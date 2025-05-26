
# Libs
# set paths(ARM_ROOT)
set paths(STANDARD_CELLS_RVT)...
lappend paths(LIB_paths) ""
set paths(STANDARD_CELLS_LVT)...
lappend paths(LIB_paths) ""
set paths(STANDARD_CELLS_HVT)...
lappend paths(LIB_paths) ""

# General
set tech(LIBRARY_HAS_ENDCAPS) ""
set tech(STANDARD_CELL_SITE) ..
set tech(STANDARD_CELL_VDD) 
set tech(STANDARD_CELL_GND)

# LEFS
lappend tech(LEF_SUPPRESS_MESSAGES_GENUS) {*}"PHYS-279 P"
lappend tech(LEF_SUPPRESS_MESSAGES_INNOVUS) {*}"IMPLF_20"
set tech_files(TECHNOLOGY_LEF) $paths(TECHNOLOGY_FILES)/..
    set tech_files(ALL_LEFS) [list $tech_files(TECHNOLOGY_LEF) ..]
set tech_files(STANDARD_CELLS_RVT_LEF) $paths(STANDARD_CELLS_RVT)
    lappend tech_files(ALL_LEFS) $tech_files(STANDARD_CELL..)
set tech_files(STANDARD_CELLS_LVT_LEF) $paths(STANDARD_CELLS_LVT)
    lappend tech_files(ALL_LEFS) $tech_files(STANDARD_CELL..)
set tech_files(STANDARD_CELLS_HVT_LEF) $paths(STANDARD_CELLS_HVT)
    lappend tech_files(ALL_LEFS) $tech_files(STANDARD_CELL..)

# Temperatures for Corners
set tech(TEMPERATURE_BC) -40
set tech(TEMPERATURE_TC) 25
set tech(TEMPERATURE_WC) 125

# Libs
lappend tech(LEF_SUPPRESS_MESSAGES_GENUS) {*}"PHYS-279 P"
lappend tech(LEF_SUPPRESS_MESSAGES_INNOVUS) {*}"IMPLF_20"

set tech_files(STANDARD_CELLS_RVT_BC_LIB) $paths(STANDARD)
    lappend tech_files(ALL_BC_LIBS) [list $tech_files(STANDARD)]
set tech_files(STANDARD_CELLS_RVT_WC_LIB) $paths(STANDARD)
    lappend tech_files(ALL_WC_LIBS) [list $tech_files(STANDARD)]
set tech_files(STANDARD_CELLS_RVT_TC_LIB) $paths(STANDARD)
    lappend tech_files(ALL_TC_LIBS) [list $tech_files(STANDARD)]

set tech_files(STANDARD_CELLS_LVT_BC_LIB) $paths(STANDARD)
    lappend tech_files(ALL_BC_LIBS) [list $tech_files(STANDARD)]
set tech_files(STANDARD_CELLS_LVT_WC_LIB) $paths(STANDARD)
    lappend tech_files(ALL_WC_LIBS) [list $tech_files(STANDARD)]
set tech_files(STANDARD_CELLS_LVT_TC_LIB) $paths(STANDARD)
    lappend tech_files(ALL_TC_LIBS) [list $tech_files(STANDARD)]

set tech_files(STANDARD_CELLS_HVT_BC_LIB) $paths(STANDARD)
    lappend tech_files(ALL_BC_LIBS) [list $tech_files(STANDARD)]
set tech_files(STANDARD_CELLS_HVT_WC_LIB) $paths(STANDARD)
    lappend tech_files(ALL_WC_LIBS) [list $tech_files(STANDARD)]
set tech_files(STANDARD_CELLS_HVT_TC_LIB) $paths(STANDARD)
    lappend tech_files(ALL_TC_LIBS) [list $tech_files(STANDARD)]
