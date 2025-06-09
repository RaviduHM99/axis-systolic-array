# Route Technology settings for the TSMC 28 HPCPLUS Technology
set METAL_STACK  
set TRACKS       9
set TECH_NODE    28

# Technology
set paths(TECHNOLOGY_FILES) "$PDK_ROOT/TECH_Libs"
set paths(STANDARD_CELLS_TECH_FILES) "$PDK_ROOT/STD_Libs/lef"

# LEFS
lappend tech(LEF_SUPPRESS_MESSAGES_GENUS) {*}"PHYS-279"
lappend tech(LEF_SUPPRESS_MESSAGES_INNOVUS) {*}"IMPLF_20"

set tech_files(TECHNOLOGY_LEF) "$paths(TECHNOLOGY_FILES)/tech_lef"
    set tech_files(ALL_LEFS) [list $tech_files(TECHNOLOGY_LEF)]
set tech_files(STANDARD_CELLS_LEF) $paths(STANDARD_CELLS_TECH_FILES)
    lappend tech_files(ALL_LEFS) $tech_files(STANDARD_CELLS_LEF)

# Temperatures for Corners
set tech(TEMPERATURE_BC) -40
set tech(TEMPERATURE_TC) 25
set tech(TEMPERATURE_WC) 125

# Parasitic Extraction
set tech_files(CAPTABLE_BC) "$paths(TECHNOLOGY_FILES)/captabl/"
set tech_files(CAPTABLE_TC) "$paths(TECHNOLOGY_FILES)/captabl/"
set tech_files(CAPTABLE_WC) "$paths(TECHNOLOGY_FILES)/captabl/"
