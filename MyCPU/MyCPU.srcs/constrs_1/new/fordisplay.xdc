#100MHz clock
set_property PACKAGE_PIN E3 [get_ports clkin]							
set_property IOSTANDARD LVCMOS33 [get_ports clkin]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clkin]

#CPU reset
set_property PACKAGE_PIN C12 [get_ports reset]				
set_property IOSTANDARD LVCMOS33 [get_ports reset]

#CPU halt
set_property PACKAGE_PIN K5 [get_ports hlt]
set_property IOSTANDARD LVCMOS33 [get_ports hlt]
#CPU run
set_property PACKAGE_PIN F6 [get_ports run]
set_property IOSTANDARD LVCMOS33 [get_ports run]
#switches, which program
set_property PACKAGE_PIN R7 [get_ports {sw[0]}]					
set_property IOSTANDARD LVCMOS33 [get_ports {sw[0]}]
set_property PACKAGE_PIN R6 [get_ports {sw[1]}]					
set_property IOSTANDARD LVCMOS33 [get_ports {sw[1]}]
#clock speed
set_property PACKAGE_PIN R3 [get_ports {clkcon[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {clkcon[0]}]
#Bank = 34, Pin name = IO_25_34,							Sch name = SW1
set_property PACKAGE_PIN P3 [get_ports {clkcon[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {clkcon[1]}]
set_property PACKAGE_PIN P4 [get_ports {clkcon[2]}]					
        set_property IOSTANDARD LVCMOS33 [get_ports {clkcon[2]}]
#Audio
set_property PACKAGE_PIN A11 [get_ports AUD_PWM]					
        set_property IOSTANDARD LVCMOS33 [get_ports AUD_PWM]
    #Bank = 15, Pin name = IO_L6P_T0_15,                        Sch name = AUD_SD
    set_property PACKAGE_PIN D12 [get_ports AUD_SD]                        
        set_property IOSTANDARD LVCMOS33 [get_ports AUD_SD]
#LEDs
#Bank = 34, Pin name = IO_L24N_T3_34,						Sch name = LED0
set_property PACKAGE_PIN T8 [get_ports {led[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {led[0]}]
#Bank = 34, Pin name = IO_L21N_T3_DQS_34,					Sch name = LED1
set_property PACKAGE_PIN V9 [get_ports {led[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {led[1]}]
#Bank = 34, Pin name = IO_L24P_T3_34,						Sch name = LED2
set_property PACKAGE_PIN R8 [get_ports {led[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {led[2]}]
#Bank = 34, Pin name = IO_L23N_T3_34,						Sch name = LED3
set_property PACKAGE_PIN T6 [get_ports {led[3]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {led[3]}]
#Bank = 34, Pin name = IO_L12P_T1_MRCC_34,					Sch name = LED4
set_property PACKAGE_PIN T5 [get_ports {led[4]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {led[4]}]
#Bank = 34, Pin name = IO_L12N_T1_MRCC_34,					Sch	name = LED5
set_property PACKAGE_PIN T4 [get_ports {led[5]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {led[5]}]
#Bank = 34, Pin name = IO_L22P_T3_34,						Sch name = LED6
set_property PACKAGE_PIN U7 [get_ports {led[6]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {led[6]}]
#Bank = 34, Pin name = IO_L22N_T3_34,						Sch name = LED7
set_property PACKAGE_PIN U6 [get_ports {led[7]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {led[7]}]
#Bank = 34, Pin name = IO_L10N_T1_34,						Sch name = LED8
set_property PACKAGE_PIN V4 [get_ports {led[8]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {led[8]}]
#Bank = 34, Pin name = IO_L8N_T1_34,						Sch name = LED9
set_property PACKAGE_PIN U3 [get_ports {led[9]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {led[9]}]
#Bank = 34, Pin name = IO_L7N_T1_34,						Sch name = LED10
set_property PACKAGE_PIN V1 [get_ports {led[10]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {led[10]}]
#Bank = 34, Pin name = IO_L17P_T2_34,						Sch name = LED11
set_property PACKAGE_PIN R1 [get_ports {led[11]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {led[11]}]
#Bank = 34, Pin name = IO_L13N_T2_MRCC_34,					Sch name = LED12
set_property PACKAGE_PIN P5 [get_ports {led[12]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {led[12]}]
#Bank = 34, Pin name = IO_L7P_T1_34,						Sch name = LED13
set_property PACKAGE_PIN U1 [get_ports {led[13]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {led[13]}]
#Bank = 34, Pin name = IO_L15N_T2_DQS_34,					Sch name = LED14
set_property PACKAGE_PIN R2 [get_ports {led[14]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {led[14]}]
#Bank = 34, Pin name = IO_L15P_T2_DQS_34,					Sch name = LED15
set_property PACKAGE_PIN P2 [get_ports {led[15]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {led[15]}]

#7-segment display
set_property PACKAGE_PIN L3 [get_ports {seg[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seg[0]}]
#Bank = 34, Pin name = IO_L3N_T0_DQS_34,					Sch name = CB
set_property PACKAGE_PIN N1 [get_ports {seg[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seg[1]}]
#Bank = 34, Pin name = IO_L6N_T0_VREF_34,					Sch name = CC
set_property PACKAGE_PIN L5 [get_ports {seg[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seg[2]}]
#Bank = 34, Pin name = IO_L5N_T0_34,						Sch name = CD
set_property PACKAGE_PIN L4 [get_ports {seg[3]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seg[3]}]
#Bank = 34, Pin name = IO_L2P_T0_34,						Sch name = CE
set_property PACKAGE_PIN K3 [get_ports {seg[4]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seg[4]}]
#Bank = 34, Pin name = IO_L4N_T0_34,						Sch name = CF
set_property PACKAGE_PIN M2 [get_ports {seg[5]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seg[5]}]
#Bank = 34, Pin name = IO_L6P_T0_34,						Sch name = CG
set_property PACKAGE_PIN L6 [get_ports {seg[6]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seg[6]}]
#Bank = 34, Pin name = IO_L18N_T2_34,						Sch name = AN0
    set_property PACKAGE_PIN N6 [get_ports {an[0]}]                    
        set_property IOSTANDARD LVCMOS33 [get_ports {an[0]}]
    #Bank = 34, Pin name = IO_L18P_T2_34,                        Sch name = AN1
    set_property PACKAGE_PIN M6 [get_ports {an[1]}]                    
        set_property IOSTANDARD LVCMOS33 [get_ports {an[1]}]
    #Bank = 34, Pin name = IO_L4P_T0_34,                        Sch name = AN2
    set_property PACKAGE_PIN M3 [get_ports {an[2]}]                    
        set_property IOSTANDARD LVCMOS33 [get_ports {an[2]}]
    #Bank = 34, Pin name = IO_L13_T2_MRCC_34,                    Sch name = AN3
    set_property PACKAGE_PIN N5 [get_ports {an[3]}]                    
        set_property IOSTANDARD LVCMOS33 [get_ports {an[3]}]
    #Bank = 34, Pin name = IO_L3P_T0_DQS_34,                    Sch name = AN4
    set_property PACKAGE_PIN N2 [get_ports {an[4]}]                    
        set_property IOSTANDARD LVCMOS33 [get_ports {an[4]}]
    #Bank = 34, Pin name = IO_L16N_T2_34,                        Sch name = AN5
    set_property PACKAGE_PIN N4 [get_ports {an[5]}]                    
        set_property IOSTANDARD LVCMOS33 [get_ports {an[5]}]
    #Bank = 34, Pin name = IO_L1P_T0_34,                        Sch name = AN6
    set_property PACKAGE_PIN L1 [get_ports {an[6]}]                    
        set_property IOSTANDARD LVCMOS33 [get_ports {an[6]}]
    #Bank = 34, Pin name = IO_L1N_T034,                            Sch name = AN7
    set_property PACKAGE_PIN M1 [get_ports {an[7]}]                    
        set_property IOSTANDARD LVCMOS33 [get_ports {an[7]}]
