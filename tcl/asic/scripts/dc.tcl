#################################################################
#       Run Design Compiler NXT in topographical mode           #
#                      dc_shell_nxt -topo                       #
#################################################################
#################################################################
#           DEFINE THE NAME OF THE TOPLEVEL DESIGN              #
#              and variables specific to this run               #
#################################################################
set design(TOPLEVEL) "axis_sa"
set runtype "synthesis"
set debug_file "debug.genus.txt"

#################################################################
#                     Load Basic Settings                       #
#################################################################

# Load General Procedures
source ../../tcl/asic/scripts/synopsys.procedures.tcl -quiet

uom_start_stage "loading_basic_settings"

# Load the specific definitions for this project
source ../../tcl/asic/inputs/synopsys.$design(TOPLEVEL).defines -quiet

# Load general settings
source ../../tcl/asic/scripts/synopsys.settings.tcl -quiet

# Load the library paths and definitions for this technology
source ../../tcl/asic/libraries/synopsys.libraries.$TECHNOLOGY.tcl -quiet
source ../../tcl/asic/libraries/synopsys.libraries.$SC_TECHNOLOGY.tcl -quiet
if {$design(FULLCHIP_OR_MACRO) == "FULLCHIP"} {
    source ../../tcl/asic/libraries/synopsys.libraries.$IO_TECHNOLOGY.tcl -quiet
}

# uom_message "Suppressing the following messages that are design specific"
# uom_message "$design(DESIGN_SUPPRESS_MESSAGES_GENUS)"
# suppress_messages $design(DESIGN_SUPPRESS_MESSAGES_GENUS)

#################################################################
#                 Print Values to debug file                    #
#################################################################
set var_list {runtype phys_synth_type}
set dic_list {paths tech tech_files design}
uom_print_debug_data w $debug_file "after everything was loaded" $var_list $dic_list

#################################################################
#                    SDC File Generation                        #
#################################################################
uom_create_sdc_file

#################################################################
#                      Read LIB files                           #
#################################################################
uom_start_stage "init_libraries"

# Suppress messages
# uom_message "Suppressing the following messages that are reported due to the LEF definitions"
# uom_message "$tech(LEF_SUPPRESS_MESSAGES_GENUS)"
# suppress_messages $tech(LEF_SUPPRESS_MESSAGES_GENUS)

# Read LIBs
# ---------
uom_message "Loading the library abstracts"
set target_library "$tech_files(ALL_WC_LIBS)"
set link_library [concat "* $target_library $tech_files(ALL_TC_LIBS) $tech_files(ALL_BC_LIBS)"]

#################################################################
#                 Read Milkyway & Tech files                    #
#################################################################
# Suppress messages
# uom_message "Suppressing the following messages that are reported due to the LEF definitions"
# uom_message "$tech(LEF_SUPPRESS_MESSAGES_GENUS)"
# suppress_messages $tech(LEF_SUPPRESS_MESSAGES_GENUS)

# Read LEFs
# ---------
uom_message "Loading the Milkyway Libs"
set mw_library $design(TOPLEVEL)_milkyway_$TECHNOLOGY

if {[file exists $mw_library]} {
    open_mw_lib $mw_library
} else {
    create_mw_lib -technology $tech_files(MILKYWAY_TF) -mw_reference_library $tech_files(MILKYWAY_DATBASE) $mw_library
    open_mw_lib $mw_library
}

check_library >> $design(synthesis_reports)/1_init_libraries/check_library.rpt

#################################################################
#                      Read RTL files                           #
#################################################################
uom_start_stage "read_rtl"

read_file -format sverilog -f $design(read_hdl_list)

#################################################################
#                  Elaborate and Init Design                    #
#################################################################
# Elaborate
# ---------
uom_start_stage "elaborate"
current_design $design(TOPLEVEL)
link -force
uniquify

# Check Design
# ------------
uom_start_stage "post_elaboration_design"
uom_message "Checking design post elaboration"
check_design -all > $design(synthesis_reports)/2_post_elaboration/check_design_post_elab.rpt

# Save elaborated design
# ----------------------
write_file -hierarchy -format ddc -output $design(dbs_dir)/synthesis/2_post_elaboration/$design(TOPLEVEL).ddc

