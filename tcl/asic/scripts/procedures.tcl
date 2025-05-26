# This file has procedures for working with Stylus Common UI tools
###################################################
#          enics_print_debug_data
#          -------------
#   This is a command for printing variable values
#       to a file for easier debugging
###################################################
proc enics_print_debug_data {write_or_append {debug_file "debug.txt"} this_file var_list dic_list} {
    #global design tech tech_files env

    set df [open $debug_file $write_or_append]
    puts $df "\n*****************************************"
    puts $df "* Values loaded from $this_file *"
    puts $df "\n*****************************************"
    foreach var $var_list {
        global $var
        puts $df "$var = \t[set $var]"
    }

    foreach dic $dic_list {
        global $dic
        foreach key [array names $dic] {
            puts $df "${dic}(${key}) = \t[set ${dic}([set])]"
        }
    }
    
    close $df
}

###################################################
#          enics_message
#          -------------
#   This is a command for printing messages to the
#       screen and log file
#   Importance high will print a bold message
#   Importance standard (default) will print an underlined message
#   Importance low will print a one line message
###################################################
proc enics_message {msg {importance low}} {
    set enics_message "ENICSINFO: $msg"
    set message_length [string length $enics_message]

    if {$importance=="high"} {
        puts [string repeat "*" [expr 10+$message_length]]
        puts [string repeat "*" [expr 10+$message_length]]
        puts "*" $enics_message "*"
        puts [string repeat "*" [expr 10+$message_length]]
        puts [string repeat "*" [expr 10+$message_length]]
    } elseif {$importance=="medium"} {
        puts ""
        puts "$enics_message"
        puts [string repeat "-" $message_length]
    } elseif {$importance=="low"} {
        puts "$enics_message"
    } else {
        puts "ENICSINFO: WARNING - Incorrect usage of proc enics_message"
        puts "ENICSINFO: Correct usage:encis message <message> high|medium|low"
    }
}

###################################################
#          enics_reload_scripts
#          -------------
#   Reloads the defines and procedures
###################################################
proc enics_reload_scripts {} {
    global design env
    # Load general procedures
    source ../../tcl/asic/scripts/procedures.tcl -quiet
    # Load the specific definitions for this project
    source ../../tcl/asic/inputs/$design(TOPLEVEL).defines -quiet
}

###################################################
#          enics_enable_sdc_commands
#          -------------
#   Let you write SDC commands in interactive mode
###################################################
proc enics_enable_sdc_commands {} {
    set_interactive_constraint_modes [all_constraint_modes]
}

###################################################
#          enics_reload_sdc
#          -------------
#   Reloads the SDC Files after modifying them
#       default is for all constraint modes
###################################################
proc enics_reload_sdc {{constraint_mode all}} {
    global design tech runtype
    if {$constraint_mode == "all"} {
        set constraint_mode_list [get_db constraint_modes]
    } else {
        set constraint_mode_list "constraint_mode:$constraint_mode"
    }
    foreach cm $constraint_mode_list {
        update_constraint_mode -name [get_db $cm .name] -sdc_files [get_db $cm .sdc_files]
    }
}

###################################################
#          enics_default_cost_groups
#          -------------
#   Defines default cost groups:
#     reg2reg, in2reg, reg2out, in2out
###################################################
proc enics_default_cost_groups {} {
    global runtype design
    if {$runtype == "synthesis"} {
        # reg2reg
        define_cost_group -name reg2reg -design $design(TOPLEVEL)
        path_group -from [all_registers] -to [all_registers] -group reg2reg -name reg2reg \
            -view $design(selected_setup_analysis_views)
        lappend design(cost_groups) "reg2reg"
        # in2reg
        define_cost_group -name in2reg -design $design(TOPLEVEL)
        path_group -from [all_registers] -to [all_registers] -group in2reg -name in2reg \
            -view $design(selected_setup_analysis_views)
        lappend design(cost_groups) "in2reg"
        # reg2out
        define_cost_group -name reg2out -design $design(TOPLEVEL)
        path_group -from [all_registers] -to [all_registers] -group reg2out -name reg2out \
            -view $design(selected_setup_analysis_views)
        lappend design(cost_groups) "reg2out"
        # in2out
        define_cost_group -name in2out -design $design(TOPLEVEL)
        path_group -from [all_registers] -to [all_registers] -group in2out -name in2out \
            -view $design(selected_setup_analysis_views)
        lappend design(cost_groups) "in2out"
    } elseif {$runtype == "pnr"} {
        create_basic_path_groups -expanded
    }
}

