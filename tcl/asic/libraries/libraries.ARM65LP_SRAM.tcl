# These are the technology definitions for the
#       for the TSMC 65nm LP Technology
#

# Library/LEF setting for ARM memories
set tech(SRAM_MUX) [ list "M32" "M16"]
set tech(SRAM_SIZE) [ list "16384" "16384"]
set tech(SRAM_FLAVOR) [ list "hde" "hde"]
foreach M $tech(SRAM_MUX) S $tech(SRAM_SIZE) F $tech(SRAM_FLAVOR) {
    set m [string tolower $M]
    set path_name "../mem_gen?SP_${S}X32/${M}/
    set inst_name "sp_${F}_${S}_${m}"
    lappend tech_files(ALL_LEFS) "${path_name}"
    lappend tech_files(ALL_WC_LIBS) "${path_name}"
    lappend tech_files(ALL_TC_LIBS) "${path_name}"
    lappend tech_files(ALL_BC_LIBS) "${path_name}"
    #lappend design(hdl_search_paths) "$design"
}

lappend tech(LIB_SUPPRESS_MESSAGES_GENUS) {*}""
lappend tech(LIB_SUPPRESS_MESSAGES_GENUS) {*}""