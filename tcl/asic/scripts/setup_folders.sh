#!/bin/bash

# List of folder names
dbs_subfolders=("1_post_elaboration" "2_post_synth_ispatial" "2_post_synth_rtl_flow")
report_subfolders=("1_post_elaboration" "2_pre_synthesis" "3_technology_mapping_ispatial_flow" "4_post_syn_opt_ispatial_flow" "3_technology_mapping_rtl_flow" "4_post_syn_opt_rtl_flow" "5_synth_gls")

# Base directory where folders will be created (default is current directory)
base_path="$PWD"

# Create dbs folder
dbs_path="$base_path/../dbs"
if [ ! -d "$dbs_path" ]; then
    mkdir -p "$dbs_path"
    echo "Created folder: $dbs_path"
else
    echo "Folder already exists: $dbs_path"
    rm -r "$dbs_path"
    mkdir -p "$dbs_path"
    echo "Created removed old and created new folder: $dbs_path"
fi

dbs_path="$base_path/../dbs/synthesis"
if [ ! -d "$dbs_path" ]; then
    mkdir -p "$dbs_path"
    echo "Created folder: $dbs_path"
else
    echo "Folder already exists: $dbs_path"
    rm -r "$dbs_path"
    mkdir -p "$dbs_path"
    echo "Created removed old and created new folder: $dbs_path"
fi

for folder in "${dbs_subfolders[@]}"; do
    folder_path="$dbs_path/$folder"
    if [ ! -d "$folder_path" ]; then
        mkdir -p "$folder_path"
        echo "Created subfolder: $folder_path"
    else
        echo "Subfolder already exists: $folder_path"
    fi
done

# Create exports folder
export_path="$base_path/../exports"
if [ ! -d "$export_path" ]; then
    mkdir -p "$export_path"
    echo "Created folder: $export_path"
else
    echo "Folder already exists: $export_path"
    rm -r "$export_path"
    mkdir -p "$export_path"
    echo "Created removed old and created new folder: $export_path"
fi

# Create reports folder
report_path="$base_path/../reports"
if [ ! -d "$report_path" ]; then
    mkdir -p "$report_path"
    echo "Created folder: $report_path"
else
    echo "Folder already exists: $report_path"
    rm -r "$report_path"
    mkdir -p "$report_path"
    echo "Created removed old and created new folder: $report_path"
fi

report_syn_path="$base_path/../reports/synthesis"
if [ ! -d "$report_syn_path" ]; then
    mkdir -p "$report_syn_path"
    echo "Created folder: $report_syn_path"
else
    echo "Folder already exists: $report_syn_path"
    rm -r "$report_syn_path"
    mkdir -p "$report_syn_path"
    echo "Created removed old and created new folder: $report_syn_path"
fi

for folder in "${report_subfolders[@]}"; do
    folder_path="$report_syn_path/$folder"
    if [ ! -d "$folder_path" ]; then
        mkdir -p "$folder_path"
        echo "Created subfolder: $folder_path"
    else
        echo "Subfolder already exists: $folder_path"
    fi
done