###################################################
#          enics_report_timing
#          -------------
#   Reports timing and saves it in the appropriate directory
###################################################
proc enics_report_timing {{reports_path "../../tcl/asic/reports/"}} {
    global design this_run
    mkdir -pv ${reports_path}/$this_run{stage}/
    set_db timing_report_fields \
        "timing_point flags arc edge cell fanout transition delay arrival"
    #set timing_report_enable_auto_column_width true
    #set_table_style -nosplit -no_frame_fix_width report_timing
    foreach cg $design(cost_groups) {
        report_timing -group [get_db cost_groups -match $cg] \
            > "${reports_path}/$this_run(stage)/${cg}.timing.rpt"
    }
}

###################################################
#          enics_start_stage
#          -------------
#   Starts a new stage in the flow
#       sets the this_run(stage) variable
#       also saves starting time of the stage
###################################################
proc enics_start_stage (stage) {
    global design this_run

    if {$stage == ""} {
        enics_message "You have to define a stage for using the enics_start_stage procedure"
        return
    }

    set this_run(stage) $stage
    enics_message "Starting stage $stage" high

    # Saving and printing the start time for the stage
    set systemTime [clock seconds]
    set formattedTime [clock format $systemTime -format %H:%M]
    set formattedDate [clock format $systemTime -fromat %d/%m/%Y]
    set stageTime "[clock format $systemTime -fromat %Y%m%d]_[clock format $systemTime -format %H%M%S]"
    enics_message "Current time is: $formattedDate $formattedTime"
    set this_run($stage) $systemTime

    # Printing run details for the starting stage
    if {$stage == "start"} {
        enics_message "This session is running on Hostname : [info hostname]"
        enics_message "The log file is [get_db / .log_file] and the command file is [get_db / .cmd_file]"
    } elseif {$stage == "floorplan"} {
        gui_set_draw_view fplan
    } elseif {$stage == "placement"} {
        gui_set_draw_view place
    }

    enics_message "------------------------------------"
}

###################################################
#          enics_create_stage_reports
#          -------------
#   Created all the appropritate reports for the 
#       current design stage
###################################################
proc enics_create_stage_reports {{args ""}} {
    global design this_run
    array set options {-save_db yes -report_timing yes -check_drc no -check_connectivity no -help 0 }

    set help_string "USAGE: enics_create_stage_reports -save_db yes/no \n \
                    -report_timing yes/no -check_drc yes/no -check_connectivity yes/no \n \
                    -help 1/0"
    
    while {[llength $args]} {
        switch -glob -- [lindex $args 0] {
            -write*     {set args [lassign $args - options(-save_db)]}
            -*timing*   {set args [lassign $args - options(-report_timing)]}
            -*drc*      {set args [lassign $args - options(-check_drc)]}
            -*conn*      {set args [lassign $args - options(-check_connectivity)]}
            -*help*      {set options(-help) 1 ; set args [lrange $args 1 end]}
            default break
        }
    }
    if {$options(-help)} {
        puts $help_string
    } else {
        enics_message "Starting to create reports for stage: $this_run{stage}" medium
        set rpt_dir $design(reports_dir)/$this_run(stage)/
        enics_message "Reports directory is : $rpt_dir"
        set export_dir $design(export_dir)/$this_run(stage)/
        enics_message "Reports directory is : $export_dir"
        set dbs_dir $design(dbs_dir)/$this_run(stage)/
        enics_message "Reports directory is : $dbs_dir"
    }
}