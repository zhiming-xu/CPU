library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

-- 16-bit ALU with two inputs and 16 different operations
-- (c) 2015 Warren Toomey, GPL3 licence
entity alu is
    generic (DATA_WIDTH :    integer := 16);
    port (
        A     : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        B     : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        ALUOP : in  std_logic_vector(3 downto 0);
        RESULT: out std_logic_vector(DATA_WIDTH-1 downto 0);
        ZERO  : out std_logic;
        CARRY : out std_logic;
        NEG   : out std_logic);
end;

architecture behaviour of alu is
    -- Internal copy of the ALU result
    signal r: std_logic_vector(DATA_WIDTH-1 downto 0);
    
    -- Extended A, B, sum and difference. Used for carry calculation
    signal ext_a:    std_logic_vector(DATA_WIDTH downto 0);
    signal ext_b:    std_logic_vector(DATA_WIDTH downto 0);
    signal ext_sum:  std_logic_vector(DATA_WIDTH downto 0);
    signal ext_diff: std_logic_vector(DATA_WIDTH downto 0);
    
    -- We are using GHDL's built-in divide and remainder operators.
    -- To stop these operators from receiving a second zero operand,
    -- we have an intermediate B line which is never zero when we
    -- are doing divide or remainder
    signal int_b: std_logic_vector(DATA_WIDTH-1 downto 0);
    
begin
    -- Ensure int_b can never be zero
    int_b <= B when (B /= x"0000") else x"0010";
    
    -- Operation 0: signed addition
    -- Operation 1: signed subtraction
    -- Operation 2: signed multiplication
    -- Operation 3: signed division
    -- Operation 4: signed remainder
    -- Operation 5: logical AND
    -- Operation 6: logical OR
    -- Operation 7: logical XOR
    -- Operation 8: logical NAND
    -- Operation 9: logical NOR
    -- Operation 10: logical NOT
    -- Operation 11: logical shift left
    -- Operation 12: logical shift right
    -- Operation 13: arithmetic shift right
    -- Operation 14: rotate left
    -- Operation 15: rotate left
    with ALUOP select
      r <= std_logic_vector(signed(A) + signed(B))      when "0000",
           std_logic_vector(signed(A) - signed(B))      when "0001",
           std_logic_vector(to_signed(to_integer(
		signed(A) * signed(B)),DATA_WIDTH))     when "0010",
           std_logic_vector(to_signed(to_integer(
		signed(A) / signed(int_b)),DATA_WIDTH)) when "0011",
           std_logic_vector(to_signed(to_integer(
		signed(A) rem signed(int_b)),DATA_WIDTH)) when "0100",
          A and B				       	when "0101",
          A or B				       	when "0110",
          A xor B				       	when "0111",
          not(A and B)					when "1000",
          not(A or B)				        when "1001",
          not(A)				       	when "1010",
	  std_logic_vector(shift_left(unsigned(A),
			to_integer(unsigned(B))))	when "1011",
	  std_logic_vector(shift_right(unsigned(A),
			to_integer(unsigned(B))))	when "1100",
	  std_logic_vector(shift_right(signed(A),
			to_integer(unsigned(B))))	when "1101",
	  std_logic_vector(rotate_left(unsigned(A),
			to_integer(unsigned(B))))	when "1110",
	  std_logic_vector(rotate_right(unsigned(A),
			to_integer(unsigned(B))))	when "1111",
          "ZZZZZZZZZZZZZZZZ"			        when others;
    
    -- Zero: OR all the result bits and negate. Not generic!
    ZERO <= not( r(0) or r(1) or r(2) or r(3) or r(4) or r(5) or
                 r(6) or r(7) or r(8) or r(9) or r(10) or r(11) or
                 r(12) or r(13) or r(14) or r(15));
    NEG  <= r(DATA_WIDTH-1);
    RESULT <= r;
    
    -- Doing the carry: we extend A & B and do the addition and
    -- subtraction. Only addition and subtraction cause carry.
    ext_a <= '0' & A;
    ext_b <= '0' & B;
    ext_sum <= std_logic_vector(signed(ext_a) + signed(ext_b));
    ext_diff <= std_logic_vector(signed(ext_a) - signed(ext_b));
    
    with ALUOP select
      CARRY <= ext_sum(DATA_WIDTH)  when "0000",
      	       ext_diff(DATA_WIDTH) when "0001",
      	       'Z'         	    when others;
