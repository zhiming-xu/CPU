--------------------------------------------------------
-- The microcode logic for Warren's microcoded CPU
-- (c) 2015 Warren Toomey, GPL3 licence
--------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ulogic is
    generic (CONTROL_WIDTH :integer := 32; 	-- Width of the control ROM
        DECISION_WIDTH :integer := 16;		-- Width of the decision ROM
        ROM_SIZE :integer := 8			-- Size of ROM, 2^ROM_SIZE
      );
    port(CLK    : in  std_logic;
        CARRY   : in  std_logic;
        ZERO    : in  std_logic;
        NEGATIVE: in  std_logic;
        OPCODE  : in  std_logic_vector (6 downto 0);
        ALUOP   : out  std_logic_vector (3 downto 0);
        OP2SEL  : out  std_logic_vector (1 downto 0);
        DATAWRITE: out  std_logic;
        ADDRSEL : out  std_logic_vector (1 downto 0);
        PCSEL   : out  std_logic_vector (1 downto 0);
        PCLOAD  : out  std_logic;
        DWRITE  : out  std_logic;
        IRLOAD  : out  std_logic;
        IMLOAD  : out  std_logic;
        REGSRC  : out  std_logic_vector (1 downto 0);
        DATASEL : out  std_logic_vector (1 downto 0);
        SWRITE  : out  std_logic
      );
end entity;

architecture behaviour of ulogic is
    -- Internal signal lines
    signal thisrow: std_logic_vector (ROM_SIZE-1 downto 0)
					:= (others => '0');  -- Current row
    signal nextrow: std_logic_vector (ROM_SIZE-1 downto 0);  -- Next row
    signal ctrllines: std_logic_vector (CONTROL_WIDTH-1 downto 0);  -- All control lines
    signal jumplines: std_logic_vector (DECISION_WIDTH-1 downto 0);  -- Two jump values
    signal cond: std_logic_vector (1 downto 0);
    signal indexsel: std_logic;
    
    -- The jump value (left or right of decision ROM) is chosen by the jumpchoice line
    signal jumpvalue: std_logic_vector (ROM_SIZE-1 downto 0);
    signal jumpchoice: std_logic;
    
    -- The jump value derived from the opcode
    signal opcodejump: std_logic_vector (ROM_SIZE-1 downto 0);
    
    -- The Control ROM component
    component controlrom is
      port (clk: in std_logic;
        addr: in std_logic_vector(8-1 downto 0);
        data: out std_logic_vector(32-1 downto 0));
    end component;

    -- The Decision ROM component
    component decisionrom is
      port (clk: in std_logic;
        addr: in std_logic_vector(8-1 downto 0);
        data: out std_logic_vector(16-1 downto 0));
    end component;
    
    -- The register component
    component reg is
        generic (DATA_WIDTH :integer);
        port (
            CLK    : in  std_logic;
            LD     : in  std_logic;
            D_IN   : in  std_logic_vector(DATA_WIDTH-1 downto 0);
            D_OUT  : out std_logic_vector(DATA_WIDTH-1 downto 0));
    end component;
    
begin
    -- The control ROM's port map
    control: controlrom
      port map (addr => thisrow,
        data => ctrllines,
        clk => CLK
      );
    
    -- The decision ROM's port map
    decision: decisionrom
      port map (addr => thisrow,
        data => jumplines,
        clk => CLK
      );
    
    -- The microcounter's size and port map
    microcounter: reg
      generic map(DATA_WIDTH => ROM_SIZE)
      port map (
        CLK => CLK,
        LD => '1',
        D_IN => nextrow,
        D_OUT => thisrow
      );
    
    -- Map the control lines from the control ROM to the output lines
    ALUOP <= ctrllines(3 downto 0);
    OP2SEL <= ctrllines(5 downto 4);
    DATAWRITE <= ctrllines(6);
    ADDRSEL <= ctrllines(8 downto 7);
    PCSEL <= ctrllines(10 downto 9);
    PCLOAD <= ctrllines(11);
    DWRITE <= ctrllines(12);
    IRLOAD <= ctrllines(13);
    IMLOAD <= ctrllines(14);
    REGSRC <= ctrllines(16 downto 15);
    cond <= ctrllines(18 downto 17);
    indexsel <= ctrllines(19);
    DATASEL <= ctrllines(21 downto 20);
    SWRITE <= ctrllines(22);
    
    -- Choose the jump value based on the jump choice value
    jumpvalue <= jumplines(7 downto 0) when jumpchoice='0' else
      		 jumplines(15 downto 8);
    
    -- The jump value from the opcode is either 0 or + & the opcode value
    opcodejump <= "00000000" when indexsel='0' else
      		  '0' & opcode;
    
    -- The jump choice is one of four values chosen by cond:
    -- the zero line (cond 0),
    -- zero OR negative (cond 1),
    -- negative (cond 2), or
    -- carry (cond 3)
    jumpchoice <= ZERO when (cond="00") else
      		  ZERO OR NEGATIVE when (cond="01") else
      		  NEGATIVE when (cond="10") else
      		  CARRY;
    
    -- The next row is the sum of the jumpvalue and the opcodejump
    nextrow <= std_logic_vector(unsigned(jumpvalue) + unsigned(opcodejump));
