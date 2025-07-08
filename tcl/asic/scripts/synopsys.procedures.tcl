# This file has procedures for working with Stylus Common UI tools
###################################################
#          uom_print_debug_data
#          -------------
#   This is a command for printing variable values
#       to a file for easier debugging
###################################################
proc uom_print_debug_data {write_or_append {debug_file "debug.txt"} this_file var_list dic_list} {
    #global design tech tech_files env

    set df [open $debug_file $write_or_append]
    puts $df "*************************************************************"
    puts $df "* Values loaded from $debug_file $this_file *"
    puts $df "*************************************************************"
    foreach var $var_list {
        global $var
        puts $df "$var = \t[set $var]"
    }

    foreach dic $dic_list {
        global $dic
        foreach key [array names $dic] {
        	puts $df "${dic}(${key}) = \t [set ${dic}([set key])]"  
        }
    }
    
    close $df
}

###################################################
#          uom_message
#          -------------
#   This is a command for printing messages to the
#       screen and log file
#   Importance high will print a bold message
#   Importance standard (default) will print an underlined message
#   Importance low will print a one line message
###################################################
proc uom_message {msg {importance low}} {
    set uom_message "uomINFO: $msg"
    set message_length [string length $uom_message]

    if {$importance=="high"} {
        puts [string repeat "*" [expr 10+$message_length]]
        puts [string repeat "*" [expr 10+$message_length]]
        puts "* $uom_message *"
        puts [string repeat "*" [expr 10+$message_length]]
        puts [string repeat "*" [expr 10+$message_length]]
    } elseif {$importance=="medium"} {
        puts ""
        puts "$uom_message"
        puts [string repeat "-" $message_length]
    } elseif {$importance=="low"} {
        puts "$uom_message"
    } else {
        puts "uomINFO: WARNING - Incorrect usage of proc uom_message"
        puts "uomINFO: Correct usage:encis message <message> high|medium|low"
    }
}

###################################################
#          uom_reload_scripts
#          -------------
#   Reloads the defines and procedures
###################################################
proc uom_reload_scripts {} {
    global design env
    # Load general procedures
    source ../../tcl/asic/scripts/procedures.tcl -quiet
    # Load the specific definitions for this project
    source ../../tcl/asic/inputs/$design(TOPLEVEL).defines -quiet
}

###################################################
#          uom_default_cost_groups
#          -------------
#   Defines default cost groups:
#     reg2reg, in2reg, reg2out, in2out
###################################################
proc uom_default_cost_groups {} {
    global runtype design
    # reg2reg
    group_path -from [all_registers] -to [all_registers] -weight 50 -name reg2reg
    # in2reg
    path_group -from [all_inputs] -to [all_registers] -weight 20 -name in2reg 
    # reg2out
    path_group -from [all_registers] -to [all_outputs] -weight 30 -name reg2out
    # in2out
    path_group -from [all_inputs] -to [all_outputs] -weight 5 -name in2out

    lappend design(cost_groups) "reg2reg"
    lappend design(cost_groups) "in2reg"
    lappend design(cost_groups) "reg2out"
    lappend design(cost_groups) "in2out"
}

###################################################
#          uom_start_stage
#          -------------
#   Starts a new stage in the flow
#       sets the this_run(stage) variable
#       also saves starting time of the stage
###################################################
proc uom_start_stage {stage} {
    global design this_run

    if {$stage == ""} {
        uom_message "You have to define a stage for using the uom_start_stage procedure"
        return
    }

    set this_run(stage) $stage
    uom_message "Starting stage $stage" high

    # Saving and printing the start time for the stage
    set systemTime [clock seconds]
    set formattedTime [clock format $systemTime -format %H:%M]
    set formattedDate [clock format $systemTime -format %d/%m/%Y]
    set stageTime "[clock format $systemTime -format %Y%m%d]_[clock format $systemTime -format %H%M%S]"
    uom_message "Current time is: $formattedDate $formattedTime"
    set this_run($stage) $systemTime

    # Printing run details for the starting stage
    if {$stage == "start"} {
        uom_message "This session is running on Hostname : [info hostname]"
        uom_message "The log file is [get_db / .log_file] and the command file is [get_db / .cmd_file]"
    } elseif {$stage == "floorplan"} {
        gui_set_draw_view fplan
    } elseif {$stage == "placement"} {
        gui_set_draw_view place
    }

    uom_message "------------------------------------"
}

