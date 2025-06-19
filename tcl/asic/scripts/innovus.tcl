##########################################################
###     MAKE SURE YOU RAN innovus -stylus !!!!!!!!     ###
##########################################################
gui_set_ui main -geometry "1920x1020+0+0"

set design(TOPLEVEL) "axis_sa"
set runtype "pnr"
set debug_file "debug.innovus.txt"

####################################################
# Starting Stage - Load defines and technology
####################################################
# Load general procedures
source ../../tcl/asic/scripts/procedures.tcl -quiet

uom_start_stage "loading_basic_settings"

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
uom_start_stage "1_init_design"

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

# Connect Global Net
# ------------------
# Connect standard cells to VDD and GND
connect_global_net $design(digital_gnd) -pin $tech(STANDARD_CELL_GND) -all -verbose
connect_global_net $design(digital_vdd) -pin $tech(STANDARD_CELL_VDD) -all -verbose
# Connect tie cells
connect_global_net $design(digital_vdd) -type tie_hi -all -verbose
connect_global_net $design(digital_gnd) -type tie_lo -all -verbose

if {$design(FULLCHIP_OR_MACRO) == "FULLCHIP"} {
    # Connect pads to IO and CORE voltages
    #       -netlist_override is needed, since GENUS connects these pins to UNCONNECTED during synthesis
    connect_global_net $design(io_vdd)      -pin $tech(IO_VDDIO)    -hinst i_${design(IO_MODULE)} -netlist_override
    connect_global_net $design(io_gnd)      -pin $tech(IO_GNDIO)    -hinst i_${design(IO_MODULE)} -netlist_override
    connect_global_net $design(digital_vdd) -pin $tech(IO_VDDCORE)  -hinst i_${design(IO_MODULE)} -netlist_override
    connect_global_net $design(digital_gnd) -pin $tech(IO_GNDCORE)  -hinst i_${design(IO_MODULE)} -netlist_override
}

uom_create_stage_reports -write_db yes -report_timing no -check_drc no \
                           -check_connectivity no 

####################################################
# Floorplan
####################################################
uom_start_stage "2_floorplan"
source ../../tcl/asic/inputs/$design(TOPLEVEL).floorplan.defines -quiet

if {$phys_synth_type == "floorplan"} {
    # You need to read a .def file for the floorplan to enable physical synthesis
    uom_message "Loading the floorplan DEF"
    read_def $design(floorplan_def)
}

# Specify Floorplan
create_floorplan -site $tech(STANDARD_CELL_SITE) -match_to_site \
    -core_density_size $design(floorplan_ratio) $design(floorplan_utilization) {*}$design(floorplan_space_to_core)
gui_fit

# Set up pads (for fullchip) or pins (for macro)
if {$design(FULLCHIP_OR_MACRO) == "FULLCHIP"} {
    # Reload the IO file after resizing the floorplan
    read_io_file $design(io_file)
    # Add IO Fillers
    add_io_fillers -cells $tech(IO_FILLERS) -prefix IOFILLER
    # Connect Pad Rings
    route_special -connect {pad_ring} -nets "$design(digital_gnd) $design(digital_vdd) \
                            $design(io_gnd) $design(io_vdd)"
} elseif {$design(FULLCHIP_OR_MACRO) == "MACRO"} {
    # Spread pins
    set pins_to_spread [get_db ports .name]
    edit_pin -spread_direction clockwise -spread_type center \
             -layer M5 -side Top -fix_overlap 1 -spacing 2 \
             -pin $design(CLOCK_PIN)
    edit_pin -spread_direction clockwise -spread_type center \
             -layer M3 -side Top -fix_overlap 1 -spacing 2 \
             -pin $design(TOP_INPUT_PINS)
    edit_pin -spread_direction clockwise -spread_type center \
             -layer M4 -side Left -fix_overlap 1 -spacing 2 \
             -pin $design(LEFT_INPUT_PINS)
    edit_pin -spread_direction clockwise -spread_type center \
             -layer M4 -side Right -fix_overlap 1 -spacing 2 \
             -pin $design(RIGHT_OUTPUT_PINS)       

}
gui_redraw
gui_fit

####################################################
# Connect Power
####################################################
uom_start_stage "power_grid_creation"
# Create Core Ring
add_rings -type core_rings -nets $design(core_ring_nets) -center 1 -follow core \
        -layer $design(core_ring_layers) -width $design(core_ring_width) -spacing $design(core_ring_spacing)

# Connect Follow Pins
route_special -connect {core_pin} -nets $design(core_ring_nets) -pad_pin_port_connect all_geom -detailed_log

if {$design(FULLCHIP_OR_MACRO) == "FULLCHIP"} {
    # Connect pads to the rings
    route_special -connect {pad_pin} -nets $design(core_ring_nets) -pad_pin_port_connect all_geom -detailed_log
}

