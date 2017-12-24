library ieee;
use ieee.std_logic_1164.all;

-- A set of registers, known as a register file
-- (c) 2015 Warren Toomey, GPL3 licence
entity regfile is
    generic (DATA_WIDTH :integer := 16);
    port (
        -- Active high write lines for three registers
        DWRITE: in std_logic;
        SWRITE: in std_logic;
        TWRITE: in std_logic;
        
        -- Which register is the d-, s- and t-register
        DSEL: in std_logic_vector(2 downto 0);
        SSEL: in std_logic_vector(2 downto 0);
        TSEL: in std_logic_vector(2 downto 0);
        
        -- The new value to write to the register(s)
        REGVAL: in std_logic_vector(DATA_WIDTH-1 downto 0);
        
        -- The output values of the d-, s- and t-registers
        DREG: out std_logic_vector(DATA_WIDTH-1 downto 0);
        SREG: out std_logic_vector(DATA_WIDTH-1 downto 0);
        TREG: out std_logic_vector(DATA_WIDTH-1 downto 0);
        
        -- The system clock
        CLK: in std_logic);
end regfile;

architecture behaviour of regfile is
    -- We need some registers
    component reg is
        generic (DATA_WIDTH :integer := DATA_WIDTH);
        port (
            CLK    : in  std_logic;
            LD     : in  std_logic;
            D_IN   : in  std_logic_vector(DATA_WIDTH-1 downto 0);
            D_OUT  : out std_logic_vector(DATA_WIDTH-1 downto 0));
    end component;
    
    -- Register outputs
    signal r0_out: std_logic_vector(DATA_WIDTH-1 downto 0);
    signal r1_out: std_logic_vector(DATA_WIDTH-1 downto 0);
    signal r2_out: std_logic_vector(DATA_WIDTH-1 downto 0);
    signal r3_out: std_logic_vector(DATA_WIDTH-1 downto 0);
    signal r4_out: std_logic_vector(DATA_WIDTH-1 downto 0);
    signal r5_out: std_logic_vector(DATA_WIDTH-1 downto 0);
    signal r6_out: std_logic_vector(DATA_WIDTH-1 downto 0);
    signal r7_out: std_logic_vector(DATA_WIDTH-1 downto 0);
    
    -- Register load bundle and load bundles from the demuxers
    signal reg_load: std_logic_vector(7 downto 0);
    signal d_load: std_logic_vector(7 downto 0);
    signal s_load: std_logic_vector(7 downto 0);
    signal t_load: std_logic_vector(7 downto 0);
    
