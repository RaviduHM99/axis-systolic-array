# Library definitions for TSMC 65LP IO Libraries

set tech_files(IO_NAME) tpdn65lpnv2od3
set IO_METAL_STACK 9lm

set paths(IO_dir) $paths(PDK_ROOT)/dig_libs/
set paths(IO_libs) $paths(IO_dir)/Front_End/
set paths(IO_lefs) $paths(IO_dir)/Back_End/lef

# Libs
set tech_files(IO_WC_LIB) $paths(IO_libs)/$tech_files
        lappend tech_files(ALL_WC_LIBS) $tech_files
set tech_files(IO_TC_LIB) $paths(IO_libs)/$tech_files
        lappend tech_files(ALL_TC_LIBS) $tech_files
set tech_files(IO_BC_LIB) $paths(IO_libs)/$tech_files
        lappend tech_files(ALL_BC_LIBS) $tech_files
lappend tech(LIB_SUPPRESS_MESSAGES_GENUS) {*}
lappend tech(LIB_SUPPRESS_MESSAGES_INNOVUS) {*}

# Verilog
set tech_files(IO_VERILOG) $paths(IO_dir)/Front
# LEF