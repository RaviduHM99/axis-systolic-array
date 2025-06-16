##########################################################
###     MAKE SURE YOU RAN voltus -stylus !!!!!!!!      ###
##########################################################

set design(TOPLEVEL) "axis_sa"
set debug_file "debug.voltus.txt"
set runtype "power"

# Load general procedures
source ../../tcl/asic/scripts/procedures.tcl -quiet
# Load the specific definitions for this project
source ../../tcl/asic/inputs/$design(TOPLEVEL).defines -quiet
# Load general settings
source ../../tcl/asic/scripts/settings.tcl -quiet

# Load the library paths and definitions for this technology
source ../../tcl/asic/libraries/libraries.$TECHNOLOGY.tcl -quiet
source ../../tcl/asic/libraries/libraries.$SC_TECHNOLOGY.tcl -quiet

# Restore design from Genus
if {$phys_synth_type == "floorplan"} {
    read_db $design(postsyn_db_ispatial)
} else {
    read_db $design(postsyn_db_rtl_flow)
}

set_db power_method static
set_db power_report_missing_nets true
set_db power_view $design(selected_power_analysis_view)
set_analysis_view -setup $design(selected_power_analysis_view) -hold $design(selected_power_analysis_view)
                  -leakage $design(selected_power_analysis_view) -dynamic $design(selected_power_analysis_view)

# TCF
#read_activity_file -reset
#read_activity_file -format TCF -scope $design(dut_name) $design(tcf_file)

# VCD
read_activity_file -reset
read_activity_file -format VCD -scope $design(tb_name).$design(dut_name) \
            -start $design(power_report_start_time) -end $design(power_report_end_time) \
            $design(vcd_file)

report_power -rail_analysis_format VS -out_file $design(synthesis_reports)/5_synth_gls/static_synth_power_report.rpt