begin
    r0: reg port map(D_IN => REGVAL,
        D_OUT => r0_out,
        LD => reg_load(0),
        CLK => CLK);
    r1: reg port map(D_IN => REGVAL,
        D_OUT => r1_out,
        LD => reg_load(1),
        CLK => CLK);
    r2: reg port map(D_IN => REGVAL,
        D_OUT => r2_out,
        LD => reg_load(2),
        CLK => CLK);
    r3: reg port map(D_IN => REGVAL,
        D_OUT => r3_out,
        LD => reg_load(3),
        CLK => CLK);
    r4: reg port map(D_IN => REGVAL,
        D_OUT => r4_out,
        LD => reg_load(4),
        CLK => CLK);
    r5: reg port map(D_IN => REGVAL,
        D_OUT => r5_out,
        LD => reg_load(5),
        CLK => CLK);
    r6: reg port map(D_IN => REGVAL,
        D_OUT => r6_out,
        LD => reg_load(6),
        CLK => CLK);
    r7: reg port map(D_IN => REGVAL,
        D_OUT => r7_out,
        LD => reg_load(7),
        CLK => CLK);
    
    -- Multiplex the register outputs
    DREG <= r0_out when DSEL = "000" else
    	    r1_out when DSEL = "001" else
    	    r2_out when DSEL = "010" else
    	    r3_out when DSEL = "011" else
    	    r4_out when DSEL = "100" else
    	    r5_out when DSEL = "101" else
    	    r6_out when DSEL = "110" else
    	    r7_out when DSEL = "111" else
	    (others => '0');

    SREG <= r0_out when SSEL = "000" else
    	    r1_out when SSEL = "001" else
    	    r2_out when SSEL = "010" else
    	    r3_out when SSEL = "011" else
    	    r4_out when SSEL = "100" else
    	    r5_out when SSEL = "101" else
    	    r6_out when SSEL = "110" else
    	    r7_out when SSEL = "111" else
	    (others => '0');

    TREG <= r0_out when TSEL = "000" else
    	    r1_out when TSEL = "001" else
    	    r2_out when TSEL = "010" else
    	    r3_out when TSEL = "011" else
    	    r4_out when TSEL = "100" else
    	    r5_out when TSEL = "101" else
    	    r6_out when TSEL = "110" else
    	    r7_out when TSEL = "111" else
	    (others => '0');

    -- Demultiplex the write lines
    d_load(0) <= DWRITE when DSEL = "000" else '0';
    d_load(1) <= DWRITE when DSEL = "001" else '0';
    d_load(2) <= DWRITE when DSEL = "010" else '0';
    d_load(3) <= DWRITE when DSEL = "011" else '0';
    d_load(4) <= DWRITE when DSEL = "100" else '0';
    d_load(5) <= DWRITE when DSEL = "101" else '0';
    d_load(6) <= DWRITE when DSEL = "110" else '0';
    d_load(7) <= DWRITE when DSEL = "111" else '0';

    s_load(0) <= SWRITE when SSEL = "000" else '0';
    s_load(1) <= SWRITE when SSEL = "001" else '0';
    s_load(2) <= SWRITE when SSEL = "010" else '0';
    s_load(3) <= SWRITE when SSEL = "011" else '0';
    s_load(4) <= SWRITE when SSEL = "100" else '0';
    s_load(5) <= SWRITE when SSEL = "101" else '0';
    s_load(6) <= SWRITE when SSEL = "110" else '0';
    s_load(7) <= SWRITE when SSEL = "111" else '0';

    t_load(0) <= TWRITE when TSEL = "000" else '0';
    t_load(1) <= TWRITE when TSEL = "001" else '0';
    t_load(2) <= TWRITE when TSEL = "010" else '0';
    t_load(3) <= TWRITE when TSEL = "011" else '0';
    t_load(4) <= TWRITE when TSEL = "100" else '0';
    t_load(5) <= TWRITE when TSEL = "101" else '0';
    t_load(6) <= TWRITE when TSEL = "110" else '0';
    t_load(7) <= TWRITE when TSEL = "111" else '0';

    -- Because we can select the same internal register both d-, s- and/or -t,
    -- we can't have dwrite=1 and swrite=0 when they refer to the same register.
    -- To solve this, any write to a register overrides a non-write. We use OR
    -- gates to implement this.
    reg_load(0) <= d_load(0) OR s_load(0) OR t_load(0);
    reg_load(1) <= d_load(1) OR s_load(1) OR t_load(1);
    reg_load(2) <= d_load(2) OR s_load(2) OR t_load(2);
    reg_load(3) <= d_load(3) OR s_load(3) OR t_load(3);
    reg_load(4) <= d_load(4) OR s_load(4) OR t_load(4);
    reg_load(5) <= d_load(5) OR s_load(5) OR t_load(5);
    reg_load(6) <= d_load(6) OR s_load(6) OR t_load(6);
    reg_load(7) <= d_load(7) OR s_load(7) OR t_load(7);
end;

library ieee;
use ieee.std_logic_1164.all;

entity regfile_test is
    generic (DATA_WIDTH :integer := 16);
end regfile_test;

