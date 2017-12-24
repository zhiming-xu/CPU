-------------------------------------------------------
-- Design Name : ram_sp_ar_sw
-- File Name   : ram_sp_ar_sw.vhd
-- Function    : Async read Sync write RAM 
-- Coder       : Deepak Kumar Tala (Verilog)
-- Translator  : Alexander H Pham (VHDL)
-------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ram is
    generic (ADDR_WIDTH :    integer := 8;
             DATA_WIDTH :    integer := 8
    );
    port (clk  : in  std_logic;                                -- Clock Input
        address: in  std_logic_vector(ADDR_WIDTH-1 downto 0);  -- Address Input
        datain : in  std_logic_vector(DATA_WIDTH-1 downto 0);  -- Data in
        dataout: out std_logic_vector(DATA_WIDTH-1 downto 0);  -- Data out
        we     :in    std_logic                                -- Write Enable
      );
end entity;

architecture rtl of ram is
    ----------------Internal variables----------------
    constant RAM_DEPTH :integer := 2**ADDR_WIDTH;
    signal data_out :std_logic_vector (DATA_WIDTH-1 downto 0);
    type RAM is array (integer range <>)of
				std_logic_vector (DATA_WIDTH-1 downto 0);
    -- Initialise the memory to all zeroes
    signal mem : RAM (0 to RAM_DEPTH-1) := (others => (others => '0'));
begin
    ----------------Code Starts Here------------------
    dataout <= data_out;
    
    -- Memory Write Block
    -- Write Operation : When we = 1
    MEM_WRITE:
      process (clk) begin
        if (rising_edge(clk)) then
            if (we = '1') then
                mem(to_integer(unsigned(address))) <= datain;
            end if;
        end if;
    end process;
    
    -- Memory Read Block
    -- Asynchronous Read Operation
    MEM_READ:
      process (address, mem) begin
        data_out <= mem(to_integer(unsigned(address)));
      end process;
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity ram_test is
    generic (DATA_WIDTH :integer := 8;
             ADDR_WIDTH :integer := 16
    );
end ram_test;

architecture behaviour of ram_test is
    component ram is
       generic (ADDR_WIDTH :integer := ADDR_WIDTH;
                DATA_WIDTH :integer := DATA_WIDTH
       );
        port (
            clk     :in    std_logic;
            address :in    std_logic_vector (ADDR_WIDTH-1 downto 0);
            data    :inout std_logic_vector (DATA_WIDTH-1 downto 0);
            we      :in    std_logic);
    end component;
    
    signal clock  : std_logic;
    signal addr   : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal data   : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal we     : std_logic;
    
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
    uut: ram port map (
        clk => clock,
        address => addr,
        data => data,
        we => we
      );
    
    --- Stimulation process
    stim_proc: process
    begin
        -- Read from RAM location 17
        we <= '0'; 
        addr <= x"0017"; wait for clock_period;
        
        -- Store ab at RAM location 22
        we <= '1'; 
        addr <= x"0022";
        data <= x"ab"; wait for clock_period;
        
        -- Store ee at RAM location 80
        we <= '1'; 
        addr <= x"0080";
        data <= x"ee"; wait for clock_period;
        
        -- Read ab from RAM location 22
        we <= '0'; 
        data <= (others => 'Z');
        addr <= x"0022"; wait for clock_period;
        
        -- Read from some other location
        we <= '0'; 
        data <= (others => 'Z');
        addr <= x"0020"; wait for clock_period;
        
        -- Read from 22 again
        we <= '0'; 
        data <= (others => 'Z');
        addr <= x"0022"; wait for clock_period;
        
        -- Read from 80 again
        we <= '0'; 
        data <= (others => 'Z');
        addr <= x"0080"; wait for clock_period;
        wait for clock_period;
        
        report "ram test finished" severity failure;
    end process;
end;
