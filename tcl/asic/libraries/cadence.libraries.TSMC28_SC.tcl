# Set Paths for Timing Libs
set paths(PDK_ROOT) "$HOME/PDK"
set paths(LIB_paths) "$PDK_ROOT/STD_Libs/lib"

# General
set tech(LIBRARY_HAS_ENDCAPS) "YES"
set tech(STANDARD_CELL_SITE) ..
set tech(STANDARD_CELL_VDD) 
set tech(STANDARD_CELL_GND)

# Libs
set tech_files(STANDARD_CELLS_RVT_BC_LIB) "$paths(LIB_Paths)/"
    set tech_files(ALL_BC_LIBS) [list $tech_files(STANDARD_CELLS_RVT_BC_LIB)]
set tech_files(STANDARD_CELLS_RVT_WC_LIB) "$paths(LIB_Paths)/"
    set tech_files(ALL_WC_LIBS) [list $tech_files(STANDARD_CELLS_RVT_WC_LIB)]
set tech_files(STANDARD_CELLS_RVT_TC_LIB) "$paths(LIB_Paths)/"
    set tech_files(ALL_TC_LIBS) [list $tech_files(STANDARD_CELLS_RVT_TC_LIB)]

set tech_files(STANDARD_CELLS_LVT_BC_LIB) "$paths(LIB_Paths)/"
    lappend tech_files(ALL_BC_LIBS) [list $tech_files(STANDARD_CELLS_LVT_BC_LIB)]
set tech_files(STANDARD_CELLS_LVT_WC_LIB) "$paths(LIB_Paths)/"
    lappend tech_files(ALL_WC_LIBS) [list $tech_files(STANDARD_CELLS_LVT_WC_LIB)]
set tech_files(STANDARD_CELLS_LVT_TC_LIB) "$paths(LIB_Paths)/"
    lappend tech_files(ALL_TC_LIBS) [list $tech_files(STANDARD_CELLS_LVT_TC_LIB)]

set tech_files(STANDARD_CELLS_HVT_BC_LIB) "$paths(LIB_Paths)/"
    lappend tech_files(ALL_BC_LIBS) [list $tech_files(STANDARD_CELLS_HVT_BC_LIB)]
set tech_files(STANDARD_CELLS_HVT_WC_LIB) "$paths(LIB_Paths)/"
    lappend tech_files(ALL_WC_LIBS) [list $tech_files(STANDARD_CELLS_HVT_WC_LIB)]
set tech_files(STANDARD_CELLS_HVT_TC_LIB) "$paths(LIB_Paths)/"
    lappend tech_files(ALL_TC_LIBS) [list $tech_files(STANDARD_CELLS_HVT_TC_LIB)]
