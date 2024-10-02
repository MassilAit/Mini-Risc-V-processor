-------------------------------------------------------------------------------
-- Project  ELE8304 : Circuits intégrés à très grande échelle
-------------------------------------------------------------------------------
-- File     riscv_rf.vhd
-- Author   Mickael Fiorentino  <mickael.fiorentino@polymtl.ca>
-- Lab      GRM - Polytechnique Montreal
-- Date     2019-08-09
-------------------------------------------------------------------------------
-- Brief    Register File
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.riscv_pkg.all;

entity riscv_rf is
  port (
    i_clk     : in  std_logic;
    i_rstn    : in  std_logic;
    i_we      : in  std_logic;
    i_addr_ra : in  std_logic_vector(REG_WIDTH-1 downto 0);
    o_data_ra : out std_logic_vector(XLEN-1 downto 0);
    i_addr_rb : in  std_logic_vector(REG_WIDTH-1 downto 0);
    o_data_rb : out std_logic_vector(XLEN-1 downto 0);
    i_addr_w  : in  std_logic_vector(REG_WIDTH-1 downto 0);
    i_data_w  : in  std_logic_vector(XLEN-1 downto 0));
end entity riscv_rf;

architecture beh of riscv_rf is

  -- Register file
  type rf_t is array(0 to 2**REG_WIDTH-1) of std_logic_vector(XLEN-1 downto 0);
  signal regfile  : rf_t;

  -- Forwading Data
  signal wb_data: std_logic_vector(XLEN-1 downto 0);
  signal ra : std_logic_vector(XLEN-1 downto 0);
  signal rb : std_logic_vector(XLEN-1 downto 0);

  -- Forwarding Control
  signal fwd_a : std_logic;
  signal fwd_b : std_logic;

begin

  --
  -- Output
  --
  o_data_ra <= wb_data when fwd_a = '1' else ra;
  o_data_rb <= wb_data when fwd_b = '1' else rb;

  --
  --  Register File
  --
  p_rf : process (i_clk, i_rstn) is
  begin
    if i_rstn = '0' then
      regfile <= (others => (others => '0'));
      ra      <= (others => '0');
      rb      <= (others => '0');
    elsif rising_edge(i_clk) then
      -- Write registers
      if (i_we = '1' and i_addr_w /= REG_X0) then
        regfile(to_integer(unsigned(i_addr_w))) <= i_data_w;
      end if;
      -- Read registers
      ra <= regfile(to_integer(unsigned(i_addr_ra)));
      rb <= regfile(to_integer(unsigned(i_addr_rb)));
    end if;
  end process p_rf;

  --
  -- Structural Hazard Handling : Forwarding WB value
  --
  p_fwd : process(i_clk, i_rstn) is
  begin
    if i_rstn = '0' then
      fwd_a   <= '0';
      fwd_b   <= '0';
      wb_data <= (others => '0');
    elsif rising_edge(i_clk) then
      -- Forward control Port A
      if (i_we = '1' and i_addr_ra /= REG_X0) then
        if (i_addr_ra = i_addr_w) then
          fwd_a <= '1';
        else
          fwd_a <= '0';
        end if;
      else
        fwd_a <= '0';
      end if;
      -- Forward control Port B
      if (i_we = '1' and i_addr_rb /= REG_X0) then
        if (i_addr_rb = i_addr_w) then
          fwd_b <= '1';
        else
          fwd_b <= '0';
        end if;
      else
        fwd_b <= '0';
      end if;
      -- Forward data
      wb_data <= i_data_w;
    end if;
  end process p_fwd;

end architecture beh;
