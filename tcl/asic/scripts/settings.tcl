###################################
# General Genus Settings
###################################
set_db source_verbose true ; #Sourcing files will be re.

# Attributes that only Genus understands...
if {$runtype == "synthesis"} {
    set_db information_level 9 ; # The log file will rep.
    set_db hdl_max_loop_limit 100000
    set_db max_cpus_per_server 50
    if {$design(HAS_SCAN) == "no"} {
        set_db use_scan_seqs_for_non_dft false
    }
    set_db retime_async_reset true
    set_db hdl_language v2001 -quiet
    set_db lp_insert_clock_gating false
    set_db detailed_sdc_messages true ; # helps read_sdc
}

###################################
# General Innovus Settings
###################################
if {$runtype == "pnr"} {

    ## Basic Settings
    ###########################
    set_multi_cpu_usage -local_cpu 50
    set_design_mode -process 28

    ## Timing Analysis Settings
    ###############################
    #set_db timing_analysis_aocv             true
    #set_db timing_enable_aocv_slack_based   true
    #set_db timing_aocv_analysis_mode        launch_capture; #{launch_capture | clock_only | separate_data}
    #set_db timing_extract_model_aocv_mode   graph_based
    #set_db timing_aocv_derate_mode          aocv_additive;  #{aocv_multiplicative | aocv_additive}

    ## Floorplan Settings
    ###############################
    set_db add_endcaps_right_edge    $tech(END_CAP_CELL)
    set_db add_endcaps_left_edge     $tech(END_CAP_CELL)
    set_db add_tieoffs_cells         "$tech(TIE_HIGH_CELL) $tech(TIE_LOW_CELL) "
    set_db add_tieoffs_prefix        $tech(TIE_PREFIX)
    set_db add_tieoffs_report_hports true
    set_db add_tieoffs_max_fanout    20
    set_db add_tieoffs_max_distance  250
    set_db add_fillers_cells         $tech(FILL_CELL)
    set_db add_fillers_check_drc     true
    set_db add_fillers_prefix        $tech(FILL_CELL_PREFIX)
    
    ## Global Placement Settings
    ###############################
    set_db place_global_place_io_pins false
    set_db place_detail_no_filler_without_implant true
    set_db place_detail_use_no_diffusion_one_site_filler true
    set_db opt_fix_fanout_load true; # Force optimization to correct max_fanout violations

    ## Clock Tree Synthesis Settings
    ##################################
    # set_db cts_target_max_transition_time_top   $clk_slew
    # set_db cts_target_max_transition_time_trunk $clk_slew
    # set_db cts_target_max_transition_time_leaf  $clk_slew

    # ## Routing Settings
    # ##################################
    # set_db route_design_details_auto_stop false
    # set_db route_design_concurrent_minimize_via_count_effort high
    # set_db route_design_strict_honor_route_rule wire
    # set_db route_design_with_via_in_pin "1:2"
    # set_db route_design_stripe_layer_range "$nonDPT_MinRouteLayer:$MaxRouteLayer"
    # set_db route_design_antenna_diode_insertion true
    # set_db route_design_antenna_cell_name $antenna_cell 
    # ### don't use pin as a jumper - make one contact
    # set_db route_design_allow_pin_as_feedthru false
    # ### don't taper to the output pin causing EM issues
    # set_db route_design_detail_no_taper_on_output_pin true

    # # Routing Rules
    # set tech(layer_names) [lrange [get_db layers .name] 0 9]
    # set tech(min_spacing_x) [lrange [get_db layers .min_spacing] 0]
    # set tech(min_width_x) [lrange [get_db layers .min_width] 0]
    # set tech(min_spacing_y) [lrange [get_db layers .min_spacing] 1]
    # set tech(min_width_y) [lrange [get_db layers .min_width] 1]
    # set tech(min_spacing_z) [lrange [get_db layers .min_spacing] 7]
    # set tech(min_width_z) [lrange [get_db layers .min_width] 7]
    # set tech(min_spacing_stripes) 0.25 ; # Comes from [dbGet head.layers.spacingTables]
    # create_route_rule -name 2w2s -width_multiplier {M1:M9 2} -spacing_multiplier {M1:M9 2}
    # # create_route_rule -width {Metal1 0.12 Metal2 0.14 Metal3 0.14  ....} \
    # #   -spacing {Metal1 0.12 .....}
    # create_route_type -name clkroute -route_rule 2w2s \
    #                   -bottom_preferred_layer $tech(cts_top_routing_layer_trunk) \
    #                   -top_preferred_layer $tech(cts_bottom_routing_layer_trunk)
    # set_db cts_route_type_trunk clkroute
    # set_db cts_route_type_leaf clkroute
    # set_db cts_route_type_top clkroute

    # set_db cts_buffer_cells $tech(CLOCK_BUFFERS)
    # set_db cts_clock_gating_cells $tech(CLOCK_GATES)
    # create_route_type -name leaf \
    #     -top_preferred_layer $tech(cts_top_routing_layer_leaf) \
    #     -bottom_preferred_layer $tech(cts_bottom_routing_layer_leaf)
    # create_route_type -name trunk \
    #     -top_preferred_layer $tech(cts_top_routing_layer_trunk) \
    #     -bottom_preferred_layer $tech(cts_bottom_routing_layer_trunk)
    # create_route_type -name top \
    #     -top_preferred_layer $tech(cts_top_routing_layer_top) \
    #     -bottom_preferred_layer $tech(cts_bottom_routing_layer_top)
}

###################################
# General Voltus Settings
###################################
if {$runtype == "power"} {}