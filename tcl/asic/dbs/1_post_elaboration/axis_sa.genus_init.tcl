################################################################################
#
# Init setup file
# Created by Genus(TM) Synthesis Solution on 06/11/2025 13:27:01
#
################################################################################
if { ![is_common_ui_mode] } { error "ERROR: This script requires common_ui to be active."}
::legacy::set_attribute -quiet init_mmmc_version 2 /

read_mmmc /work/axis-systolic-array/run/work/../../tcl/asic/dbs/1_post_elaboration/axis_sa.mmmc.tcl

read_physical -lef {/work/axis-systolic-array/run/work/../../../PDK/TSMC28HPCPLUS/TECH_Libs/tech_lef/1p8m_5x2z_utalrdl/sc9mcpp140z_tech.lef /work/axis-systolic-array/run/work/../../../PDK/TSMC28HPCPLUS/STD_Libs/lef/sc9mcpp140z_cln28ht_base_ulvt_c35.lef}

read_netlist /work/axis-systolic-array/run/work/../../tcl/asic/dbs/1_post_elaboration/axis_sa.v

init_design
