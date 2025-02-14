-------------------------------------------------------------------------------
-- Project  ELE8304 : Circuits intégrés à très grande échelle
-------------------------------------------------------------------------------
-- File     dpm.vhd
-- Author   Mickael Fiorentino  <mickael.fiorentino@polymtl.ca>
-- Lab      GRM - Polytechnique Montreal
-- Date     2019-08-09
-------------------------------------------------------------------------------
-- Brief    Dual-port memory
--          1-cycle read, 1-cycle write
--          Load memory content from file
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

library std;
use std.textio.all;

entity dpm is
  generic (
    WIDTH : integer := 32;
    DEPTH : integer := 10;
    RESET : integer := 16#00000000#;
    INIT  : string  := "memory.mem");
  port (
    -- Port A
    i_a_clk   : in  std_logic;                               -- Clock
    i_a_rstn  : in  std_logic;                               -- Reset Address
    i_a_en    : in  std_logic;                               -- Port enable
    i_a_we    : in  std_logic;                               -- Write enable
    i_a_addr  : in  std_logic_vector(DEPTH-1 downto 0);      -- Address port
    i_a_write : in  std_logic_vector(WIDTH-1 downto 0);      -- Data write port
    o_a_read  : out std_logic_vector(WIDTH-1 downto 0);      -- Data read port
    -- Port B
    i_b_clk   : in  std_logic;                               -- Clock
    i_b_rstn  : in  std_logic;                               -- Reset Address
    i_b_en    : in  std_logic;                               -- Port enable
    i_b_we    : in  std_logic;                               -- Write enable
    i_b_addr  : in  std_logic_vector(DEPTH-1 downto 0);      -- Address port
    i_b_write : in  std_logic_vector(WIDTH-1 downto 0);      -- Data write port
    o_b_read  : out std_logic_vector(WIDTH-1 downto 0));     -- Data read port
end entity dpm;

architecture beh of dpm is

  type t_memory is array(0 to 2**DEPTH-1) of std_logic_vector(WIDTH-1 downto 0);

  ------------------------------------------------------------------------------
  -- LOAD_MEM
  ------------------------------------------------------------------------------
  impure function load_mem(constant file_name : in string) return t_memory is
    file ramfile            : text;
    variable file_status    : file_open_status;
    variable L              : line    := null;
    variable Lnum           : natural := 0;
    variable read_ok        : boolean := true;
    variable at_char        : std_logic;
    variable next_address   : natural := 0;
    variable next_address_u : unsigned(WIDTH-1 downto 0);
    variable ram            : t_memory;
  begin
    -- Init RAM to 0
    ram := (others => (others => '0'));
    if (file_name /= "") then
      -- Open init file
      file_open(f         => ramfile, external_name => file_name,
                open_kind => read_mode, status => file_status);
      -- Check opening status
      assert file_status = open_ok
        report "load_mem: "  & " opening file "
        severity error;
      -- Read and parse memory file and fill ram with its content
      loop
        -- Exit condition
        exit when not read_ok or endfile(ramfile);
        -- Read line
        readline(ramfile, L);
        if L(L'left) = '@' then
          -- Read address
          read(L, at_char, read_ok);
          hread(L, next_address_u, read_ok);
          -- Check that read was ok
          assert read_ok = true
            report "load_mem: Error reading address at line: "
            & " in file " & file_name
            severity error;
          -- Update next_address
          next_address := to_integer(next_address_u);
        else
          -- Read data
          hread(L, ram(next_address), read_ok);
          -- Check that read was ok
          assert read_ok = true
            report "load_mem: Error reading data at address: "
            & " in file " & file_name
            severity error;
          -- Update next address
          next_address := next_address + 1;
        end if;
        -- Increment Line number
        Lnum := Lnum + 1;
      end loop;
      -- Close init file
      file_close(f => ramfile);
    end if;
    return ram;
  end function load_mem;

  signal mem      : t_memory := load_mem(INIT);
  signal a_addr_r : std_logic_vector(DEPTH-1 downto 0);
  signal b_addr_r : std_logic_vector(DEPTH-1 downto 0);

begin

  o_a_read <= mem(to_integer(unsigned(a_addr_r)));
  o_b_read <= mem(to_integer(unsigned(b_addr_r)));

  ------------------------------------------------------------------------------
  -- DPM
  ------------------------------------------------------------------------------
  p_dpm : process (i_a_clk, i_a_rstn, i_b_clk, i_b_rstn) is
  begin
    -- PORT A
    if i_a_rstn = '0' then
      a_addr_r <= (others => '0');
    elsif rising_edge(i_a_clk) then
      if i_a_en = '1' then
        if i_a_we = '1' then
          mem(to_integer(unsigned(i_a_addr))) <= i_a_write;
        end if;
        a_addr_r <= i_a_addr;
      end if;
    end if;
    -- PORT B
    if i_b_rstn = '0' then
      b_addr_r <= (others => '0');
    elsif rising_edge(i_b_clk) then
      if i_b_en = '1' then
        if i_b_we = '1' then
          mem(to_integer(unsigned(i_b_addr))) <= i_b_write;
        end if;
        b_addr_r <= i_b_addr;
      end if;
    end if;
  end process p_dpm;

end architecture beh;