###################################################
#          uom_report_timing
#          -------------
#   Reports timing and saves it in the 
#       appropriate directory
###################################################
proc uom_report_timing {{reports_path "../../tcl/asic/reports/cadence"}} {
    global design runtype this_run scenarios_list
    mkdir -pv ${reports_path}/$this_run(stage)/

    foreach scnrio $scenarios_list {
        foreach cg $design(cost_groups) {
            report_timing -max_paths 100 -group $cg -scenarios $scnrio\
                > "${reports_path}/$this_run(stage)/${cg}.${scnrio}.setup.timing.rpt"
        }
    }
}

###################################################
#          uom_report_hold_timing
#          -------------
#   Reports hold timing and saves it in the 
#       appropriate directory
###################################################
proc uom_report_hold_timing {{reports_path "../../tcl/asic/reports/cadence"}} {
    global design runtype this_run
    mkdir -pv ${reports_path}/$this_run(stage)/
    set_db timing_report_fields \
        "timing_point flags arc edge cell fanout transition delay arrival"
    #set timing_report_enable_auto_column_width true
    #set_table_style -nosplit -no_frame_fix_width report_timing
    foreach cg $design(cost_groups) {
        if {$runtype == "synthesis"} {
        report_timing -early -max_paths 100 -group [get_db cost_groups -match $cg] \
            > "${reports_path}/$this_run(stage)/${cg}.hold.timing.rpt"
        } elseif {$runtype == "pnr"} {
        report_timing -early -max_paths 100 -group $cg \
            > "${reports_path}/$this_run(stage)/${cg}.hold.timing.rpt"
        }
    }
}

###################################################
#          uom_create_stage_reports
#          -------------
#   Created all the appropritate reports for the 
#       current design stage
###################################################
proc uom_create_stage_reports {{args ""}} {
    global design this_run
    array set options {
        -write_db           yes 
        -report_timing      no 
        -report_hold        no
        -check_drc          no 
        -check_connectivity no  
        -help               0   }

    while {[llength $args]} {
        switch -glob -- [lindex $args 0] {
            -*write*     {set args [lassign $args - options(-write_db)]}
            -*timing*    {set args [lassign $args - options(-report_timing)]}
            -*hold*      {set args [lassign $args - options(-report_hold)]}
            -*drc*       {set args [lassign $args - options(-check_drc)]}
            -*conn*      {set args [lassign $args - options(-check_connectivity)]}
            -*help*      {set args [lassign $args - options(-help)]; set args [lrange $args 1 end]}
            default break
        }
    }

    uom_message "Starting to create reports for stage: $this_run(stage)" medium
    if { $options(-write_db) eq "yes" } {
        mkdir -pv $design(dbs_dir)/pnr
        set dbs_proc_dir $design(dbs_dir)/pnr/$this_run(stage).stylus.enc
        uom_message "Reports directory is : $dbs_proc_dir"
        write_db -common $dbs_proc_dir
    }

    if { $options(-report_timing) eq "yes" } {
        mkdir -pv $design(reports_dir)/pnr
        set rpt_proc_dir $design(reports_dir)/pnr
        uom_message "Reports directory is : $rpt_proc_dir" 
        uom_report_timing $rpt_proc_dir
    }

    if { $options(-report_hold) eq "yes" } {
        mkdir -pv $design(reports_dir)/pnr
        set rpt_proc_dir $design(reports_dir)/pnr
        uom_message "Reports directory is : $rpt_proc_dir" 
        uom_report_hold_timing $rpt_proc_dir
    }

    if { $options(-check_drc) eq "yes" } {
        mkdir -pv $design(reports_dir)/pnr/$this_run(stage)
        set rpt_proc_dir $design(reports_dir)/pnr/$this_run(stage)
        uom_message "Reports directory is : $rpt_proc_dir" 
        check_drc -out_file $rpt_proc_dir/drc_report.rpt
    }

    if { $options(-check_connectivity) eq "yes" } {
        mkdir -pv $design(reports_dir)/pnr/$this_run(stage)
        set rpt_proc_dir $design(reports_dir)/pnr/$this_run(stage)
        uom_message "Reports directory is : $rpt_proc_dir" 
        check_connectivity > $rpt_proc_dir/connectivity.rpt
    }

    if {$options(-help)} {
        help
    }
}

