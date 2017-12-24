---------------------------------------------------------------------
-- Warren's microcoded CPU. This is the VHDL version of the CPU
-- described at http://minnie.tuhs.org/Programs/UcodeCPU. The only
-- significant difference is that 16K of ROM is mapped starting at
-- address 0x0000, 16K of RAM mapped starting at 0x4000, nothing at
-- the 16K block starting at 0x8000, and a UART is mapped at the
-- addresses 0xC000, 0xC001 and 0xC002.
-- (c) 2015 Warren Toomey, GPL3 licence
---------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity cpu is
    generic (ADDR_WIDTH :    integer := 16;
             DATA_WIDTH :    integer := 16
      );
    port ( SYS_CLK: in   std_logic;
	   RESET:   in   std_logic;
           UART_STATUS: in std_logic_vector(2 downto 0);
	   UART_RDDATA: in std_logic_vector(7 downto 0);
	   UART_WRDATA: out std_logic_vector(7 downto 0);
           UART_CTRL: out std_logic_vector(1 downto 0);
	   ADDRBUS: out std_logic_vector (ADDR_WIDTH-1 downto 0);
	   DATABUS: out std_logic_vector (DATA_WIDTH-1 downto 0);
	   INST_REG: out std_logic_vector (DATA_WIDTH-1 downto 0);
	   STATUS: out std_logic_vector(3 downto 0)
    );
end entity;

