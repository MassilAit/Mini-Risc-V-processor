-------------------------------------------------------------------------------
-- Project  ELE8304 : Circuits intégrés à très grande échelle
-- Polytechnique Montréal
-------------------------------------------------------------------------------
-- File     riscv_adder.vhd
-- Author   Théo Dupuis  <theo.dupuis@polymtl.ca>
-- Date     2022-08-27
-------------------------------------------------------------------------------
-- Description 	adder with ripple-carry
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity riscv_adder is
  generic (
    N : positive := 32
  );
  port (
    i_a    : in  std_logic_vector(N-1 downto 0);
    i_b    : in  std_logic_vector(N-1 downto 0);
    i_sign : in  std_logic;
    i_sub  : in  std_logic;
    o_sum  : out std_logic_vector(N downto 0)
  );
end entity riscv_adder;

architecture beh of riscv_adder is
--------------------------------------
--------- COMPLETE FROM HERE ---------


begin











end architecture beh;