# Add End Caps
add_endcaps -prefix $tech(END_CAP_PREFIX)

# Add Well Taps
add_well_taps -cell $tech(FILL_TIE_CELL) -checker_board -prefix $tech(FILL_TIE_PREFIX) \
        -cell_interval [expr 2 * $design(WELLTAP_RULE)]
check_well_taps -max_distance $design(WELLTAP_RULE)

# Add Stripes
add_stripes -layer [lindex [get_db layers .name] 7] -direction vertical -nets $design(M7_stripes_nets) \
            -width $design(M7_stripes_width) -spacing $design(M7_stripes_spacing) \
            -start_from left -start_offset $design(M7_stripes_from_left) \
            -set_to_set_distance $design(M7_stripes_interval) -create_pins true \
            -max_same_layer_jog_length 10.0

# Check DRC/LVS
check_connectivity -type special > $design(pnr_reports)/2_floorplan/power_connectivity.rpt
uom_create_stage_reports -write_db yes -report_timing no -check_drc yes \
                           -check_connectivity no

# Export floorplan DEF
# This can be used for loading the floorplan in subsequent runs
#   And also as a basis for physically-aware synthesis
write_def -floorplan -no_std_cells "$design(floorplan_def)"

####################################################
# Placement
####################################################
uom_start_stage "3_placement"

# Add M2 routing blockages around vertical power stripes to prevent M2 routing DRCs near them
uom_add_m2_stripe_blockage

set_db place_global_cong_effort auto
set_db opt_new_inst_prefix "place_opt_inst_"
set_db opt_new_net_prefix  "place_opt_net_"
place_opt_design -report_dir "$design(reports_dir)/pnr/3_placement/place_opt_design"

# Add Tie Cells
add_tieoffs -lib_cell "$tech(TIE_HIGH_CELL) $tech(TIE_LOW_CELL)" -prefix $tech(TIE_PREFIX)

# Fix DRV
opt_design -pre_cts -drv 

check_place > $design(pnr_reports)/3_placement/power_connectivity.rpt
uom_create_stage_reports -write_db yes -report_timing no -check_drc yes \
                           -check_connectivity no -help 1

####################################################
# Clock Tree Synthesis
####################################################
uom_start_stage "4_clock_tree_synthesis"

# Load Clock Tree Configuration
create_clock_tree_spec -out_file tmp_clock_spec.ccopt 
# Run until this examine clock tree spec
##########################################################
##########################################################
##########################################################
##########################################################
##########################################################
reset_ccopt_config
source $design(clock_tree_spec)

set_db opt_new_inst_prefix "cts_opt_inst_"
set_db opt_new_net_prefix  "cts_opt_net_"
ccopt_design -report_dir "$design(reports_dir)/pnr/4_clock_tree_synthesis/ccopt_design"

uom_create_stage_reports -write_db yes -report_timing yes -check_drc yes \
                           -check_connectivity yes 

# Open the clock tree debugger and check Clock Tree
#gui_open_ctd

# Post CTS Hold Fixing
# --------------------
uom_start_stage "5_post_cts_hold"
opt_design -post_cts -hold 
uom_create_stage_reports -write_db yes -report_timing yes -check_drc yes \
                           -check_connectivity yes 

####################################################
# Route
####################################################
# Pre Routing
# -----------
uom_start_stage "6_pre_route"

# Get rid of the M2 stripe blockages that are no longer needed and cause annoying DRC violations
uom_delete_m2_stripe_blockage

set_db route_design_with_timing_driven true
set_db route_design_with_si_driven true
set_db route_design_detail_use_multi_cut_via_effort medium

set_db opt_new_inst_prefix "route_opt_inst_"
set_db opt_new_net_prefix "route_opt_net_"
route_opt_design
uom_create_stage_reports -write_db yes -report_timing yes -check_drc yes \
                           -check_connectivity yes 

# Post Route Optimization
# -----------------------
uom_start_stage "7_post_route_opt"
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

add_fillers -cell $tech(FILL_CELL) -prefix $tech(FILL_CELL_PREFIX);
route_eco -fix_drc

uom_create_stage_reports -write_db yes -report_timing yes -check_drc yes \
                           -check_connectivity yes 

####################################################
# Export
####################################################
uom_start_stage "8_signoff"

# Write out a netlist for gls simulation
# ---------------------------------------------
enics_message "Writing the post route netlist to $design(postroute_netlist)"
write_netlist > $design(postroute_netlist)

# Write out SDF for backannotation simulation
# -------------------------------------------
enics_message "Writing the post route SDF to $design(postroute_sdf)"
write_sdf > $design(postroute_sdf)