architecture behaviour of cpu is
    
    -- Data and address bus into the memory unit, plus the load line
    -- and the output from the program counter
    signal data_bus: std_logic_vector (DATA_WIDTH-1 downto 0);
    signal addr_bus: std_logic_vector (ADDR_WIDTH-1 downto 0);
    signal pc_out  : std_logic_vector (ADDR_WIDTH-1 downto 0);

    -- Data signals that drive the data bus, one from the CPU itself
    -- and the other from the memory unit
    signal cpu_data: std_logic_vector (DATA_WIDTH-1 downto 0);
    signal memory_data: std_logic_vector (DATA_WIDTH-1 downto 0);
    
    -- Data lines between the data bus and the ALU
    -- Immediate register output
    signal immed_out: std_logic_vector (ADDR_WIDTH-1 downto 0);
    
    -- The output of the instruction register is split into several bundles
    signal ir_out:  std_logic_vector (DATA_WIDTH-1 downto 0);
    signal opcode:  std_logic_vector (6 downto 0);
    signal tregsel: std_logic_vector (2 downto 0);
    signal sregsel: std_logic_vector (2 downto 0);
    signal dregsel: std_logic_vector (2 downto 0);
    
    -- Register file inputs and outputs
    signal dwrite,swrite: std_logic;
    signal regval: std_logic_vector(DATA_WIDTH-1 downto 0);
    signal dreg, sreg, treg: std_logic_vector(DATA_WIDTH-1 downto 0);
    
    -- Control lines from the microcode logic
    signal aluop: std_logic_vector (3 downto 0);   -- ALU operation
    signal datawrite: std_logic;		   -- Write data on the bus
    signal addrsel: std_logic_vector (1 downto 0); -- Select address on bus
    signal datasel: std_logic_vector (1 downto 0); -- Select write data on bus
    signal pcsel: std_logic_vector (1 downto 0);   -- Select PC operation
    signal op2sel: std_logic_vector (1 downto 0);  -- Select second ALU operand
    signal regsrc: std_logic_vector (1 downto 0);  -- Select reg file write src
    signal pc_load: std_logic;			   -- Program counter load
    signal im_load: std_logic;			   -- Immediate register load
    signal ir_load: std_logic;			   -- Instruction register load
    
    -- Lines into and out from the ALU
    signal alu_a:  std_logic_vector(DATA_WIDTH-1 downto 0);
    signal alu_b:  std_logic_vector(DATA_WIDTH-1 downto 0);
    signal aluout: std_logic_vector(DATA_WIDTH-1 downto 0);
    signal zero  : std_logic;
    signal carry : std_logic;
    signal neg   : std_logic;

    -- The component types used to build the CPU
    component reg is
        -- generic (DATA_WIDTH :integer := DATA_WIDTH);
        port (
            CLK   : in  std_logic;
            LD    : in  std_logic;
            D_IN  : in  std_logic_vector(DATA_WIDTH-1 downto 0);
            D_OUT : out std_logic_vector(DATA_WIDTH-1 downto 0));
    end component;
    
    component prog_cntr is
        -- generic (DATA_WIDTH :integer := DATA_WIDTH);
        port (
            PCLOAD : in std_logic;
            RESET  : in std_logic;
            PCSEL  : in std_logic_vector(1 downto 0);
            IMVAL  : in std_logic_vector(DATA_WIDTH-1 downto 0);
            SREGVAL: in std_logic_vector(DATA_WIDTH-1 downto 0);
            PCOUT  : out std_logic_vector(DATA_WIDTH-1 downto 0);
            CLK    : in std_logic);
    end component;
    
    component regfile is
        -- generic (DATA_WIDTH :integer := DATA_WIDTH);
        port(
            DWRITE: in std_logic;
            SWRITE: in std_logic;
            TWRITE: in std_logic;
            DSEL  : in std_logic_vector(2 downto 0);
            SSEL  : in std_logic_vector(2 downto 0);
            TSEL  : in std_logic_vector(2 downto 0);
            REGVAL: in std_logic_vector(DATA_WIDTH-1 downto 0);
            DREG  : out std_logic_vector(DATA_WIDTH-1 downto 0);
            SREG  : out std_logic_vector(DATA_WIDTH-1 downto 0);
            TREG  : out std_logic_vector(DATA_WIDTH-1 downto 0);
            CLK  : in std_logic);
    end component;
    
    -- The ALU component
    component alu is port (
            A     : in  std_logic_vector(DATA_WIDTH-1 downto 0);
            B     : in  std_logic_vector(DATA_WIDTH-1 downto 0);
            ALUOP : in  std_logic_vector(3 downto 0);
            RESULT: out std_logic_vector(DATA_WIDTH-1 downto 0);
            ZERO  : out std_logic;
            CARRY : out std_logic;
            NEG   : out std_logic);
    end component;
    
    -- The memory component
    component memory is
 --       generic (ADDR_WIDTH :    integer := 16;
 --           	   DATA_WIDTH :    integer := 16);
        port (clk     : in    std_logic;
              address : in    std_logic_vector (ADDR_WIDTH-1 downto 0);
              data_in : in    std_logic_vector (DATA_WIDTH-1 downto 0);
              data_out: out   std_logic_vector (DATA_WIDTH-1 downto 0);
              ld      : in    std_logic;
              uart_status: in std_logic_vector(2 downto 0);
	      uart_wrdata: out std_logic_vector(7 downto 0);
	      uart_rddata: in  std_logic_vector(7 downto 0);
              uart_ctrl: out std_logic_vector(1 downto 0));
    end component;
    
    -- The microcode logic component
    component ulogic is
--        generic (CONTROL_WIDTH :integer := 32;      -- Width of the control ROM
--            DECISION_WIDTH :integer := 16;          -- Width of the decision ROM
--            ROM_SIZE :integer := 8                  -- Size of ROM, 2^ROM_SIZE
--        );
        port(CLK     : in  std_logic;
            CARRY    : in  std_logic;
            ZERO     : in  std_logic;
            NEGATIVE : in  std_logic;
            OPCODE   : in  std_logic_vector (6 downto 0);
            ALUOP    : out  std_logic_vector (3 downto 0);
            OP2SEL   : out  std_logic_vector (1 downto 0);
            DATAWRITE: out  std_logic;
            ADDRSEL  : out  std_logic_vector (1 downto 0);
            PCSEL    : out  std_logic_vector (1 downto 0);
            PCLOAD   : out  std_logic;
            DWRITE   : out  std_logic;
            IRLOAD   : out  std_logic;
            IMLOAD   : out  std_logic;
            REGSRC   : out  std_logic_vector (1 downto 0);
            DATASEL  : out  std_logic_vector (1 downto 0);
            SWRITE   : out  std_logic
          );
    end component;