architecture behaviour of regfile_test is
    component regfile is port(
        -- Active high write lines for three registers
        DWRITE: in std_logic;
        SWRITE: in std_logic;
        TWRITE: in std_logic;
            
        -- Which register is the d-, s- and t-register
        DSEL: in std_logic_vector(2 downto 0);
        SSEL: in std_logic_vector(2 downto 0);
        TSEL: in std_logic_vector(2 downto 0);
            
        -- The new value to write to the register(s)
        REGVAL: in std_logic_vector(DATA_WIDTH-1 downto 0);
            
        -- The output values of the d-, s- and t-registers
        DREG: out std_logic_vector(DATA_WIDTH-1 downto 0);
        SREG: out std_logic_vector(DATA_WIDTH-1 downto 0);
        TREG: out std_logic_vector(DATA_WIDTH-1 downto 0);
            
        -- The system clock
        CLK: in std_logic);
    end component;
    
    signal dwrite,swrite,twrite: std_logic;
    signal dsel, ssel, tsel: std_logic_vector(2 downto 0);
    signal regval: std_logic_vector(DATA_WIDTH-1 downto 0);
    signal dreg, sreg, treg: std_logic_vector(DATA_WIDTH-1 downto 0);
    signal clock    : std_logic;
    
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
    uut: regfile port map (
        DWRITE => dwrite,
        SWRITE => swrite,
        TWRITE => twrite,
        DSEL => dsel,
        SSEL => ssel,
        TSEL => tsel,
        REGVAL => regval,
        DREG => dreg,
        SREG => sreg,
        TREG => treg,
        CLK => clock
      );
    
    --- Stimulation process
    stim_proc: process
    begin
        -- Try to write x"0011" to register 1 as sreg
        dwrite <= '0';
        swrite <= '1';
        twrite <= '0';
        ssel <= "001";
        regval <= x"0011";
        wait for clock_period;
        assert sreg = x"0011" report "sreg 1 write x11 failed";
        
        -- Try to write x"0022" to register 2 as sreg
        dwrite <= '0';
        swrite <= '1';
        twrite <= '0';
        ssel <= "010";
        regval <= x"0022";
        wait for clock_period;
        assert sreg = x"0022" report "sreg 2 write x22 failed";
        
        -- Try to write x"0033" to register 3 as sreg
        dwrite <= '0';
        swrite <= '1';
        twrite <= '0';
        ssel <= "011";
        regval <= x"0033";
        wait for clock_period;
        assert sreg = x"0033" report "sreg 3 write x33 failed";
        
        -- Try to write x"0044" to register 4 as sreg
        dwrite <= '0';
        swrite <= '1';
        twrite <= '0';
        ssel <= "100";
        regval <= x"0044";
        wait for clock_period;
        assert sreg = x"0044" report "sreg 4 write x44 failed";
        
        -- Try to write x"0055" to register 5 as sreg
        dwrite <= '0';
        swrite <= '1';
        twrite <= '0';
        ssel <= "101";
        regval <= x"0055";
        wait for clock_period;
        assert sreg = x"0055" report "sreg 5 write x55 failed";
        
        -- Try to write x"0066" to register 6 as sreg
        dwrite <= '0';
        swrite <= '1';
        twrite <= '0';
        ssel <= "110";
        regval <= x"0066";
        wait for clock_period;
        assert sreg = x"0066" report "sreg 6 write x66 failed";
        
        -- Try to write x"0077" to register 7 as sreg
        dwrite <= '0';
        swrite <= '1';
        twrite <= '0';
        ssel <= "111";
        regval <= x"0077";
        wait for clock_period;
        assert sreg = x"0077" report "sreg 7 write x77 failed";
        
        -- Try to write x"0014" to register 1 as dreg
        dwrite <= '1';
        swrite <= '0';
        twrite <= '0';
        dsel <= "001";
        regval <= x"0014";
        wait for clock_period;
        assert dreg = x"0014" report "dreg 1 write x14 failed";
        
        -- Try to write x"0028" to register 2 as treg
        dwrite <= '0';
        swrite <= '0';
        twrite <= '1';
        tsel <= "010";
        regval <= x"0028";
        wait for clock_period;
        assert treg = x"0028" report "dreg 2 write x28 failed";
        
        -- One last thing, check we can read back old values
        dwrite <= '0';
        swrite <= '0';
        twrite <= '0';
        dsel <= "100";
        ssel <= "101";
        tsel <= "110";
        wait for clock_period;
        assert dreg = x"0044" report "dreg 4 read x44 failed";
        assert sreg = x"0055" report "sreg 5 read x55 failed";
        assert treg = x"0066" report "treg 6 read x66 failed";
        
        wait for clock_period;
        report "regfile test finished" severity failure;
    end process;
end;
