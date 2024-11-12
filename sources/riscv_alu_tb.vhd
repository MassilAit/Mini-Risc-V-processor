library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.riscv_pkg.all;

entity tb_riscv_alu is
end entity tb_riscv_alu;

architecture test of tb_riscv_alu is

  -- Signals to connect to the ALU
  signal i_arith  : std_logic;                                -- Arith/Logic
  signal i_sign   : std_logic;                                -- Signed/Unsigned
  signal i_opcode : std_logic_vector(ALUOP_WIDTH-1 downto 0); -- ALU opcodes
  signal i_shamt  : std_logic_vector(SHAMT_WIDTH-1 downto 0); -- Shift Amount
  signal i_src1   : std_logic_vector(XLEN-1 downto 0);        -- Operand A
  signal i_src2   : std_logic_vector(XLEN-1 downto 0);        -- Operand B
  signal o_res    : std_logic_vector(XLEN-1 downto 0);        -- Result

  -- Instantiate the ALU component
  component riscv_alu
    port (
      i_arith  : in  std_logic;
      i_sign   : in  std_logic;
      i_opcode : in  std_logic_vector(ALUOP_WIDTH-1 downto 0);
      i_shamt  : in  std_logic_vector(SHAMT_WIDTH-1 downto 0);
      i_src1   : in  std_logic_vector(XLEN-1 downto 0);
      i_src2   : in  std_logic_vector(XLEN-1 downto 0);
      o_res    : out std_logic_vector(XLEN-1 downto 0)
    );
  end component;

