---------------------------------------------------------------------
-- This is the top-level Vivado file for the implementation of
-- Warren's microcoded CPU on the Nexys4 DDR development board.
-- This file contains the interface to the I/O devices on the board
-- and the code that abstracts these devices for the CPU.
--
-- Strictly speaking, the CPU only needs the Nexys4 CLK and UART
-- devices. But these other I/O devices are also used:
--	o The 7-segment LEDs display the address and data bus values in hex
--	o The 16 LEDs display the instruction register
--	o The red CPU reset button is exactly that: a reset button
--	o The right pushbutton cycles the CPU clock line. When the
--	o Slide switch 15 (left-most) stops the clock when raised. The right
--	  pushbutton then cycles the clock manually.
--	o When (only) one of the slide switches 14 .. 10 is raised, the clock
--	  frequency is set to 1 Hz, 2 Hz, 4 Hz, 10 Hz or 20 Hz.
--
-- (c) 2015 Warren Toomey, GPL3 licence
---------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity nexys4 is
    -- These are the I/O lines we use from the board. Only the
    -- CLK and UART_TXD lines are essential.
    port (CLK: 	      in std_logic;
	  CPU_RESETN: in std_logic;
	  BTN:        in std_logic_vector(4 downto 0);
          SW:  	      in std_logic_vector(15 downto 0);
          UART_RXD:   in  std_logic;
          LED:        out std_logic_vector(15 downto 0);
          SSEG_CA:    out std_logic_vector(7 downto 0);
          SSEG_AN:    out std_logic_vector(7 downto 0);
	  RGB1_Red:   out std_logic;
	  RGB1_Green: out std_logic;
	  RGB2_Red:   out std_logic;
	  RGB2_Green: out std_logic;
	  RGB2_Blue:  out std_logic;
          UART_TXD:   out std_logic
    );
end entity;

architecture behaviour of nexys4 is
    -- The CPU is independent of the FPGA board
    component cpu
        generic (ADDR_WIDTH :    integer := 16;
                 DATA_WIDTH :    integer := 16
        );
        port ( SYS_CLK: in  std_logic;
           RESET:       in  std_logic;
           UART_STATUS: in  std_logic_vector(2 downto 0);
           UART_RDDATA: in  std_logic_vector(7 downto 0);
           UART_WRDATA: out std_logic_vector(7 downto 0);
           UART_CTRL:   out std_logic_vector(1 downto 0);
           ADDRBUS:     out std_logic_vector (ADDR_WIDTH-1 downto 0);
           DATABUS:     out std_logic_vector (DATA_WIDTH-1 downto 0);
           INST_REG:    out std_logic_vector (DATA_WIDTH-1 downto 0);
           STATUS:      out std_logic_vector(3 downto 0)
        );
    end component;

    -- The UART component simulates a 9600 bps serial port
    component UART_TX_CTRL
	port(SEND:    in std_logic;
             DATA:    in std_logic_vector(7 downto 0);
             CLK:     in std_logic;          
             READY:   out std_logic;
             UART_TX: out std_logic
        );
    end component;

    component UART_RX_CTRL is
        port(UART_RX:    in   STD_LOGIC;
             CLK:        in   STD_LOGIC;
             DATA:       out  STD_LOGIC_VECTOR (7 downto 0);
             READ_DATA:  out  STD_LOGIC;
             RESET_READ: in   STD_LOGIC
        );
    end component;

    -- The debouncer turns the unpredictable pushbutton
    -- presses into clean pushbutton presses
    component debouncer
	generic(DEBNC_CLOCKS: integer;
        	PORT_WIDTH  : integer
	);
	port(SIGNAL_I: in std_logic_vector(5 downto 0);
             CLK_I: in std_logic;          
             SIGNAL_O: out std_logic_vector(5 downto 0)
        );
    end component;

    -- These are the signals that we send into the CPU
    signal sys_clk: 	std_logic := '0';		-- CPU's clock
    signal reset:	std_logic;			-- Reset line
    signal uart_status: std_logic_vector(2 downto 0);	-- Uart status lines

    -- These are the signals that come out of the CPU
    signal addr_bus:  std_logic_vector(15 downto 0);
    signal data_bus:  std_logic_vector(15 downto 0);
    signal inst_reg:  std_logic_vector (15 downto 0);
    signal status:    std_logic_vector(3 downto 0);
    signal uart_ctrl: std_logic_vector(1 downto 0);

    -- Internal signals
    -- Raw and debounced buttons, including the reset button
    signal raw_btn: std_logic_vector(5 downto 0);
    signal deb_btn: std_logic_vector(5 downto 0);

    -- UART transmitter signals
    signal uart_ready: std_logic;	-- The UART is ready to send a character
    signal uart_send: std_logic;	-- Fast UART write strobe
    signal uart_data: std_logic_vector(7 downto 0);	-- Data to send on UART
    signal slow_uart_send: std_logic;			-- UART write strobe

    -- UART receiver signals
    signal uart_recv_data: std_logic_vector(7 downto 0); -- Data received
    signal uart_data_available: std_logic;		-- Data is available
    signal uart_data_reset: std_logic;			-- We received it

    -- A 4-bit value to be displayed as hex on a 7-segment LED
    signal hex_value: std_logic_vector(3 downto 0);

    -- Which of the 7-segment LEDs we are displaying now
    signal anode: std_logic_vector(2 downto 0):= "000";

    -- A clock to strobe the 7-segment LED anodes and a counter for it
    signal led_clk: std_logic := '0';
    signal sseg_counter: integer := 0;

    -- Signals and constants used to divide the 100MHz clock
    -- How much we divide the 100MHz Nexys4 clock by.
    -- Because our clock is 50% duty cycle, leave the
    -- /2 on the end so we get two halves of the cycle
    signal DIVIDE_RATIO: integer := 100/2;

    -- Counter to count CLKs. We toggle clock when it hits DIVIDE_RATIO
    signal clk_counter: integer := 0;
