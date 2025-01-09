-------------------------------------------------------------------------------
-- Project  ELE8304 : Circuits intégrés à très grande échelle
-------------------------------------------------------------------------------
-- File     riscv_pc.vhd
-- Author   Mickael Fiorentino  <mickael.fiorentino@polymtl.ca>
-- Lab      GRM - Polytechnique Montreal
-- Date     2019-08-09
-------------------------------------------------------------------------------
-- Brief    Program Counter
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.riscv_pkg.all;

entity riscv_pc is
  generic (RESET_VECTOR : natural := 16#00000000#);
  port (
    i_clk       : in  std_logic;
    i_rstn      : in  std_logic;
    i_stall     : in  std_logic;
    i_transfert : in  std_logic;
    i_target    : in  std_logic_vector(XLEN-1 downto 0);
    o_pc        : out std_logic_vector(XLEN-1 downto 0));
end entity riscv_pc;

architecture beh of riscv_pc is

  signal pc : unsigned(XLEN-1 downto 0);

begin

  -- Output
  o_pc <= std_logic_vector(pc);

  -- Flop
  p_pc : process(i_clk, i_rstn)
  begin
    if i_rstn = '0' then
      pc <= unsigned(RESET);
    elsif rising_edge(i_clk) then
      if i_stall = '1' then
        pc <= pc;
      elsif i_transfert = '1' then
        pc <= unsigned(i_target);
      else
        pc <= pc + ADDR_INCR;
      end if;
    end if;
  end process p_pc;

end architecture beh;