begin

  -- Instantiate the Device Under Test (DUT)
  DUT: riscv_alu
    port map (
      i_arith  => i_arith,
      i_sign   => i_sign,
      i_opcode => i_opcode,
      i_shamt  => i_shamt,
      i_src1   => i_src1,
      i_src2   => i_src2,
      o_res    => o_res
    );

  
  stim_process : process
  begin
    -- Example of initializing inputs (add your test cases)
    i_arith  <= '0';  -- Set for addition
    i_sign   <= '0';  -- Set for unsigned operation
    i_opcode <= "000";  -- Set an example opcode (replace with specific ALU operation)
    i_shamt  <= "00000"; -- Shift amount (used for shift operations)
    i_src1   <= (others => '0');  -- Initialize source operand 1
    i_src2   <= (others => '0');  -- Initialize source operand 2

    wait for 20 ns;
    
    --Test 1 : ALUOP_ADD (addition)
    i_src1<=std_logic_vector(to_unsigned(20, XLEN));
    i_src2<=std_logic_vector(to_unsigned(10, XLEN));
    i_arith  <= '0';  -- Set for addition
    i_sign   <= '0';  -- Set for unsigned operation
    i_opcode<=ALUOP_ADD;
    wait for 5 ns;
    if o_res = std_logic_vector(to_unsigned(30, XLEN)) then
     assert false report "Test 1 Passed: Addition (20 + 10) = 30" severity note;
    else
     assert false report "Test 1 Failed: Addition (20 + 10) should be 30" severity error;
    end if;

    wait for 20 ns;

    --Test 2 : ALUOP_ADD (soustraction)
    i_src1<=std_logic_vector(to_unsigned(20, XLEN));
    i_src2<=std_logic_vector(to_unsigned(10, XLEN));
    i_arith  <= '1';  -- Soustraction
    i_sign   <= '0';  -- Set for unsigned operation
    i_opcode<=ALUOP_ADD;
    wait for 5 ns;
    if o_res = std_logic_vector(to_unsigned(10, XLEN)) then
     assert false report "Test 2 Passed: Substraction (20-10) = 10" severity note;
    else
     assert false report "Test 2 Failed: Addition (20 - 10) should be 10" severity error;
    end if;

    wait for 20 ns;

    --Test 3 : ALUOP_SLT (résultat nul)
    i_src1<=std_logic_vector(to_unsigned(10, XLEN));
    i_src2<=std_logic_vector(to_unsigned(10, XLEN));
    i_arith  <= '1';  -- Set for substraction
    i_sign   <= '0';  -- Set for unsigned operation
    i_opcode<=ALUOP_SLT;
    wait for 5 ns;
    if o_res = std_logic_vector(to_unsigned(1, XLEN)) then
     assert false report "Test 3 Passed: Null result outputs 1" severity note;
    else
     assert false report "Test 3 Failed: Null result outputs 0" severity error;
    end if;

    wait for 20 ns;

    --Test 4 : ALUOP_SLT (résultat non nul)
    i_src1<=std_logic_vector(to_unsigned(20, XLEN));
    i_src2<=std_logic_vector(to_unsigned(10, XLEN));
    i_arith  <= '1';  -- Set for substraction
    i_sign   <= '0';  -- Set for unsigned operation
    i_opcode<=ALUOP_SLT;
    wait for 5 ns;
    if o_res = std_logic_vector(to_unsigned(0, XLEN)) then
     assert false report "Test 4 Passed: Non null result outputs 0" severity note;
    else
     assert false report "Test 4 Failed: Non null result outputs 1" severity error;
    end if;

    wait for 20 ns;

    --Test 5 : ALUOP_SL 
    i_src1<=std_logic_vector(to_unsigned(1, XLEN));
    i_shamt  <= "00001"; -- Shift amount (used for shift operations)
    i_arith  <= '0';  -- Set for substraction
    i_sign   <= '0';  -- Set for unsigned operation
    i_opcode<=ALUOP_SL;
    wait for 5 ns;
    if o_res = std_logic_vector(to_unsigned(2, XLEN)) then
     assert false report "Test 5 Passed: Shift left of 1 = 2" severity note;
    else
     assert false report "Test 5 Failed: Shift left of 1 != 2" severity error;
    end if;

    wait for 20 ns;

     --Test 6 : ALUOP_SR (logique) 
     i_src1<=std_logic_vector(to_unsigned(2, XLEN));
     i_shamt  <= "00001"; -- Shift amount (used for shift operations)
     i_arith  <= '0';  -- Set for substraction
     i_sign   <= '0';  
     i_opcode<=ALUOP_SR;
     wait for 5 ns;
     if o_res = std_logic_vector(to_unsigned(1, XLEN)) then
      assert false report "Test 6 Passed: Logical shift right of 2 = 1" severity note;
     else
      assert false report "Test 6 Failed: Logical shift left of 2 != 1" severity error;
     end if;
 
     wait for 20 ns;

     --Test 7 : ALUOP_SR (arithmétique) 
     i_src1<=std_logic_vector(to_signed(-2, XLEN));
     i_shamt  <= "00001"; -- Shift amount (used for shift operations)
     i_arith  <= '1';  -- arithmetic shift
     i_sign   <= '0';  
     i_opcode<=ALUOP_SR;
     wait for 5 ns;
     if o_res = std_logic_vector(to_signed(-1, XLEN)) then
      assert false report "Test 7 Passed: Arithmetic shift right of -2 = -1" severity note;
     else
      assert false report "Test 7 Failed: Arithmetic shift left of -2 != -1" severity error;
     end if;

    wait for 20 ns;

    --Test 8 : XOR (1 xor 0)
    i_src1<=std_logic_vector(to_unsigned(1, XLEN));
    i_src2<=std_logic_vector(to_unsigned(0, XLEN));
    i_arith  <= '0';  
    i_sign   <= '0';
    i_shamt  <= "00000";   
    i_opcode<=ALUOP_XOR;
    wait for 5 ns;
    if o_res = std_logic_vector(to_unsigned(1, XLEN)) then
     assert false report "Test 8 Passed: 1 Xor 0 = 1" severity note;
    else
     assert false report "Test 8 Failed: 1 Xor 0 != 1" severity error;
    end if;

    wait for 20 ns;

    --Test 9 : XOR (1 xor 1)
    i_src1<=std_logic_vector(to_unsigned(1, XLEN));
    i_src2<=std_logic_vector(to_unsigned(1, XLEN));
    i_arith  <= '0';  
    i_sign   <= '0';
    i_shamt  <= "00000";   
    i_opcode<=ALUOP_XOR;
    wait for 5 ns;
    if o_res = std_logic_vector(to_unsigned(0, XLEN)) then
     assert false report "Test 9 Passed: 1 Xor 1 = 0" severity note;
    else
     assert false report "Test 9 Failed: 1 Xor 1 != 0" severity error;
    end if;

    wait for 20 ns;


    --Test 10 : OR (1 or 1)
    i_src1<=std_logic_vector(to_unsigned(1, XLEN));
    i_src2<=std_logic_vector(to_unsigned(1, XLEN));
    i_arith  <= '0';  
    i_sign   <= '0';
    i_shamt  <= "00000";   
    i_opcode<=ALUOP_OR;
    wait for 5 ns;
    if o_res = std_logic_vector(to_unsigned(1, XLEN)) then
     assert false report "Test 10 Passed: 1 or 1 = 1" severity note;
    else
     assert false report "Test 10 Failed: 1 or 1 != 1" severity error;
    end if;

    wait for 20 ns;

     --Test 11 : OR (1 or 0)
     i_src1<=std_logic_vector(to_unsigned(1, XLEN));
     i_src2<=std_logic_vector(to_unsigned(0, XLEN));
     i_arith  <= '0';  
     i_sign   <= '0';
     i_shamt  <= "00000";   
     i_opcode<=ALUOP_OR;
     wait for 5 ns;
     if o_res = std_logic_vector(to_unsigned(1, XLEN)) then
      assert false report "Test 11 Passed: 1 or 0 = 1" severity note;
     else
      assert false report "Test 11 Failed: 1 or 0 != 1" severity error;
     end if;
 
     wait for 20 ns;

     --Test 12 : And (1 or 0)
     i_src1<=std_logic_vector(to_unsigned(1, XLEN));
     i_src2<=std_logic_vector(to_unsigned(0, XLEN));
     i_arith  <= '0';  
     i_sign   <= '0';
     i_shamt  <= "00000";   
     i_opcode<=ALUOP_AND;
     wait for 5 ns;
     if o_res = std_logic_vector(to_unsigned(0, XLEN)) then
      assert false report "Test 12 Passed: 1 and 0 = 0" severity note;
     else
      assert false report "Test 12 Failed: 1 and 0 != 0" severity error;
     end if;
 
     wait for 20 ns;

     --Test 13 : And (1 or 0)
     i_src1<=std_logic_vector(to_unsigned(1, XLEN));
     i_src2<=std_logic_vector(to_unsigned(1, XLEN));
     i_arith  <= '0';  
     i_sign   <= '0';
     i_shamt  <= "00000";   
     i_opcode<=ALUOP_AND;
     wait for 5 ns;
     if o_res = std_logic_vector(to_unsigned(1, XLEN)) then
      assert false report "Test 13 Passed: 1 and 1 = 1" severity note;
     else
      assert false report "Test 13 Failed: 1 and 1 != 1" severity error;
     end if;
 
     wait for 20 ns;

    wait;
  end process;

end architecture test;