begin
    -- Instantiation of the CPU
    the_cpu: cpu
    port map( SYS_CLK => sys_clk,
           RESET => reset,
           UART_STATUS => uart_status,
           UART_RDDATA => uart_recv_data,
           UART_WRDATA => uart_data,
           UART_CTRL => uart_ctrl,
	   ADDRBUS => addr_bus,
	   DATABUS => data_bus,
	   INST_REG => inst_reg,
	   STATUS => status
    );

    -- Instantiation of the button debouncer
    inst_btn_debounce: debouncer 
	generic map(
            DEBNC_CLOCKS => (2**16),
            PORT_WIDTH => 6)
	port map(
            SIGNAL_I => raw_btn,
            CLK_I => CLK,
            SIGNAL_O => deb_btn
        );

    -- Instantiation of the UART transmit component
    inst_UART_TX_CTRL: UART_TX_CTRL
	port map(
            SEND => uart_send,
            DATA => uart_data,
            CLK => CLK,
            READY => uart_ready,
            UART_TX => UART_TXD
        );

    inst_UART_RX_CTRL: UART_RX_CTRL
        port map (
	    UART_RX => UART_RXD,
            CLK => CLK,
            DATA => uart_recv_data,
            READ_DATA => uart_data_available,
            RESET_READ => uart_data_reset
        );

    -- Signal mappings
    -- The individual LEDs are easy: connected to the IR register
    LED <= inst_reg;

    -- Map the raw pushbuttons and the reset button.
    -- The debounced reset line goes into the CPU
    -- The reset button is active low, so we need a not()
    raw_btn <= CPU_RESETN & BTN;
    reset <= not(deb_btn(5));

    -- At present we don't have an empty UART line, just lines
    -- for data available, and ready to transmit
    uart_status <= uart_data_available & uart_ready & '0';

    -- The UART control lines: reset the receive signal, and
    -- tell the UART to send a byte of data
    uart_data_reset <= uart_ctrl(1);
    slow_uart_send <= uart_ctrl(0);

    -- The slow_uart_send line from the CPU stays high too long, especially
    -- when the sys_clk is slowed down or single stepped. This process
    -- generates a single clock pulse on uart_send. Borrowed from 
    -- http://stackoverflow.com/questions/
    -- 20174889/one-clock-period-pulse-based-on-trigger-signal
    uart_send_pulse: process(clk)
       variable idle : boolean := true;	-- True if we are not sending a pulse
    begin
       if rising_edge(clk) then
          uart_send <= '0';        -- default action
          if (idle) then
             if (slow_uart_send = '1') then
                uart_send <= '1';  -- overrides default FOR THIS CYCLE ONLY
                idle := false;
             end if;
          else
             if (slow_uart_send = '0') then
                idle := true;
             end if;
          end if;
      end if;
    end process;


    -- The code to divide the Nexys4 100MHz clock into a slower clock
    -- but only when SW(15) is off. Done by decrementing the counter.
    -- Also, single-step the sys_clk when SW(15) is on and BTN(3) is pressed
    clock_divide_process: process(CLK, SW(15), deb_btn(2))
        begin
	    if (SW(15) = '0') then
                if (rising_edge(CLK)) then
                    if (clk_counter = 0) then
                        clk_counter <= DIVIDE_RATIO;
                        -- Toggle sys_clk each time clk_counter resets
                        sys_clk <= not(sys_clk);
                    else
                        clk_counter <= clk_counter - 1;
                    end if;
                end if;
	    else
                if (rising_edge(deb_btn(2))) then
            	    sys_clk <= not(sys_clk);
	        end if;
	    end if;
        end process;

    -- Choose the clock dividing ratio based on the switches
    ratio_choice_process: process(SW(14 downto 9))
	begin
	    case SW(14 downto 9) is
		when "100000" => DIVIDE_RATIO <= 100000000;	-- 1 Hz
		when "010000" => DIVIDE_RATIO <=  50000000;	-- 2 Hz
		when "001000" => DIVIDE_RATIO <=  25000000;	-- 4 Hz
		when "000100" => DIVIDE_RATIO <=  10000000;	-- 10 Hz
		when "000010" => DIVIDE_RATIO <=   5000000;	-- 20 Hz
		when "000001" => DIVIDE_RATIO <=   2000000;	-- 50 Hz
		when others  => DIVIDE_RATIO <=        100;  	-- 1 MHz
	    end case;
        end process;


    -- The code to display the address and data bus values on the 7-seg LEDs
    -- We also need a slow running clock to strobe the anodes, so yet
    -- another process to generate this clock
    sseg_clock_process: process(CLK)
        begin
            if (rising_edge(CLK)) then
                if (sseg_counter = 0) then
                    sseg_counter <= 10000;
                    -- Toggle led_clk each time counter resets
                    led_clk <= not(led_clk);
                else
                    sseg_counter <= sseg_counter - 1;
                end if;
            end if;
        end process;


    -- Combinatorial code: convert a 4-bit value into a 7-segment value
    with hex_value select
	SSEG_CA <= "11000000" when "0000",	-- 0
                   "11111001" when "0001",	-- 1
                   "10100100" when "0010",	-- 2
                   "10110000" when "0011",	-- 3
                   "10011001" when "0100",	-- 4
                   "10010010" when "0101",	-- 5
                   "10000010" when "0110",	-- 6
                   "11111000" when "0111",	-- 7
                   "10000000" when "1000",	-- 8
                   "10010000" when "1001",	-- 9
                   "10001000" when "1010",	-- A
                   "10000011" when "1011",	-- B
                   "11000110" when "1100",	-- C
                   "10100001" when "1101",	-- D
                   "10000110" when "1110",	-- E
                   "10001110" when "1111",	-- F
                   "11111111" when others;

    -- Drive each anode in turn low based on the anode number
    with anode select
	SSEG_AN <= "11111110" when "000",	-- 0
                   "11111101" when "001",	-- 1
                   "11111011" when "010",	-- 2
                   "11110111" when "011",	-- 3
                   "11101111" when "100",	-- 4
                   "11011111" when "101",	-- 5
                   "10111111" when "110",	-- 6
                   "01111111" when "111",	-- 7
                   "11111111" when others;

    -- Multiplex data onto the hex_value lines and choose an anode,
    -- cycling through each one as the clock ticks. We also use
    -- this to send the sys_clk to the left tricolor LED.
    seven_segment_process: process(led_clk)
        begin
            if (rising_edge(led_clk)) then
		case anode is 
		    when "000" =>
		    	anode <= "001";
		    	hex_value <= data_bus(7 downto 4);
			RGB1_Red <= status(3);		-- Datawrite
			RGB1_Green <= sys_clk;
			RGB2_Red <= status(0);		-- Carry
			RGB2_Green <= status(2);	-- Zero
			RGB2_Blue <= status(1);		-- Negative
		    when "001" =>
		    	anode <= "010";
		    	hex_value <= data_bus(11 downto 8);
			RGB1_Red <= '0';
			RGB1_Green <= '0';
			RGB2_Red <= '0';
			RGB2_Green <= '0';
			RGB2_Blue <= '0';
		    when "010" =>
		    	anode <= "011";
		    	hex_value <= data_bus(15 downto 12);
			RGB1_Red <= '0';
			RGB1_Green <= '0';
			RGB1_Red <= '0';
			RGB2_Red <= '0';
			RGB2_Green <= '0';
			RGB2_Blue <= '0';
		    when "011" =>
		    	anode <= "100";
		    	hex_value <= addr_bus(3 downto 0);
			RGB1_Red <= '0';
			RGB1_Green <= '0';
			RGB2_Red <= '0';
			RGB2_Green <= '0';
			RGB2_Blue <= '0';
		    when "100" =>
		    	anode <= "101";
		    	hex_value <= addr_bus(7 downto 4);
			RGB1_Red <= '0';
			RGB1_Green <= '0';
			RGB2_Red <= '0';
			RGB2_Green <= '0';
			RGB2_Blue <= '0';
		    when "101" =>
		    	anode <= "110";
		    	hex_value <= addr_bus(11 downto 8);
			RGB1_Red <= '0';
			RGB1_Green <= '0';
			RGB2_Red <= '0';
			RGB2_Green <= '0';
			RGB2_Blue <= '0';
		    when "110" =>
		    	anode <= "111";
		    	hex_value <= addr_bus(15 downto 12);
			RGB1_Red <= '0';
			RGB1_Green <= '0';
			RGB2_Red <= '0';
			RGB2_Green <= '0';
			RGB2_Blue <= '0';
		    when others =>
		    	anode <= "000";
		    	hex_value <= data_bus(3 downto 0);
			RGB1_Red <= '0';
			RGB1_Green <= '0';
			RGB2_Red <= '0';
			RGB2_Green <= '0';
			RGB2_Blue <= '0';
            	end case;
            end if;
        end process;
end architecture;
