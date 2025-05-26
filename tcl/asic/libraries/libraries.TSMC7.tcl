# Technology settings for the TSMC 65LP Technology
#   Note that standard cell library setting....
#   to support various standard cell libraries....
#

set METAL_STACK
set TRACKS
set_db design

set paths(PDK_ROOT)

# Technology
set paths()
set paths(TECHNOLOGY_FILES)

# Parasitic Extraction
set tech_files(CAPTABLE_BC) $paths(TECHNOLOGY_FILES)
set tech_files(CAPTABLE_TC) $paths(TECHNOLOGY)
set tech_files(CAPTABLE_WC) $paths(TECHNOLOGY)
set paths(QRC_ROOT) $paths(PDK_ROOT)/QRC/1.3a/
set tech_files(QRCTECH_FILE_TYPICAL) $paths(QRC_ROOT)
set tech_files(QRCTECH_FILE_CBEST) $paths(QRC_ROOT)
set tech_files(QRCTECH_FILE_CWORST) $paths(QRC_ROOT)