begin
    -- The actual components used to build the CPU

    -- Immediate register
    immed_reg: reg port map(
        D_IN => data_bus,
        D_OUT => immed_out,
        LD => im_load,
        CLK => SYS_CLK );
    
    -- Instruction register
    instr_reg: reg port map(
        D_IN => data_bus,
        D_OUT => ir_out,
        LD => ir_load,
        CLK => SYS_CLK );
    
    -- Program counter
    pc: prog_cntr port map (
        CLK => SYS_CLK,
        PCLOAD => pc_load,
        RESET => RESET,
        PCSEL => pcsel,
        IMVAL => immed_out,
        SREGVAL => sreg,
        PCOUT => pc_out
      );
    
    -- The register file
    regs: regfile port map (
        DWRITE => dwrite,
        SWRITE => swrite,
        TWRITE => '0',
        DSEL => dregsel,
        SSEL => sregsel,
        TSEL => tregsel,
        REGVAL => regval,
        DREG => dreg,
        SREG => sreg,
        TREG => treg,
        CLK => SYS_CLK
      );
    
    -- The ALU
    alunit: alu port map (
        A => alu_a,
        B => alu_b,
        ALUOP => aluop,
        RESULT=> aluout,
        ZERO => zero,
        CARRY => carry,
        NEG => neg
      );
    
    -- The memory
    mem: memory
      port map (
        clk => SYS_CLK,
        address => addr_bus,
        data_in => data_bus,
        data_out => memory_data,
        ld => datawrite,
        uart_status =>  UART_STATUS,
	uart_wrdata => UART_WRDATA,
	uart_rddata => UART_RDDATA,
        uart_ctrl => UART_CTRL
      );
    
    -- The microcode unit
    ucode: ulogic port map (
        clk => SYS_CLK,
        CARRY => carry,
        ZERO => zero,
        NEGATIVE => neg,
        OPCODE => opcode,
        ALUOP => aluop,
        OP2SEL => op2sel,
        DATAWRITE => datawrite,
        ADDRSEL => addrsel,
        PCSEL => pcsel,
        PCLOAD => pc_load,
        DWRITE => dwrite,
        IRLOAD => ir_load,
        IMLOAD => im_load,
        REGSRC => regsrc,
        DATASEL => datasel,
        SWRITE => swrite
      );

    -- These are the top-level multiplexors in the CPU
    -- Multiplexor on the address bus
    addr_bus <= pc_out when addrsel="00" else
      		immed_out when addrsel="01" else
      		aluout when addrsel="10" else
      		sreg when addrsel="11" else
      		(others => 'Z');
    
    -- Multiplexor into the register file
    regval <= data_bus when regsrc="00" else
      	      immed_out when regsrc="01" else
      	      aluout when regsrc="10" else
      	      sreg when regsrc="11" else
      	      (others => 'Z');
    
    -- Multiplexor into the second ALU input, and first ALU input
    alu_a <= sreg;
    alu_b <= treg when op2sel="00" else
      	     immed_out when op2sel="01" else
      	     x"0000" when op2sel="10" else
      	     x"0001" when op2sel="11" else
      	     (others => 'Z');
    
    -- Multiplexor for the CPU data bus driver
    cpu_data <= pc_out when datasel="00" else
                dreg   when datasel="01" else
                sreg   when datasel="10" else
                aluout when datasel="11" else
                (others => 'Z');

    -- Multiplexor onto the data bus
    data_bus <= memory_data when datawrite= '0' else
		cpu_data;
    
    -- Unbundle the instruction from the instruction register
    opcode <= ir_out(15 downto 9);
    tregsel <= ir_out(8 downto 6);
    sregsel <= ir_out(5 downto 3);
    dregsel <= ir_out(2 downto 0);

    -- Diagnostic output to the FPGA board
    ADDRBUS <= addr_bus;
    DATABUS <= data_bus;
    INST_REG <= ir_out;
    STATUS <= datawrite & zero & neg & carry;

end architecture;
