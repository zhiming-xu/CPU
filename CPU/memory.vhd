-------------------------------------------------------
-- Memory module for Warren's microcoded CPU.
--
-- There are four banks of 16K words. The first bank starting at 0x0000
-- contains ROM. The second bank at 0x4000 contains RAM. The third bank
-- is empty. The fourth bank at 0xC000 maps I/O devices like the UART.
--
-- To avoid tristate logic which is hard to implement on an FPGA, this
-- memory unit has data in, data out, plus lines to connect to an external
-- UART device which is supplied by the nexys4.vhd component.
-- a data bus, a clock and a load (write enable) line.
--
-- (c) 2015 Warren Toomey, GPL3 licence
-------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity memory is
    generic (ADDR_WIDTH :    integer := 16;
             DATA_WIDTH :    integer := 16
    );
    port (clk     : in    std_logic;
          address : in    std_logic_vector (ADDR_WIDTH-1 downto 0);
          data_in : in    std_logic_vector (DATA_WIDTH-1 downto 0);
          data_out: out   std_logic_vector (DATA_WIDTH-1 downto 0);
          ld      : in    std_logic;
	  uart_status: in std_logic_vector(2 downto 0);
	  uart_wrdata: out std_logic_vector(7 downto 0);
	  uart_rddata: in  std_logic_vector(7 downto 0);
	  uart_ctrl: out std_logic_vector(1 downto 0)
    );
end entity;

architecture behaviour of memory is
    -- Internal signal lines
    -- The top two bits of the incoming address
    alias addrsel: std_logic_vector (1 downto 0)
      			is address(ADDR_WIDTH-1 downto ADDR_WIDTH-2);
    
    -- The lower bits of the incoming address
    alias addrlsb: std_logic_vector (ADDR_WIDTH-3 downto 0)
      			is address(ADDR_WIDTH-3 downto 0);
    
    -- RAM output line and load line
    signal ram_data_out: std_logic_vector (DATA_WIDTH-1 downto 0);
    signal ram_ld: std_logic;
    
    -- The ROM's output and address lines
    signal rom_data: std_logic_vector (DATA_WIDTH-1 downto 0);
    
    -- The UART is mapped as follows:
    --    data_in is at 0xC001 lowest 8 bits
    --    uart_status is dav,ready,empty, which are the lowest 3 bits at 0xC002
    --    uart_ctrl(0): write is rising edge to write data
    --    uart_ctrl(1): strobe high to tell UART we received data
    
    -- The 16K ROM component
    component mainrom is
      port (clk: in std_logic;
        addr: in std_logic_vector(14-1 downto 0);
        data: out std_logic_vector(16-1 downto 0)
      );
    end component;
    
    -- The 16K RAM component
    component ram is
        generic (ADDR_WIDTH :integer := ADDR_WIDTH-2;
            	 DATA_WIDTH :integer := DATA_WIDTH
        );
        port (
            clk     :in    std_logic;
            address :in    std_logic_vector (ADDR_WIDTH-1 downto 0);
            datain  :in    std_logic_vector (DATA_WIDTH-1 downto 0);
            dataout :out   std_logic_vector (DATA_WIDTH-1 downto 0);
            we      :in    std_logic);
    end component;
    
begin
    -- The ROM's port map
    romchip: mainrom port map (
        clk => clk,
        addr => addrlsb,
        data => rom_data
      );
    
    -- The RAM's port map
    ramchip: ram port map (
        clk => clk,
        address => addrlsb,
        datain => data_in,
        dataout => ram_data_out,
        we => ram_ld
      );

    -- The data out is:
    -- the ROM output when address bank 0,
    -- the RAM output when address bank 1,
    -- the UART's data when address 0xC000,
    -- the UART's status lines when address 0xC002,
    -- and (for now) zeroes when everything else
    data_out <= rom_data when addrsel= "00" else
      	        ram_data_out when addrsel= "01" else
	        "00000000" & uart_rddata when address= x"C000" else
	        "0000000000000" & uart_status when address= x"C002" else
      	        (others => '0');

    -- RAM is only written when using address bank 1.
    ram_ld <= ld when addrsel= "01" else '0';
    
    -- We strobe the UART write line on address 0xC001.
    uart_wrdata <= data_in(7 downto 0);
    uart_ctrl(0) <= '1' when address= x"C001" else '0';

    -- We strobe the UART read line on address 0xC000.
    uart_ctrl(1) <= '1' when address= x"C000" else '0';
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity memory_test is
    generic (DATA_WIDTH :integer := 16;
             ADDR_WIDTH :integer := 16
    );
end memory_test;

architecture behaviour of memory_test is
    component memory is
        generic (ADDR_WIDTH :    integer := 16;
                 DATA_WIDTH :    integer := 16
        );
        port (clk     :in    std_logic;
              uart_clk:in    std_logic;
              address :in    std_logic_vector (ADDR_WIDTH-1 downto 0);
              data    :inout std_logic_vector (DATA_WIDTH-1 downto 0);
              ld      :in    std_logic
        );
    end component;
    
    signal clock  : std_logic;
    signal addr   : std_logic_vector(ADDR_WIDTH-1 downto 0) := x"0000";
    signal data   : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal ld     : std_logic;
    
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
    uut: memory port map (
        clk => clock,
        uart_clk => clock,
        address => addr,
        data => data,
        ld => ld
      );
    
    --- Stimulation process
    stim_proc: process
    begin
                -- Read from RAM location 0x4017
                ld <= '0'; 
                addr <= x"4017"; wait for clock_period;
                data <= (others => 'Z');
                
                -- Store at RAM location 0x4022
                ld <= '1'; 
                addr <= x"4022";
                data <= x"00ab"; wait for clock_period;
        
        -- Store ee at RAM location 0x4088
        ld <= '1'; 
        addr <= x"4080";
        data <= x"00ee"; wait for clock_period;
        
        -- Read from RAM location 0x4022
        ld <= '0'; 
        data <= (others => 'Z');
        addr <= x"4022"; wait for clock_period;
        
        -- Read from some other location
        ld <= '0'; 
        data <= (others => 'Z');
        addr <= x"4020"; wait for clock_period;
        
        -- Read from 0x4022 again
        ld <= '0'; 
        data <= (others => 'Z');
        addr <= x"4022"; wait for clock_period;
        
        -- Read from 0x4080 again
        ld <= '0'; 
        data <= (others => 'Z');
        addr <= x"4080"; wait for clock_period;
        wait for clock_period;
        
        -- Read from ROM location 0x0001
        ld <= '0'; 
        data <= (others => 'Z');
        addr <= x"0001"; wait for clock_period;
        wait for clock_period;
        
        -- Read from ROM location 0x0002
        ld <= '0'; 
        data <= (others => 'Z');
        addr <= x"0002"; wait for clock_period;
        wait for clock_period;
        
        -- Read from ROM location 0x0020
        ld <= '0'; 
        data <= (others => 'Z');
        addr <= x"0020"; wait for clock_period;
        wait for clock_period;
        
        wait for clock_period;
        report "memory test finished" severity failure;
    end process;
end;
