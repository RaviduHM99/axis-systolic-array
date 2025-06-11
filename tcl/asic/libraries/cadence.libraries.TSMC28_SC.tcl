# Set Paths for Timing Libs
set paths(LIB_Paths) "$paths(PDK_ROOT)/STD_Libs/lib"

# General
set tech(LIBRARY_HAS_ENDCAPS) "YES"
set tech(STANDARD_CELL_VDD) VDD
set tech(STANDARD_CELL_GND) VSS

# LEFS
lappend tech(LIB_SUPPRESS_MESSAGES_GENUS) {*}"LBR-9 LBR-76 LBR-40 LBR-436 LBR-170 LBR-415 LBR-162 LBR-155"
lappend tech(LIB_SUPPRESS_MESSAGES_INNOVUS) {*}"LBR-9 LBR-76 LBR-40 LBR-436 LBR-170 LBR-415 LBR-162 LBR-155"

# Libs

set tech_files(STANDARD_CELLS_LVT_BC_LIB) "$paths(LIB_Paths)/sc9mcpp140z_cln28ht_base_ulvt_c35_ffg_cbestt_min_0p77v_m40c.lib"
    set tech_files(ALL_BC_LIBS) $tech_files(STANDARD_CELLS_LVT_BC_LIB)
set tech_files(STANDARD_CELLS_LVT_WC_LIB) "$paths(LIB_Paths)/sc9mcpp140z_cln28ht_base_ulvt_c35_ssg_cworstt_max_0p72v_125c.lib"
    set tech_files(ALL_WC_LIBS) $tech_files(STANDARD_CELLS_LVT_WC_LIB)
set tech_files(STANDARD_CELLS_LVT_TC_LIB) "$paths(LIB_Paths)/sc9mcpp140z_cln28ht_base_ulvt_c35_tt_ctypical_max_0p70v_85c.lib"
    set tech_files(ALL_TC_LIBS) $tech_files(STANDARD_CELLS_LVT_TC_LIB)

set tech_files(STANDARD_CELLS_RVT_BC_LIB) "$paths(LIB_Paths)/sc9mcpp140z_cln28ht_base_ulvt_c35_ffg_cbestt_min_0p88v_m40c.lib"
    lappend tech_files(ALL_BC_LIBS) $tech_files(STANDARD_CELLS_RVT_BC_LIB)
set tech_files(STANDARD_CELLS_RVT_WC_LIB) "$paths(LIB_Paths)/sc9mcpp140z_cln28ht_base_ulvt_c35_ssg_cworstt_max_0p81v_125c.lib"
    lappend tech_files(ALL_WC_LIBS) $tech_files(STANDARD_CELLS_RVT_WC_LIB)
set tech_files(STANDARD_CELLS_RVT_TC_LIB) "$paths(LIB_Paths)/sc9mcpp140z_cln28ht_base_ulvt_c35_tt_ctypical_max_0p90v_85c.lib"
    lappend tech_files(ALL_TC_LIBS) $tech_files(STANDARD_CELLS_RVT_TC_LIB)

set tech_files(STANDARD_CELLS_HVT_BC_LIB) "$paths(LIB_Paths)/sc9mcpp140z_cln28ht_base_ulvt_c35_ffg_cbestt_min_1p05v_m40c.lib"
    lappend tech_files(ALL_BC_LIBS) $tech_files(STANDARD_CELLS_HVT_BC_LIB)
set tech_files(STANDARD_CELLS_HVT_WC_LIB) "$paths(LIB_Paths)/sc9mcpp140z_cln28ht_base_ulvt_c35_ssg_cworstt_max_0p90v_125c.lib"
    lappend tech_files(ALL_WC_LIBS) $tech_files(STANDARD_CELLS_HVT_WC_LIB)
set tech_files(STANDARD_CELLS_HVT_TC_LIB) "$paths(LIB_Paths)/sc9mcpp140z_cln28ht_base_ulvt_c35_tt_ctypical_max_1p05v_85c.lib"
    lappend tech_files(ALL_TC_LIBS) $tech_files(STANDARD_CELLS_HVT_TC_LIB)
