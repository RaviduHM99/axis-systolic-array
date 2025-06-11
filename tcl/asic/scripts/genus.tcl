#################################################################
#           DEFINE THE NAME OF THE TOPLEVEL DESIGN              #
#              and variables specific to this run               #
#################################################################
set design(TOPLEVEL) "axis_sa"

# Variables
set runtype "synthesis"
set mmmc_or_simple "mmmc";   # "simple" - using "read_lib"
                             # "mmmc"   - using "read_mmmc"
set phys_synth_type "lef" ;  # "none"   - don't read any tech files
                             # "lef"    - only read lef - RTL Floorplaning Flow
                             # "floorplan" - read in DEF - iSpatial Flow

#################################################################
#                     Load Basic Settings                       #
#################################################################

# Load General Procedures
source ../../tcl/asic/scripts/procedures.tcl -quiet

uom_start_stage "start"

set debug_file "debug.txt"

# Load the specific definitions for this project
source ../../tcl/asic/inputs/$design(TOPLEVEL).defines -quiet

# Load general settings
source ../../tcl/asic/scripts/settings.tcl -quiet

# Load the library paths and definitions for this technology
source ../../tcl/asic/libraries/cadence.libraries.$TECHNOLOGY.tcl -quiet
source ../../tcl/asic/libraries/cadence.libraries.$SC_TECHNOLOGY.tcl -quiet
if {$design(FULLCHIP_OR_MACRO) == "FULLCHIP"} {
    source ../../tcl/asic/libraries/cadence.libraries.$IO_TECHNOLOGY.tcl -quiet
}

uom_message "Suppressing the following messages that are design specific"
uom_message "$design(DESIGN_SUPPRESS_MESSAGES_GENUS)"
suppress_messages $design(DESIGN_SUPPRESS_MESSAGES_GENUS)

#################################################################
#              Print Values to debug file                       #
#################################################################
set var_list {runtype phys_synth_type}
set dic_list {paths tech tech_files design}
uom_print_debug_data w $debug_file "after everything was loaded" $var_list $dic_list

#################################################################
#                           Read MMMC                           #
#################################################################
uom_start_stage "init_libraries"

# Suppress messages
uom_message "Suppressing the following messages that are reported due to the library definitions"
uom_message "$tech(LIB_SUPPRESS_MESSAGES_GENUS)"
suppress_messages $tech(LIB_SUPPRESS_MESSAGES_GENUS)

# Load MMMC File
# --------------
uom_message "Loading MMMC File"
read_mmmc $design(mmmc_view_file)

#################################################################
#                      Read LEF files                           #
#################################################################
# Suppress messages
uom_message "Suppressing the following messages that are reported due to the LEF definitions"
uom_message "$tech(LEF_SUPPRESS_MESSAGES_GENUS)"
suppress_messages $tech(LEF_SUPPRESS_MESSAGES_GENUS)

# Read LEFs
# ---------
uom_message "Loading the library abstracts"
read_physical -lef $tech_files(ALL_LEFS)

#################################################################
#                      Read RTL files                           #
#################################################################
uom_start_stage "read_rtl"

set_db init_hdl_search_path $design(hdl_search_paths)
read_hdl -language sv -f $design(read_hdl_list)

#################################################################
#                  Elaborate and Init Design                    #
#################################################################
# Elaborate
# ---------
uom_start_stage "elaborate"
elaborate $design(TOPLEVEL)

# Check Design
# ------------
uom_start_stage "1_post_elaboration"
uom_message "Checking design post elaboration"
check_design -unresolved
check_design -all > $design(synthesis_reports)/1_post_elaboration/check_design_post_elab.rpt
if {[check_design -status]} {
    puts "uomINFO: ############### There is an issure with check design. You better look at it! ###############"
}

# Init Design
# -----------
uom_message "Running init_design in an MMMC flow"
init_design

# Check Timing
# ------------
uom_message "Checking timing intent (lint) after init_design"
check_timing_intent
check_timing _intent -verbose > $design(synthesis_reports)/1_post_elaboration/check_timing_post_elab.rpt

# Save elaborated design
# ----------------------
write_design -base_name $design(dbs_dir)/1_post_elaboration/$design(TOPLEVEL)

#################################################################
#                    For iSpatial Flow	                        #
#################################################################
# Optionally read floorplan
# -------------------------
if {$phys_synth_type == "floorplan"} {
    # You need to read a .def file for the floorplan to enable physical synthesis
    uom_message "Loading the floorplan DEF"
    read_def $design(floorplan_def)
}

