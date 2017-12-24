---------------------------------------------------------------------
-- Testing code for the top-level Vivado file.
--
-- (c) 2015 Warren Toomey, GPL3 licence
---------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
entity nexys4_test is
end nexys4_test;

architecture behaviour of nexys4_test is
    component nexys4 is
       port (CLK: in std_logic;
	  CPU_RESETN: in std_logic;
	  BTN:        in std_logic_vector(4 downto 0);
          SW:  	      in std_logic_vector(15 downto 0);
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
    end component;

    signal clk: std_logic;
    signal cpu_resetn: std_logic;
    signal btn:        std_logic_vector(4 downto 0);
    signal sw:         std_logic_vector(15 downto 0);
    signal led:        std_logic_vector(15 downto 0);
    signal sseg_ca:    std_logic_vector(7 downto 0);
    signal sseg_an:    std_logic_vector(7 downto 0);
    signal rgb1_red:   std_logic;
    signal rgb1_green: std_logic;
    signal rgb2_red:   std_logic;
    signal rgb2_green: std_logic;
    signal rgb2_blue:  std_logic;
    signal uart_txd:   std_logic;

    -- Clock period definitions
    constant clock_period : time := 10 ns;

begin
    -- Clock process definitions: clock with 50% duty cycle is generated here.
    clock_process: process
    begin
        clk <= '0';
        wait for clock_period/2;  --for 5 ns signal is '0'.
        clk <= '1';
        wait for clock_period/2;  --for next 5 ns signal is '1'.
    end process;
    
    -- Unit under test port map
    uut: nexys4 port map (
    	CLK => clk,
        CPU_RESETN => cpu_resetn,
        BTN => btn,
        SW => sw,
        LED => led,
        SSEG_CA =>sseg_ca,
        SSEG_AN => sseg_an,
        RGB1_Red =>   rgb1_red,
        RGB1_Green => rgb1_green,
        RGB2_Red =>   rgb2_red,
        RGB2_Green => rgb2_green,
        RGB2_Blue =>  rgb2_blue,
        UART_TXD => uart_txd
     );

    --- Stimulation process
    stim_proc: process
    begin
	-- Start with everything turned off
	cpu_resetn <= '0';
	btn <= (others => '0');
	sw <= (others => '0');

  	wait for clock_period * 20000;
	report "nexys4 test finished" severity failure;
	wait;
    end process;
end;
