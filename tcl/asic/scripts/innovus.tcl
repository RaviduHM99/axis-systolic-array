##########################################################
###     MAKE SURE YOU RAN innovus -stylus !!!!!!!!     ###
##########################################################
gui_set_ui main -geometry "1480x870+0+0"

set design(TOPLEVEL) "axis_sa"
set runtype "pnr"
set debug_file "debug.txt"

# Load general procedures
source ../../tcl/asic/scripts/procedures.tcl -quiet

####################################################
# Starting Stage - Load defines and technology
####################################################
uom_start_stage "start"

# Load the specific definitions for this project
source ../../tcl/asic/inputs/$design(TOPLEVEL).defines -quiet

# Load the library paths and definitions for this technology files
source ../../tcl/asic/libraries/cadence.libraries.$TECHNOLOGY.tcl -quiet
source ../../tcl/asic/libraries/cadence.libraries.$SC_TECHNOLOGY.tcl -quiet

if {$design(FULLCHIP_OR_MACRO) == "FULLCHIP"} {
    source $design(libraries_dir)/libraries.$IO_TECHNOLOGY.tcl -quiet
}

####################################################
# Print values to debug file
####################################################
set var_list {runtype}
set dic_list {paths_tech tech_files design}
uom_print_debug_data w $debug_file "after everything was loaded" $var_list $dic_list

####################################################
#               SDC File Generation                
####################################################
uom_create_sdc_file

####################################################
# Init Design
####################################################
enable_metrics -on
uom_start_stage "init_design"

# Global Nets
set_db init_ground_nets $design(all_ground_nets)
set_db init_power_nets  $design(all_power_nets)

# MMMC
uom_message "Suppressing the following messages that are reported due to the LIB definitions"
uom_message "$tech(LIB_SUPPRESS_MESSAGES_INNOVUS)"
set_message -suppress -id $tech(LIB_SUPPRESS_MESSAGES_INNOVUS)
uom_message "Reading MMMC File"
read_mmmc $design(mmmc_view_file)

# LEFs
uom_message "Suppressing the following messages that are reported due to the LEF definitions"
uom_message "$tech(LEF_SUPPRESS_MESSAGES_INNOVUS)"
set_message -suppress -id $tech(LEF_SUPPRESS_MESSAGES_INNOVUS)
uom_message "Reading LEF abstracts"
read_physical -lef $tech_files(ALL_LEFS)

# Post Synthesis Netlist
if {$phys_synth_type == "floorplan"} {
	read_netlist $design(postsyn_netlist_ispatial)
} else {
	read_netlist $design(postsyn_netlist_rtl_flow)
}


# Import and initialize design
init_design

# Load general settings
source ../../tcl/asic/scripts/settings.tcl -quiet

# Create cost groups
uom_default_cost_groups

# Connect Global Nets
# Connect standard cells to VDD and GND
connect_global_net $design(digital_gnd) -pin $tech(STANDARD_CELL_GND) -all -verbose
connect_global_net $design(digital_vdd) -pin $tech(STANDARD_CELL_VDD) -all -verbose
# Connect tie cells
connect_global_net $design(digital_vdd) -type tiehi -all -verbose
connect_global_net $design(digital_gnd) -type tielo -all -verbose

if {$design(FULLCHIP_OR_MACRO) == "FULLCHIP"} {
    # Connect pads to IO and CORE voltages
    #       -netlist_override is needed, since GENUS connects these pins to UNCONNECTED during synthesis
    connect_global_net $design(io_vdd)      -pin $tech(IO_VDDIO)    -hinst i_${design(IO_MODULE)} -netlist_override
    connect_global_net $design(io_gnd)      -pin $tech(IO_GNDIO)    -hinst i_${design(IO_MODULE)} -netlist_override
    connect_global_net $design(digital_vdd) -pin $tech(IO_VDDCORE)  -hinst i_${design(IO_MODULE)} -netlist_override
    connect_global_net $design(digital_gnd) -pin $tech(IO_GNDCORE)  -hinst i_${design(IO_MODULE)} -netlist_override
}

# Power Intent
# read_power_intent -1801 $design(UPF_file)
# read_power_intent $design(CPF_file)
# commit_power_intent -verbose

# Don't Use and Size Only files
#      If Don't Use file exists
# source $design(dont_use_files)
#      If Size Only file exists
# Source $design(size_only_file)

enics_create_stage_reports -save_db no -report_timing no -pop_snapshot yes

####################################################
# Floorplan
####################################################
enics_start_stage "floorplan"
source ../inputs/$design(TOPLEVEL).floorplan.defines -quiet

# If Floorplan DEF is available
# read_def $design(floorplan_def)

# If SCAN DEF is available
# read_def $design(scan_def)

# Specify Floorplan
# create_floorplan \
#       -core_size <YOUR FLOORPLAN SIZE> \
#       -core_margins_by die \
#       -flip s \
#       -match_to_site

create_floorplan -site $tech(STANDARD_CELL_SITE) -match_to_site \
    -core_density_size $design(floorplan_ratio) $design(floorplan_utilization) {*}$design(floorplan_space_to_)
gui_fit

# Set up pads (for fullchip) or pins (for macro)
if {$design(FULLCHIP_OR_MACRO) == "FULLCHIP"} {
    # Reload the IO file after resizing the floorplan
    read_io_file $design(io_file)
    # Add IO Fillers
    add_io_fillers -cells $tech(IO_FILLERS) -prefix IOFILLER
    # Connect Pad Rings
    #route_special -connect {pad_ring} \
    #               -nets "$design(digital_gnd) $design(digital_vdd) $design(io_gnd) $design(io_vdd)"
} elseif {$design(FULLCHIP_OR_MACRO) == "MACRO"} {
    # Spread pins
    set pins_to_spread [get_db ports .name]
    edit_pin -spread_type start -start {0 0} -spread_direction clockwise \
             -layer_horizontal M4 -layer_vertical M3 \
             -pin $pins_to_spread -fix_overlap 1 -spacing 6
}
gui_redraw


