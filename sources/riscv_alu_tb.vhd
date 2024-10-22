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
    i_opcode <= "0000";  -- Set an example opcode (replace with specific ALU operation)
    i_shamt  <= "00000"; -- Shift amount (used for shift operations)
    i_src1   <= (others => '0');  -- Initialize source operand 1
    i_src2   <= (others => '0');  -- Initialize source operand 2

    -- Wait and add more test cases
    wait for 20 ns;
    
    -- Continue with other test scenarios and assertions...

    wait;
  end process;

end architecture test;