#################################################################
#                       Read MCMM                               #
#################################################################
uom_start_stage "init_mcmm_flow"

# Load MCMM File
# --------------
if {$timing_lib_type == "nldm"} {
    uom_message "Loading MMMC File with NLDM Libs"
    source $design(mcmm_nldm_view_file)
} else {
    uom_message "Loading MMMC File with CCS & OCV Libs"
    source $design(mcmm_ocv_view_file)
}

#################################################################
#                    For DEF Flow	                        #
#################################################################
if {$phys_synth_type == "floorplan"} {
    # You need to read a .def file for the floorplan to enable physical synthesis
    uom_message "Loading the floorplan DEF"
    read_def $design(floorplan_def)
}

#################################################################
#                          Synthesize                           #
#################################################################
uom_start_stage "3_pre_synthesis"

# Define OCV Methodology for Timing Analysis
# ------------------------------------------
if {$timing_lib_type == "ccs_ocv"} {
    phys_enable_ocv -native_aocv -design $design(TOPLEVEL)
}

# Define cost groups (reg2reg, in2reg, reg2out, in2out)
# -----------------------------------------------------
uom_default_cost_groups

# Physical Flow Attributes
# ------------------------
# set_db design_process_node      $TECH_NODE
# set_db number_of_routing_layers $METAL_LAYERS
#set_db design_tech_node         N7
#Compiler directives Synthesis
set compile_effort   "high"
set_app_var ungroup_keep_original_design true
set_register_merging [get_designs $top_module] false
set compile_seqmap_propagate_constants false
set compile_seqmap_propagate_high_effort false
set compile_seqmap_propagate_constants true
set compile_delete_unloaded_sequential_cells false
set hdlin_ff_always_sync_set_reset "true"

current_design $top_module

# Compile

compile_ultra -spg -no_seq_output_inversion
compile_ultra -spg -retime -no_seq_output_inversion -incremental

ungroup -all -flatten


#################################################################
#                     Post Synthesis Reports                    #
#################################################################
uom_report_timing $design(synthesis_reports)
set post_synth_reports [list \
    report_area \
    report_gates \
    report_hierarchy \
    report_design_rules \
    report_dp \
    report_qor \
]
foreach rpt $post_synth_reports {
    uom_message "$rpt" medium
    $rpt
    $rpt > "$design(synthesis_reports)/$this_run(stage)/${rpt}.rpt"
}

#################################################################
#                     Exporting the Design                      #
#################################################################
if {$phys_synth_type == "floorplan"} {
    uom_start_stage "export_post_synth_design_ispatial"

    # Write out a database for loading in Innovus/Voltus/Tempus
    # ---------------------------------------------------------
    uom_message "Exporting the design Database to $design(postsyn_db_base_name_ispatial)"
    write_db -common $design(postsyn_db_ispatial)

    # Write out a netlist for simulation or Innovus
    # ---------------------------------------------
    uom_message "Writing the post synthesis netlist to $design(postsyn_netlist_ispatial)"
    write_netlist $design(TOPLEVEL) -depth 0 > $design(postsyn_netlist_ispatial)

    # Write out SDF for backannotation simulation
    # -------------------------------------------
    uom_message "Writing the post synthesis SDF"
    write_sdf > $design(postsyn_sdf_ispatial)
} else {
    uom_start_stage "export_post_synth_rtl_floorplanning"

    # Write out a database for loading in Innovus/Voltus/Tempus
    # ---------------------------------------------------------
    uom_message "Exporting the design Database to $design(postsyn_db_base_name_rtl_flow)"
    write_db -common $design(postsyn_db_rtl_flow)

    # Write out a netlist for simulation or Innovus
    # ---------------------------------------------
    uom_message "Writing the post synthesis netlist to $design(postsyn_netlist_rtl_flow)"
    write_netlist $design(TOPLEVEL) -depth 0 > $design(postsyn_netlist_rtl_flow)

    # Write out SDF for backannotation simulation
    # -------------------------------------------
    uom_message "Writing the post synthesis SDF"
    write_sdf > $design(postsyn_sdf_rtl_flow)
}
uom_message "!!!!!!!!!!!!!!!!!!! Genus Synthesis Successful !!!!!!!!!!!!!!!!!!!!!"
