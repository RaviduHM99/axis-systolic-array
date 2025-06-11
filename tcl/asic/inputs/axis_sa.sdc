#################################
#       Clock Constraints       #
#################################
# Create Clocks
create_clock -period $design(clock_period_list) -name $design(clock_list) 
set_clock_uncertainty $design(CLOCK_UNCERTAINTY) $design(clock_list)


set_ideal_network [get_ports $design(clock_port_list)]
set_ideal_network [get_ports $design(RST_PORT)]


#################################
#       IO Constraints          #
#################################
set_input_delay -clock CLK 0.5 \
        [remove_from_collection [all_inputs] clk]
set_output_delay -clock CLK 0.5 [all_outputs]


set tech(SDC_LOAD_VALUE) [lindex [get_db [get_lib_pins BUF_X0P5B_A9PP140ZTUL_C35/Q] .capacitance] 0]


set_load                $tech(SDC_LOAD_VALUE)                      [all_outputs]
set_input_transition    $design(INPUT_TRANSITION)                  [all_inputs]
set_driving_cell        -lib_cell $tech(SDC_DRIVING_CELL)          [all_inputs]