#################################################################
#                          Synthesize                           #
#################################################################
uom_start_stage "2_pre_synthesis"

# Define cost groups (reg2reg, in2reg, reg2out, in2out)
# -----------------------------------------------------
uom_default_cost_groups
uom_report_timing $design(synthesis_reports)

# Set Retime
set_db design:${design(TOPLEVEL)} .retime true

# Clock Gating Settings
# ---------------------
# set_db [get_db design:design(TOPLEVEL)] .lp_clock_gating_min_flops 8
# set_db [get_db design:design(TOPLEVEL)] .lp_clock_gating_style latch

# Don't use Scan Cells
# --------------------
uom_message "Settings Don't Use on scan flip flops"
foreach cell [get_db lib_cells -if {.scan_enable_pins!=""}] {set_db $cell .avoid true}

# Physical Flow Attributes
# ------------------------
set_db design_process_node      $TECH_NODE
set_db number_of_routing_layers $METAL_LAYERS


if {$phys_synth_type == "floorplan"} {
    # Set Synthesis Efforts
    set_db syn_generic_effort express           ; # low|medium|high|express
    set_db syn_map_effort high                  ; # low|medium|high
    set_db syn_opt_effort extreme               ; # low|medium|high|extreme
    set_db opt_spatial_effort extreme           ; # legacy|standard|extreme
    set_db design_power_effort high             ; # none|low|high

    # Synthesize to generics and place generics in floorplan
    uom_start_stage "syn_generic_ispatial_flow"
    syn_generic -physical
    # Map technology
    uom_start_stage "3_technology_mapping_ispatial_flow"
    syn_map -physical
    uom_report_timing $design(synthesis_reports)
    # Post synthesis optimization
    uom_start_stage "4_post_syn_opt_ispatial_flow"
    syn_opt -spatial
} else {
    # Set Synthesis Efforts
    set_db syn_generic_effort high           ; # low|medium|high|express
    set_db syn_map_effort medium               ; # low|medium|high
    set_db syn_opt_effort medium               ; # low|medium|high|extreme
    set_db opt_spatial_effort standard      ; # legacy|standard|extreme
    set_db design_power_effort high         ; # none|low|high

    # Predict Floorplan Attributes
    set_db predict_floorplan_enable_during_generic true
    set_db physical_force_predict_floorplan true

    # Synthesize to generics and place generics in floorplan
    uom_start_stage "syn_generic_rtl_flow"
    syn_generic -create_floorplan -physical
    # Map technology
    uom_start_stage "3_technology_mapping_rtl_flow"
    syn_map -physical
    uom_report_timing $design(synthesis_reports)
    # Disable Predict Floorplan Again
    set_db physical_force_predict_floorplan false
    # Post synthesis optimization
    uom_start_stage "4_post_syn_opt_rtl_flow"
    syn_opt -spatial
}

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
    uom_start_stage "2_export_design_ispatial_flow"

    # Write out a database for loading in Innovus/Voltus/Tempus
    # ---------------------------------------------------------
    uom_message "Exporting the design Database to $design(postsyn_db_base_name_ispatial)"
    write_design -base_name $design(postsyn_db_base_name_ispatial) -innovus -db

    # Write out a netlist for simulation or Innovus
    # ---------------------------------------------
    uom_message "Writing the post synthesis netlist to $design(postsyn_netlist_ispatial)"
    write_netlist > $design(postsyn_netlist_ispatial)

    # Write out SDF for backannotation simulation
    # -------------------------------------------
    uom_message "Writing the post synthesis SDF"
    write_sdf > $design(postsyn_sdf_ispatial)
} else {
    uom_start_stage "2_export_design_rtl_floorplanning"

    # Write out a database for loading in Innovus/Voltus/Tempus
    # ---------------------------------------------------------
    uom_message "Exporting the design Database to $design(postsyn_db_base_name_rtl_flow)"
    write_design -base_name $design(postsyn_db_base_name_rtl_flow) -innovus -db

    # Write out a netlist for simulation or Innovus
    # ---------------------------------------------
    uom_message "Writing the post synthesis netlist to $design(postsyn_netlist_rtl_flow)"
    write_netlist > $design(postsyn_netlist_rtl_flow)

    # Write out SDF for backannotation simulation
    # -------------------------------------------
    uom_message "Writing the post synthesis SDF"
    write_sdf > $design(postsyn_sdf_rtl_flow)
}
