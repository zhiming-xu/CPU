set_property PACKAGE_PIN E3 [get_ports clk]							
	set_property IOSTANDARD LVCMOS33 [get_ports clk]
	create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]

set_property PACKAGE_PIN A11 [get_ports AUD_PWM]					
	set_property IOSTANDARD LVCMOS33 [get_ports AUD_PWM]
##Bank = 15, Pin name = IO_L6P_T0_15,						Sch name = AUD_SD
set_property PACKAGE_PIN D12 [get_ports AUD_SD]						
	set_property IOSTANDARD LVCMOS33 [get_ports AUD_SD]

set_property PACKAGE_PIN U2 [get_ports {enable}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {enable}]
#Bank = 34, Pin name = IO_L11N_T1_MRCC_34,					Sch name = SW11
set_property PACKAGE_PIN T3 [get_ports {port[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {port[0]}]
#Bank = 34, Pin name = IO_L17N_T2_34,						Sch name = SW12
set_property PACKAGE_PIN T1 [get_ports {port[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {port[1]}]
#Bank = 34, Pin name = IO_L11P_T1_SRCC_34,					Sch name = SW13
set_property PACKAGE_PIN R3 [get_ports {port[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {port[2]}]
#Bank = 34, Pin name = IO_L14N_T2_SRCC_34,					Sch name = SW14
set_property PACKAGE_PIN P3 [get_ports {port[3]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {port[3]}]
#Bank = 34, Pin name = IO_L14P_T2_SRCC_34,					Sch name = SW15
set_property PACKAGE_PIN P4 [get_ports {port[4]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {port[4]}]
set_property PACKAGE_PIN V2 [get_ports {amp}]					
        set_property IOSTANDARD LVCMOS33 [get_ports {amp}]