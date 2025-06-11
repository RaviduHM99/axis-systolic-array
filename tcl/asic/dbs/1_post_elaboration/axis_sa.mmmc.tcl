#################################################################################
#
# Created by Genus(TM) Synthesis Solution 23.13-s073_1 on Wed Jun 11 13:27:00 UTC 2025
#
#################################################################################

## library_sets
create_library_set -name bc_libset \
    -timing { /work/axis-systolic-array/run/work/../../../PDK/TSMC28HPCPLUS/STD_Libs/lib/sc9mcpp140z_cln28ht_base_ulvt_c35_ffg_cbestt_min_0p77v_m40c.lib \
              /work/axis-systolic-array/run/work/../../../PDK/TSMC28HPCPLUS/STD_Libs/lib/sc9mcpp140z_cln28ht_base_ulvt_c35_ffg_cbestt_min_0p88v_m40c.lib \
              /work/axis-systolic-array/run/work/../../../PDK/TSMC28HPCPLUS/STD_Libs/lib/sc9mcpp140z_cln28ht_base_ulvt_c35_ffg_cbestt_min_1p05v_m40c.lib }
create_library_set -name tc_libset \
    -timing { /work/axis-systolic-array/run/work/../../../PDK/TSMC28HPCPLUS/STD_Libs/lib/sc9mcpp140z_cln28ht_base_ulvt_c35_tt_ctypical_max_0p70v_85c.lib \
              /work/axis-systolic-array/run/work/../../../PDK/TSMC28HPCPLUS/STD_Libs/lib/sc9mcpp140z_cln28ht_base_ulvt_c35_tt_ctypical_max_0p90v_85c.lib \
              /work/axis-systolic-array/run/work/../../../PDK/TSMC28HPCPLUS/STD_Libs/lib/sc9mcpp140z_cln28ht_base_ulvt_c35_tt_ctypical_max_1p05v_85c.lib }
create_library_set -name wc_libset \
    -timing { /work/axis-systolic-array/run/work/../../../PDK/TSMC28HPCPLUS/STD_Libs/lib/sc9mcpp140z_cln28ht_base_ulvt_c35_ssg_cworstt_max_0p72v_125c.lib \
              /work/axis-systolic-array/run/work/../../../PDK/TSMC28HPCPLUS/STD_Libs/lib/sc9mcpp140z_cln28ht_base_ulvt_c35_ssg_cworstt_max_0p81v_125c.lib \
              /work/axis-systolic-array/run/work/../../../PDK/TSMC28HPCPLUS/STD_Libs/lib/sc9mcpp140z_cln28ht_base_ulvt_c35_ssg_cworstt_max_0p90v_125c.lib }

## timing_condition
create_timing_condition -name bc_timing_condition \
    -library_sets { bc_libset }
create_timing_condition -name tc_timing_condition \
    -library_sets { tc_libset }
create_timing_condition -name wc_timing_condition \
    -library_sets { wc_libset }

## rc_corner
create_rc_corner -name bc_rc_corner \
    -temperature -40.0 \
    -cap_table /work/axis-systolic-array/run/work/../../../PDK/TSMC28HPCPLUS/TECH_Libs/captbl/1p8m_5x2z_utalrdl/rcbest.captbl \
    -pre_route_res 1.0 \
    -pre_route_cap 1.0 \
    -pre_route_clock_res 0.0 \
    -pre_route_clock_cap 0.0 \
    -post_route_res {1.0 1.0 1.0} \
    -post_route_cap {1.0 1.0 1.0} \
    -post_route_cross_cap {1.0 1.0 1.0} \
    -post_route_clock_res {1.0 1.0 1.0} \
    -post_route_clock_cap {1.0 1.0 1.0} \
    -post_route_clock_cross_cap {1.0 1.0 1.0}
create_rc_corner -name tc_rc_corner \
    -temperature 85.0 \
    -cap_table /work/axis-systolic-array/run/work/../../../PDK/TSMC28HPCPLUS/TECH_Libs/captbl/1p8m_5x2z_utalrdl/typical.captbl \
    -pre_route_res 1.0 \
    -pre_route_cap 1.0 \
    -pre_route_clock_res 0.0 \
    -pre_route_clock_cap 0.0 \
    -post_route_res {1.0 1.0 1.0} \
    -post_route_cap {1.0 1.0 1.0} \
    -post_route_cross_cap {1.0 1.0 1.0} \
    -post_route_clock_res {1.0 1.0 1.0} \
    -post_route_clock_cap {1.0 1.0 1.0} \
    -post_route_clock_cross_cap {1.0 1.0 1.0}
create_rc_corner -name wc_rc_corner \
    -temperature 125.0 \
    -cap_table /work/axis-systolic-array/run/work/../../../PDK/TSMC28HPCPLUS/TECH_Libs/captbl/1p8m_5x2z_utalrdl/rcworst.captbl \
    -pre_route_res 1.0 \
    -pre_route_cap 1.0 \
    -pre_route_clock_res 0.0 \
    -pre_route_clock_cap 0.0 \
    -post_route_res {1.0 1.0 1.0} \
    -post_route_cap {1.0 1.0 1.0} \
    -post_route_cross_cap {1.0 1.0 1.0} \
    -post_route_clock_res {1.0 1.0 1.0} \
    -post_route_clock_cap {1.0 1.0 1.0} \
    -post_route_clock_cross_cap {1.0 1.0 1.0}

## delay_corner
create_delay_corner -name bc_dly_corner \
    -early_timing_condition { bc_timing_condition } \
    -late_timing_condition { bc_timing_condition } \
    -early_rc_corner bc_rc_corner \
    -late_rc_corner bc_rc_corner
create_delay_corner -name tc_dly_corner \
    -early_timing_condition { tc_timing_condition } \
    -late_timing_condition { tc_timing_condition } \
    -early_rc_corner tc_rc_corner \
    -late_rc_corner tc_rc_corner
create_delay_corner -name wc_dly_corner \
    -early_timing_condition { wc_timing_condition } \
    -late_timing_condition { wc_timing_condition } \
    -early_rc_corner wc_rc_corner \
    -late_rc_corner wc_rc_corner

## constraint_mode
create_constraint_mode -name functional_mode \
    -sdc_files { /work/axis-systolic-array/run/work/../../tcl/asic/dbs/1_post_elaboration/axis_sa.functional_mode.sdc }

## analysis_view
create_analysis_view -name bc_analysis_view \
    -constraint_mode functional_mode \
    -delay_corner bc_dly_corner
create_analysis_view -name tc_analysis_view \
    -constraint_mode functional_mode \
    -delay_corner tc_dly_corner
create_analysis_view -name wc_analysis_view \
    -constraint_mode functional_mode \
    -delay_corner wc_dly_corner

## set_analysis_view
set_analysis_view -setup { wc_analysis_view } \
                  -hold { bc_analysis_view }
