# Route Technology settings for the TSMC 28 HPCPLUS Technology
set TECHNOLOGY_NODE TSMC28HPCPLUS
set METAL_STACK     1p8m_5x2z_utalrdl
set METAL_LAYERS    9
set TECH_NODE       28

# Technology
set HOME                                 "../../.."
set paths(PDK_ROOT)                      "$HOME/PDK/$TECHNOLOGY_NODE"
set paths(TECHNOLOGY_FILES)              "$paths(PDK_ROOT)/TECH_Libs"
set paths(STANDARD_CELLS_MILKYWAY_FILES) "$paths(PDK_ROOT)/STD_Libs/milkyway"
set paths(STANDARD_CELLS_TECH_FILES)     "$paths(PDK_ROOT)/STD_Libs/lef"

# LEFS
# lappend tech(LEF_SUPPRESS_MESSAGES_GENUS) {*}"PHYS-279"
# lappend tech(LEF_SUPPRESS_MESSAGES_INNOVUS) {*}"IMPLF_20"

set tech_files(MILKYWAY_TF)      "$paths(TECHNOLOGY_FILES)/milkyway/$METAL_STACK/sc9mcpp140z_tech.tf"
set tech_files(MILKYWAY_DATBASE) "$paths(STANDARD_CELLS_MILKYWAY_FILES)"
set tech_files(STD_LEF)          "$paths(STANDARD_CELLS_TECH_FILES)/sc9mcpp140z_cln28ht_base_ulvt_c35.lef"

# Temperatures for Corners
set tech(TEMPERATURE_BC) -40
set tech(TEMPERATURE_TC) 85
set tech(TEMPERATURE_WC) 125

# Parasitic Extraction
set tech_files(TLUPLUS_BC)  "$paths(TECHNOLOGY_FILES)/synopsys_tluplus/$METAL_STACK/rcbest.tluplus"
set tech_files(TLUPLUS_TC)  "$paths(TECHNOLOGY_FILES)/synopsys_tluplus/$METAL_STACK/typical.tluplus"
set tech_files(TLUPLUS_WC)  "$paths(TECHNOLOGY_FILES)/synopsys_tluplus/$METAL_STACK/rcworst.tluplus"
set tech_files(TLUPLUS_MAP) "$paths(TECHNOLOGY_FILES)/synopsys_tluplus/$METAL_STACK/tluplus.map"