###################################################
#          uom_create_sdc_file
#          -------------
#   This is a command for create sdc file depends 
#       on synthesis or pnr
###################################################
proc uom_create_sdc_file {} {
    global design tech runtype

    set df [open $design(functional_sdc) "w"]

    puts $df "#################################"
    puts $df "#       Clock Constraints       #"
    puts $df "#################################"
    puts $df "# Create Clocks"
    if {$design(MULTI_CLOCK_DESIGN) == "yes"} {
        foreach cname $design(clock_list) cport $design(clock_port_list) cperiod $design(clock_period_list){
            puts $df "create_clock -period $cperiod -name $cname [get_ports $cport]"
            puts $df "set_clock_uncertainty \$design(CLOCK_UNCERTAINTY) $cname"
        }
    } else {
        puts $df "create_clock -period \$design(clock_period_list) -name \$design(clock_list) \[get_ports \$design(clock_port_list)]"
        puts $df "set_clock_uncertainty \$design(CLOCK_UNCERTAINTY) \$design(clock_list)"
    }
    
    puts $df "\n"

    if {$runtype == "synthesis"} {
        puts $df "set_ideal_network \[get_ports \$design(clock_port_list)]"
        puts $df "set_ideal_network \[get_ports \$design(RST_PORT)]"
    }
    puts $df "\n"

    puts $df "#################################"
    puts $df "#       IO Constraints          #"
    puts $df "#################################"
    puts $df "set_input_delay -clock \$design(CLK_NAME) \$design(INPUT_DELAY) \\"
    puts $df "        \[remove_from_collection \[all_inputs] \$design(CLK_PORT)]"
    puts $df "set_output_delay -clock \$design(CLK_NAME) \$design(OUTPUT_DELAY) \[all_outputs]"
    #puts $df "set_max_delay [expr $design(CLK_PERIOD)/2 + $design(INPUT_DELAY) + $design(OUTPUT_DELAY)] \\"
    #puts $df "        -from \[all_inputs] \\"
    #puts $df "        -to   \[all_outputs]"

    puts $df "\n"

    if {$design(FULLCHIP_OR_MACRO) == "FULLCHIP"} {
        puts $df "set tech(SDC_LOAD_VALUE) $tech(EXTERNAL_SDC_LOAD)"
    } else {
        puts $df "set tech(SDC_LOAD_VALUE) \[lindex \[get_db \[get_lib_pins \$tech(SDC_LOAD_PIN)] .capacitance] 0]"
    }
    puts $df "\n"

    puts $df "set_load                \$tech(SDC_LOAD_VALUE)                      \[all_outputs]"
    puts $df "set_input_transition    \$design(INPUT_TRANSITION)                  \[all_inputs]"
    puts $df "set_driving_cell        -lib_cell \$tech(SDC_DRIVING_CELL)          \[all_inputs]"

    puts $df "\n"

    #puts $df "#################################"
    #puts $df "#       DRV Constraints         #"
    #puts $df "#################################"
    #puts $df "# By default Lib Files includes these constraints"
    #puts $df "# -----------------------------------------------"
    #puts $df "set_max_fanout \$design(MAX_FANOUT)  \[current_design]"
    #puts $df "set_max_transition \$design(MAX_TRANSITION) \[current_design]"
    #puts $df "set_max_capacitance \$design(MAX_CAPACITANCE) \[current_design]"
    #puts $df "set_max_transition \$clk_leaf_skew -clock_path \[all_clocks]"
    #puts $df "set_max_capacitance \$clk_cap -clock_path \[all_clocks]"

    puts $df "\n"

    close $df
}