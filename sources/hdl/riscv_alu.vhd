-------------------------------------------------------------------------------
-- Project  ELE8304 : Circuits intégrés à très grande échelle
-------------------------------------------------------------------------------
-- File     riscv_alu.vhd
-- Author   Mickael Fiorentino  <mickael.fiorentino@polymtl.ca>
-- Lab      GRM - Polytechnique Montreal
-- Date     2019-08-09
-------------------------------------------------------------------------------
-- Brief    Arithmetical and Logical Unit
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.riscv_pkg.all;

entity riscv_alu is
  port (
    i_arith  : in  std_logic;                                -- Arith/Logic
    i_sign   : in  std_logic;                                -- Signed/Unsigned
    i_opcode : in  std_logic_vector(ALUOP_WIDTH-1 downto 0); -- ALU opcodes
    i_shamt  : in  std_logic_vector(SHAMT_WIDTH-1 downto 0); -- Shift Amount
    i_src1   : in  std_logic_vector(XLEN-1 downto 0);        -- Operand A
    i_src2   : in  std_logic_vector(XLEN-1 downto 0);        -- Operand B
    o_res    : out std_logic_vector(XLEN-1 downto 0));       -- Result
end entity riscv_alu;

architecture beh of riscv_alu is

  signal shifter_res : unsigned(XLEN-1 downto 0);
  signal adder_res   : std_logic_vector(XLEN downto 0);
  signal slt_res     : std_logic_vector(XLEN-1 downto 0);

begin

  ------------------------------------------------------------------------------
  --  SHIFTER
  ------------------------------------------------------------------------------
  p_shift : process (all)
  begin
    case i_opcode is
      when ALUOP_SR =>
        if i_arith = '1' then
          shifter_res <= unsigned(signed(i_src1) sra to_integer(unsigned(i_shamt)));
        else
          shifter_res <= unsigned(i_src1) srl to_integer(unsigned(i_shamt));
        end if;
      when others => shifter_res <= unsigned(i_src1) sll to_integer(unsigned(i_shamt));
    end case;
  end process p_shift;

  ------------------------------------------------------------------------------
  -- ADDER
  ------------------------------------------------------------------------------
  u_adder : riscv_adder
    generic map (
      N => XLEN)
    port map (
      i_a    => i_src1,
      i_b    => i_src2,
      i_sign => i_sign,
      i_sub  => i_arith,
      o_sum  => adder_res);

  slt_res(XLEN-1 downto 1) <= (others => '0');
  slt_res(0) <= adder_res(XLEN);

  ------------------------------------------------------------------------------
  --  RESULT SELECTION
  ------------------------------------------------------------------------------
  p_res : process (all)
  begin
    case i_opcode is
      when ALUOP_ADD  => o_res <= adder_res(XLEN-1 downto 0);    -- ADD[I]/SUB[I]
      when ALUOP_SL   => o_res <= std_logic_vector(shifter_res); -- SLL[I]
      when ALUOP_SR   => o_res <= std_logic_vector(shifter_res); -- SRL[I]/SRA[I]
      when ALUOP_SLT  => o_res <= slt_res;                       -- SLT[IU]
      when ALUOP_XOR  => o_res <= i_src1 xor i_src2;             -- XOR[I]
      when ALUOP_OR   => o_res <= i_src1 or i_src2;              -- OR[I]
      when ALUOP_AND  => o_res <= i_src1 and i_src2;             -- AND[I]
      when others     => o_res <= i_src2;                        -- Default
    end case;
  end process p_res;

end architecture beh;