####################################################
# Connect Power
####################################################
# Create Core Ring
#       get_db -category add_rings *
add_rings -type core_rings -nets $design(core_ring_nets) -center 1 -follow core \
        -layer $design(core_ring_layers) -width $design(core_ring_width) -spacing $design(core_ring_spacing)

# Connect Follow Pins
#       (do this before connecting the pads, so the follow pin connections to the right are nice)
#       get_db -category route_special *
route_special -connect {core_pin} -nets $design(core_ring_nets) -pad_pin_port_connect all_geom -detailed_log

if {design(FULLCHIP_OR_MACRO) == "FULLCHIP"} {
    # Connect pads to the rings
    route_special -connect {pad_pin} -nets $design(core_ring_nets) -pad_pin_port_connect all_geom -detailed_log
}

# Add End Caps
if {$tech(LIBRARY_HAS_ENDCAPS) == "YES"} {
    # get_db -category add_endcaps *
    add_endcaps -prefix $design(end_cap_prefix)
}

# Add Well Taps
# get_db -category add_well_taps *
add_well_taps -cell $tech(WELLTAP) -checker_board -prefix $design(well_tap_prefix) \
        -cell_interval [expr 2 * $tech(WELLTAP_RULE)]
check_well_taps -max_distance $tech(WELLTAP_RULE)

# Add Stripes
# get_db -category add_stripes *

# NOTE: max_same_layer_jog_length = 10.0 is essential to prevent the
# M2 vertical stripes to go down to M1 with horizontal stripes -->
# leading to M1 shorts with standard cells. The alternative is to use 
# block_ring_bottom_layer_limit = M2
add_stripes -layer [lindex [get_db layers .name] 1] -direction vertical -nets $design(M2_stripe_nets) \
            -width $design(M2_stripes_width) -spacing $design(M2_stripes_spacing) \
            -start_from left -start_offset $design(M2_stripes_from_left) \
            -set_to_set_distance $design(M2_stripes_interval) -create_pins true \
            -max_same_layer_jog_length 10.0

# Check DRC/LVS
enics_create_stage_reports -pop_snapshot yes

# Export floorplan DEF
#       This can be used for loading the floorplan in subsequent runs
#       And also as a basis for physically-aware synthesis
write_def -floorplan -no_std_cells "$design(floorplan_def)"

####################################################
# Placement
####################################################
enics_start_stage "placement"

# Add M2 routing blockages around vertical power stripes to prevent M2 routing DRCs near them
enics_add_m2_stripes_bloackage

# get_db -category place *
set_db place_global_cong_effort auto
set_db opt_new_inst_prefix "place_opt_inst_"
set_db opt_new_net_prefix  "place_opt_net_"
place_opt_design -report_dir "$design(report_dir)/placement/place_opt_design"

# Add Tie Cells
# get_db -category add_tieoffs *
add_tieoffs 

# Fix DRV
opt_design -pre_cts -drv 

enics_create_stage_reports -pop_snapshot yes

####################################################
# Clock Tree Synthesis
####################################################
enics_start_stage "cts"

# Load Clock Tree Configuration
# create_clock_tree_spec -out_file tmp_clock_spec.ccopt
reset_ccopt_config
source $design(clock_tree_spec)

set_db opt_new_inst_prefix "cts_opt_inst_"
set_db opt_new_net_prefix  "cts_opt_net_"
ccopt_design -report_dir "$design(report_dir)/cts/ccopt_design"
# skew balanced clock tree
#clock_design

enics_create_stage_reports -pop_snapshot yes

# Open the clock tree debugger
#gui_open_ctd

# Post CTS Hold Fixing
# --------------------
enics_start_stage "post_cts_hold"
opt_design -post_cts -hold 
enics_create_stage_reports -pop_snapshot yes

####################################################
# Route
####################################################
enics_start_stage "route"

# Get rid of the M2 stripe blockages that are no longer needed and cause annoying DRC violations
enics_delete_m2_stripe_blockage

set_db route_design_with_timing_driven true
set_db route_design_with_si_driven true
set_db route_design_detail_use_multi_cut_via_effort medium

set_db opt_new_inst_prefix "route_opt_inst_"
set_db opt_new_net_prefix "route_opt_net_"
route_opt_design
enics_create_stage_reports -check_drc yes -check_connectivity yes -pop_snapshot yes

# Post Route Optimization
# -----------------------
enics_start_stage "post_route_opt"
opt_design -post_route -setup -hold

set_db route_design_with_timing_driven false
set_db route_design_with_si_driven false
set_db route_design_detail_post_route_spread_wire true
set_db route_design_detail_use_multi_cut_via_effort high
route_design -wire_opt
route_design -via_opt
set_db route_design_detail_post_route_spread_wire false
set_db route_design_with_timing_driven true
set_db route_design_with_si_driven true

enics_create_stage_reports -check_drc yes -check_connectivity yes -pop_snapshot yes

####################################################
# Export
####################################################
enics_start_stage "signoff"

# Write out a netlist for gls simulation
# ---------------------------------------------
enics_message "Writing the post route netlist to $design(postroute_netlist)"
write_netlist > $design(postroute_netlist)

# Write out SDF for backannotation simulation
# -------------------------------------------
enics_message "Writing the post route SDF to $design(postroute_sdf)"
write_sdf > $design(postroute_sdf)