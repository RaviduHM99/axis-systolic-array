# This script run SDF backannotation with a GateLevel Netlist
# Specifically, the script:
#       1) Opens a waveform with all the signals of the
#       2) Opens a VCD database and dumps all signals into a VCD file
#       3) Opens a TCF database and dumps all signals into a TCF file
#       4) Runs the simulation
#   execute this script with the command:
#       simvision -input backannotation.tcl
#     or alternatively
#       xrun ../scripts/xrun.backannotation

set design(TOPLEVEL) "sm"
set debug_file "debug.xrun.txt"

# Read in the project definitions/variables
source ../inputs/$design(TOPLEVEL).defines

# Open a waveform and add the relevant signals to the waveform
set w [simvision waveform new]
simvision scope set $design(tb_name)
simvision waveform add -using "Waveform 1" -signals "$design(tb_name).$design(dut_name)" -depth 2

# Open a VCD database and start probing signals and dumping into it
database -open $design(vcd_file) -vcd 
probe -create "$design(tb_name).$design(dut_name)" -vcd -all -database $design(vcd_file) -depth 9
# The VCD probe will continue until the end of the simulation

# Create a TCF file with the dumptcf command
# The TCF file only collects data between the initial dumptcf and the dumptcf -end commands
#   dumptcf [-dumpwireasnet] [-flatformat] [-inctoggle] [-internal] \
#           [-output filename] [-overwrite] [-scope scope_identifier] [-verbose] \
#           -flatformat  -- makes flat output rather than hierarchical

simvision simcontrol run -time 1
#dumptcf -output $design(tcf_file) -scope "#$design(tb_name).$design(dut_name)" -overwrite -verbose

#dumptcf -end
simvision window geometry Console 1336x500+10+700
simvision window geometry "Design Browser 1" 1336x500+10+700
simvision window geometry "Waveform 1" 1336x400+10+25
simvision waveform xview limits 0 2000000ps

reset
puts "The simulation will run from $design(power_report_start_time) to $design(power_report_end_time) "
#run -time $design(power_report_end_time);
#run $design(power_report_end_time);
simvision simcontrol run -time $design(power_report_end_time)
#simvision exit