end;

library ieee;
use ieee.std_logic_1164.all;

entity ulogic_test is
end ulogic_test;

architecture behaviour of ulogic_test is
    component ulogic is
        generic (CONTROL_WIDTH :integer := 32;      -- Width of the control ROM
            DECISION_WIDTH :integer := 16;          -- Width of the decision ROM
            ROM_SIZE :integer := 8                  -- Size of ROM, 2^ROM_SIZE
        );
        port(CLK    : in  std_logic;
            CARRY: in  std_logic;
            ZERO: in  std_logic;
            NEGATIVE: in  std_logic;
            OPCODE: in  std_logic_vector (6 downto 0);
            ALUOP: out  std_logic_vector (3 downto 0);
            OP2SEL: out  std_logic_vector (1 downto 0);
            DATAWRITE: out  std_logic;
            ADDRSEL: out  std_logic_vector (1 downto 0);
            PCSEL: out  std_logic_vector (1 downto 0);
            PCLOAD: out  std_logic;
            DWRITE: out  std_logic;
            IRLOAD: out  std_logic;
            IMLOAD: out  std_logic;
            REGSRC: out  std_logic_vector (1 downto 0);
            DATASEL: out  std_logic_vector (1 downto 0);
            SWRITE: out  std_logic
          );
    end component;
    
    signal clock  : std_logic;
    signal carry  : std_logic;
    signal zero: std_logic;
    signal negative: std_logic;
    signal opcode: std_logic_vector (6 downto 0);
    signal aluop: std_logic_vector (3 downto 0);
    signal op2sel: std_logic_vector (1 downto 0);
    signal datawrite: std_logic;
    signal addrsel: std_logic_vector (1 downto 0);
    signal pcsel: std_logic_vector (1 downto 0);
    signal pcload: std_logic;
    signal dwrite: std_logic;
    signal irload: std_logic;
    signal imload: std_logic;
    signal regsrc: std_logic_vector (1 downto 0);
    signal datasel: std_logic_vector (1 downto 0);
    signal swrite: std_logic;
    
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
    uut: ulogic port map (
        clk => clock,
        CARRY => carry,
        ZERO => zero,
        NEGATIVE => negative,
        OPCODE => opcode,
        ALUOP => aluop,
        OP2SEL => op2sel,
        DATAWRITE =>  datawrite,
        ADDRSEL => addrsel,
        PCSEL => pcsel,
        PCLOAD => pcload,
        DWRITE => dwrite,
        IRLOAD => irload,
        IMLOAD => imload,
        REGSRC => regsrc,
        DATASEL => datasel,
        SWRITE => swrite
      );
    
    --- Stimulation process
    stim_proc: process
    begin
        -- Run li r0,0 instruction
        --	opcode <= "0111111";
        --	wait for clock_period;
        --	wait for clock_period;
        --	wait for clock_period;
        
        -- Run add     r0, r0, r1 instruction
        --	opcode <= "0000000";
        --	wait for clock_period;
        --	wait for clock_period;
        --	wait for clock_period;
        
        -- Run         jnez    r1, loop instruction
            opcode <= "0101000";
        	zero <= '0';
        	wait for clock_period;
        	wait for clock_period;
        	wait for clock_period;
        
        -- Run  sw      r0, 256 instruction
        -- opcode <= "1000001";
        -- wait for clock_period;
        -- wait for clock_period;
        -- wait for clock_period;
        
        wait for clock_period;
        report "memory test finished" severity failure;
    end process;
end;
