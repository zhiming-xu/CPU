library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

-- The PC is a register which can be loaded with one of four values
-- chosen from a mux: PC+1, immediate, PC + immediate, or s-reg.
-- The pcsel line controls the mux.
-- (c) 2015 Warren Toomey, GPL3 licence
entity prog_cntr is
    generic (DATA_WIDTH :integer := 16);
    port (
        PCLOAD: in std_logic;	-- Load the mux into the PC register
        RESET:  in std_logic;	-- Reset the PC back to value 0
        PCSEL:  in std_logic_vector(1 downto 0); -- Mux select value
        
        -- Data inputs from elsewhere in the CPU and the PC output
        IMVAL:   in std_logic_vector(DATA_WIDTH-1 downto 0);
        SREGVAL: in std_logic_vector(DATA_WIDTH-1 downto 0);
        PCOUT:   out std_logic_vector(DATA_WIDTH-1 downto 0);
        
        -- The system clock
        CLK: in std_logic);
end prog_cntr;

architecture behaviour of prog_cntr is
    -- We need a 16-bit register
    component reg is
        generic (DATA_WIDTH :integer := DATA_WIDTH);
        port (
            CLK    : in  std_logic;
            LD     : in  std_logic;
            D_IN   : in  std_logic_vector(DATA_WIDTH-1 downto 0);
            D_OUT  : out std_logic_vector(DATA_WIDTH-1 downto 0));
    end component;
    
    -- 4-way Multiplexer output
    signal mux_out: std_logic_vector(DATA_WIDTH-1 downto 0);
    
    -- This line holds the multiplexer output, or 0 on reset
    signal reset_out: std_logic_vector(DATA_WIDTH-1 downto 0);
    
    -- We always load the PC when reset is enabled
    signal reset_load: std_logic;
    
    -- Internal PC output line
    signal pc_out: std_logic_vector(DATA_WIDTH-1 downto 0);
    
begin
    pcreg: reg port map(D_IN => reset_out,

    D_OUT => pc_out,
    LD => reset_load,
    CLK => CLK);
    
    -- Work out what mux value goes into the PC register
    with (PCSEL) select
      mux_out <= std_logic_vector(unsigned(pc_out) + 1)    when "00",
      std_logic_vector(unsigned(IMVAL)) 		   when "01",
      std_logic_vector(unsigned(pc_out) + unsigned(IMVAL)) when "10",
      std_logic_vector(unsigned(SREGVAL)) 		   when "11",
      x"0000" 						   when others;
    
    -- But if the reset line is enabled, always put 0 into the PC
    with (RESET) select
      reset_out <= x"0000" when '1',
      		   mux_out when others;
    
    -- We always load the PC when reset is enabled
    with (RESET) select
      reset_load <= '1'    when '1',
      		    PCLOAD when others;
    
    PCOUT <= pc_out;
end;

library ieee;
use ieee.std_logic_1164.all;

entity prog_cntr_test is
end prog_cntr_test;

architecture behaviour of prog_cntr_test is
    component prog_cntr is port (
            PCLOAD: in std_logic;
            RESET: in std_logic;
            PCSEL: in std_logic_vector(1 downto 0);
            IMVAL: in std_logic_vector(15 downto 0);
            SREGVAL: in std_logic_vector(15 downto 0);
            PCOUT: out std_logic_vector(15 downto 0);
            CLK: in std_logic);
    end component;
    
    signal clock: std_logic;
    signal load : std_logic;
    signal reset: std_logic;
    signal immed: std_logic_vector(15 downto 0);
    signal sreg : std_logic_vector(15 downto 0);
    signal pcsel: std_logic_vector(1 downto 0);
    signal pcout: std_logic_vector(15 downto 0);
    
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
    uut: prog_cntr port map (
        CLK => clock,
        PCLOAD => load,
        RESET => reset,
        PCSEL => pcsel,
        IMVAL => immed,
        SREGVAL => sreg,
        PCOUT => pcout
      );
    
    --- Stimulation process
    stim_proc: process
    begin
        -- Load x10 into the PC
        reset <= '0';
        immed <= x"0010";
        load <= '1'; 
        pcsel <= "01"; 
        wait for clock_period;
        -- assert data_out = x"003f" report "load x3f failed";
        
        -- Try to increment the PC
        load <= '1'; 
        pcsel <= "00"; 
        wait for clock_period;
        
        -- Set the PC to the s-register
        sreg <= x"3000";
        load <= '1'; 
        pcsel <= "11"; 
        wait for clock_period;
        
        -- Increment the PC again
        load <= '1'; 
        pcsel <= "00"; 
        wait for clock_period;
        
        -- And do PC + immed
        load <= '1'; 
        pcsel <= "10"; 
        wait for clock_period;
        
        -- Leave the PC unaltered, value should not change
        load <= '0'; 
        wait for clock_period;
        
        -- Reset the PC, it should go back to zero
        reset <= '1';
        load <= '1'; 
        wait for clock_period;
        
        -- Reload the PC from the s-reg
        reset <= '0';
        sreg <= x"3000";
        load <= '1'; 
        pcsel <= "11"; 
        wait for clock_period;
        
        -- This time, reset the PC to zero even when load is off
        reset <= '1';
        load <= '0'; 
        wait for clock_period;
        
        load <= '0'; 
        wait for clock_period;
        report "prog_cntr test finished" severity failure;
    end process;
end;
