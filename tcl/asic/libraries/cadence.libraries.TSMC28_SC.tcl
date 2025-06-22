# Set Paths for Timing Libs
set paths(LIB_Paths) "$paths(PDK_ROOT)/STD_Libs/lib"

# General
set tech(STANDARD_CELL_VDD)   VDD
set tech(STANDARD_CELL_GND)   VSS
set tech(STANDARD_CELL_SITE)  sc9mcpp140z_cln28ht

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

# Set Input and Output Capacitance Values from Std Cells
set tech(SDC_LOAD_PIN)      BUF_X0P5B_A9PP140ZTUL_C35/A
set tech(SDC_DRIVING_CELL)  BUF_X0P5B_A9PP140ZTUL_C35

# Set Tie High and Tie Low cells
set tech(TIE_PREFIX)        TIEOFF_
set tech(TIE_HIGH_CELL)     TIEHI_X1M_A9PP140ZTUL_C35
set tech(TIE_LOW_CELL)      TIELO_X1M_A9PP140ZTUL_C35

# Set End Cap Cells, Fill Tie Cells
set tech(END_CAP_PREFIX)    ENDCAP_
set tech(END_CAP_CELL)      ENDCAPTIE3_A9PP140ZTUL_C35 
set tech(FILL_TIE_PREFIX)   FILLTIE 
set tech(FILL_TIE_CELL)     FILLTIE5_A9PP140ZTUL_C35

# Set Fill Cells
set tech(FILL_CELL_PREFIX) FILLER_CELL_
set tech(FILL_CELL)         "FILLSGCAP2_A9PP140ZTUL_C35 FILLSGCAP3_A9PP140ZTUL_C35 FILLSGCAP4_A9PP140ZTUL_C35 FILLSGCAP8_A9PP140ZTUL_C35 FILLSGCAP16_A9PP140ZTUL_C35 FILLSGCAP32_A9PP140ZTUL_C35 FILLSGCAP64_A9PP140ZTUL_C35 FILLSGCAP128_A9PP140ZTUL_C35"

# Set Antenna Cell
set tech(ANTENNA_CELL)      ANTENNA2_A9PP140ZTUL_C35

# Routing Rules
set tech(LAYER_NAMES)       [lrange [get_db layers .name] 0 9]
set tech(MIN_SPACING_X)     [lrange [get_db layers .min_spacing] 2]
set tech(MIN_WIDTH_X)       [lrange [get_db layers .min_width] 2]
set tech(MIN_SPACING_Y)     [lrange [get_db layers .min_spacing] 3]
set tech(MIN_WIDTH_Y)       [lrange [get_db layers .min_width] 3]
set tech(MIN_SPACING_Z)     [lrange [get_db layers .min_spacing] 7]
set tech(MIN_WIDTH_Z)       [lrange [get_db layers .min_width] 7]
set tech(MIN_SPACING_STRIPES) 0.25 ; # Comes from [dbGet head.layers.spacingTables]

# Set Clock Tree Specs 
# set tech(CCOPT_DRIVING_PIN) {BUF_X0P5B_A9PP140ZTUL_C35/A BUF_X0P5B_A9PP140ZTUL_C35/Y}
# set tech(CLOCK_BUFFERS)     BUF_X0P5B_A9PP140ZTUL_C35
# set tech(CLOKC_GATES)       
# set tech(CLOCK_INVERTERS)   
# set tech(CLOCK_LOGIC)       MXGL2
# set tech(CLOCK_DELAYS)      DLYCLK8

# Set Slew Rates from Documentation
set tech(CLOCK_SLEW)        0.00108
set tech(DATA_SLEW)         0.00108
set tech(INPUT_SLEW)        0.00108

# Clock Route Rules
set tech(cts_top_routing_layer_top)         [lindex [get_db layers] 6]   
set tech(cts_bottom_routing_layer_top)      [lindex [get_db layers] 5]
set tech(cts_top_routing_layer_trunk)       [lindex [get_db layers] 6]
set tech(cts_bottom_routing_layer_trunk)    [lindex [get_db layers] 5]
set tech(cts_top_routing_layer_leaf)        [lindex [get_db layers] 4]
set tech(cts_bottom_routing_layer_leaf)     [lindex [get_db layers] 3]