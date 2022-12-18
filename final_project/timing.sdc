## Generated SDC file "lab7.sdc"

## Copyright (C) 1991-2014 Altera Corporation. All rights reserved.
## Your use of Altera Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Altera Program License 
## Subscription Agreement, the Altera Quartus II License Agreement,
## the Altera MegaCore Function License Agreement, or other 
## applicable license agreement, including, without limitation, 
## that your use is for the sole purpose of programming logic 
## devices manufactured by Altera and sold by Altera or its 
## authorized distributors.  Please refer to the applicable 
## agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus II"
## VERSION "Version 14.1.0 Build 186 12/03/2014 SJ Web Edition"

## DATE    "Sun Feb 15 03:20:54 2015"

##
## DEVICE  "EP4CE115F29C8"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {main_clk_50} -period 20.000 -waveform { 0.000 10.000 } [get_ports {CLOCK_50}]


#**************************************************************
# Create Generated Clock
#**************************************************************



#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************



#**************************************************************
# Set Input Delay
#**************************************************************

set_input_delay -add_delay -max -clock [get_clocks {main_clk_50}]  3.000 [get_ports {KEY[0]}]
set_input_delay -add_delay -min -clock [get_clocks {main_clk_50}]  2.000 [get_ports {KEY[0]}]
set_input_delay -add_delay -max -clock [get_clocks {main_clk_50}]  3.000 [get_ports {KEY[1]}]
set_input_delay -add_delay -min -clock [get_clocks {main_clk_50}]  2.000 [get_ports {KEY[1]}]
set_input_delay -add_delay -max -clock [get_clocks {main_clk_50}]  3.000 [get_ports {KEY[2]}]
set_input_delay -add_delay -min -clock [get_clocks {main_clk_50}]  2.000 [get_ports {KEY[2]}]
set_input_delay -add_delay -max -clock [get_clocks {main_clk_50}]  3.000 [get_ports {KEY[3]}]
set_input_delay -add_delay -min -clock [get_clocks {main_clk_50}]  2.000 [get_ports {KEY[3]}]


#**************************************************************
# Set Output Delay
#**************************************************************

set_output_delay -add_delay  -clock [get_clocks {main_clk_50}]  2.000 [get_ports {LEDG[0]}]
set_output_delay -add_delay  -clock [get_clocks {main_clk_50}]  2.000 [get_ports {LEDG[1]}]
set_output_delay -add_delay  -clock [get_clocks {main_clk_50}]  2.000 [get_ports {LEDG[2]}]
set_output_delay -add_delay  -clock [get_clocks {main_clk_50}]  2.000 [get_ports {LEDG[3]}]
set_output_delay -add_delay  -clock [get_clocks {main_clk_50}]  2.000 [get_ports {LEDG[4]}]
set_output_delay -add_delay  -clock [get_clocks {main_clk_50}]  2.000 [get_ports {LEDG[5]}]
set_output_delay -add_delay  -clock [get_clocks {main_clk_50}]  2.000 [get_ports {LEDG[6]}]
set_output_delay -add_delay  -clock [get_clocks {main_clk_50}]  2.000 [get_ports {LEDG[7]}]


#**************************************************************
# Set Clock Groups
#**************************************************************


#**************************************************************
# Set False Path
#**************************************************************

set_false_path -to [get_keepers {*altera_std_synchronizer:*|din_s1}]
set_false_path -from [get_ports {SW[7]}]
set_false_path -from [get_ports {SW[6]}]
set_false_path -from [get_ports {SW[5]}]
set_false_path -from [get_ports {SW[4]}]
set_false_path -from [get_ports {SW[3]}]
set_false_path -from [get_ports {SW[2]}]
set_false_path -from [get_ports {SW[1]}]
set_false_path -from [get_ports {SW[0]}]


#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