end;

library ieee;
use ieee.std_logic_1164.all;

entity alu_test is
        generic (DATA_WIDTH :    integer := 16);
end alu_test;

architecture behaviour of alu_test is
    component alu is
        generic (DATA_WIDTH :integer := DATA_WIDTH);
	port (
            A     : in  std_logic_vector(DATA_WIDTH-1 downto 0);
            B     : in  std_logic_vector(DATA_WIDTH-1 downto 0);
            ALUOP : in  std_logic_vector(3 downto 0);
            RESULT: out std_logic_vector(DATA_WIDTH-1 downto 0);
            ZERO  : out std_logic;
            CARRY : out std_logic;
            NEG  : out std_logic);
    end component;
    
    signal a     : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal b     : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal aluop : std_logic_vector(3 downto 0);
    signal result: std_logic_vector(DATA_WIDTH-1 downto 0);
    signal zero  : std_logic;
    signal carry : std_logic;
    signal neg   : std_logic;
    
begin
    
    -- Unit under test port map
    uut: alu port map (
        A => a,
        B => b,
        ALUOP => aluop,
        RESULT=> result,
        ZERO => zero,
        CARRY => carry,
        NEG => neg
      );
    
    --- Stimulation process
    stim_proc: process
    begin
        -- Addition
        a <= x"0007"; b <= x"0008";
        aluop <= "0000"; wait for 10 ns;
        assert result = x"000f" report "7 + 8 failed";
        
        -- Subtraction with a non-zero result
        a <= x"0028"; b <= x"0008";
        aluop <= "0001"; wait for 10 ns;
        assert result = x"0020" report "28 - 8 failed";
        assert zero = '0' report "28 - 8 failed zero";
        
        -- Addition with a zero result
        a <= x"ffff"; b <= x"0001";
        aluop <= "0000"; wait for 10 ns;
        assert result = x"0000" report "-1 + 1 failed";
        assert zero = '1' report "-1 + 1 failed zero";
        
        -- Subtraction with a negative result
        a <= x"0008"; b <= x"0028";
        aluop <= "0001"; wait for 10 ns;
        assert result = x"ffe0" report "8 - 28 failed";
        assert neg = '1' report "8 - 28 failed negative";
        
        -- Addition with a carry
        a <= x"9000"; b <= x"9000";
        aluop <= "0000"; wait for 10 ns;
        assert result = x"2000" report "9000 + 9000 failed";
        assert carry = '1' report "9000 + 9000 carry failed";
        
        -- Multiplication
        a <= x"0010"; b <= x"0020";
        aluop <= "0010"; wait for 10 ns;
        assert result = x"0200" report "10 * 20 failed";
        
        -- Division 
        a <= x"0030"; b <= x"0010";
        aluop <= "0011"; wait for 10 ns;
        
        -- Modulo 
        aluop <= "0100";
        a <= x"0000"; b <= x"0005";
        wait for 10 ns;
        a <= x"0001"; b <= x"0005";
        wait for 10 ns;
        a <= x"0002"; b <= x"0005";
        wait for 10 ns;
        a <= x"0003"; b <= x"0005";
        wait for 10 ns;
        a <= x"0004"; b <= x"0005";
        wait for 10 ns;
        a <= x"0005"; b <= x"0005";
        wait for 10 ns;
        a <= x"0006"; b <= x"0005";
        wait for 10 ns;
        a <= x"0007"; b <= x"0005";
        wait for 10 ns;
        a <= x"0008"; b <= x"0005";
        wait for 10 ns;
        a <= x"0009"; b <= x"0005";
        wait for 10 ns;
        
        wait for 10 ns;
        report "alu test finished" severity failure;
        wait;
    end process;
end;
