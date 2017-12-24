library ieee;
use ieee.std_logic_1164.all;

-- Register with an active high load enable
-- that operates on the rising edge of the clock.
-- From "Free Range VHDL".
entity reg is
    generic (DATA_WIDTH :    integer := 16);
    port (
        CLK    : in  std_logic;
        LD     : in  std_logic;
        D_IN   : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        D_OUT  : out std_logic_vector(DATA_WIDTH-1 downto 0):= (others => '0'));
end;

architecture behaviour of reg is
begin
    process (CLK)
    begin
        if (rising_edge(CLK)) then
            if (LD = '1') then
                D_OUT <= D_IN;
            end if;
        end if;
    end process;
end;

library ieee;
use ieee.std_logic_1164.all;

entity reg_test is
    generic (DATA_WIDTH :integer := 16);
end reg_test;

architecture behaviour of reg_test is
    component reg is
        generic (DATA_WIDTH :    integer := 16);
        port (
            CLK    : in  std_logic;
            LD     : in  std_logic;
            D_IN   : in  std_logic_vector(DATA_WIDTH-1 downto 0);
            D_OUT  : out std_logic_vector(DATA_WIDTH-1 downto 0));
    end component;
    
    signal clock    : std_logic;
    signal load     : std_logic;
    signal data_in  : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal data_out : std_logic_vector(DATA_WIDTH-1 downto 0);
    
    -- Clock period definitions
    constant clock_period : time := 10 ns;
    
begin
    -- Clock process definitions: clock with 50% duty cycle is generated here.
    clock_process: process
    begin
        clock <= '0';
        wait for clock_period/2;  --for 5 ns signal is '0'.
        clock <= '1';
        wait for clock_period/2;  --for next 5 ns signal is '1'.
    end process;
    
    -- Unit under test port map
    uut: reg
      generic map ( DATA_WIDTH => 16)
      port map (
        CLK => clock,
        LD => load,
        D_IN => data_in,
        D_OUT => data_out
      );
    
    --- Stimulation process
    stim_proc: process
    begin
        load <= '1'; data_in <= x"003f"; wait for clock_period;
        assert data_out = x"003f" report "load x3f failed";
        
        load <= '1'; data_in <= x"2020"; wait for clock_period;
        assert data_out = x"2020" report "load 20 failed";
        
        wait for clock_period;
        report "reg test finished" severity failure;
    end process;
end;
