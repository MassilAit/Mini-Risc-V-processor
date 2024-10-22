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
    i_sign : in  std_logic;  -- '0' for unsigned, '1' for signed
    i_sub  : in  std_logic;  -- '0' for addition, '1' for subtraction
    o_sum  : out std_logic_vector(N downto 0)
  );
end entity riscv_adder;

architecture beh of riscv_adder is

  -- Signals for unsigned versions of the inputs
  signal op1_u  : unsigned(N downto 0);
  signal op2_u  : unsigned(N downto 0);

  -- Signals for signed versions of the inputs
  signal op1_s  : signed(N downto 0);
  signal op2_s  : signed(N downto 0);

begin

  -- Extend the inputs to N+1 bits for both signed and unsigned operations
  op1_u <= resize(unsigned(i_a), N+1);
  op2_u <= resize(unsigned(i_b), N+1);

  op1_s <= resize(signed(i_a), N+1);
  op2_s <= resize(signed(i_b), N+1);

  -- Combinational process for performing the addition/subtraction
  process(i_sign, i_sub, op1_u, op2_u, op1_s, op2_s)
  begin
    if i_sign = '0' then
      -- Unsigned operation
      if i_sub = '0' then
        -- Unsigned addition
        o_sum <= std_logic_vector(op1_u + op2_u);
      else
        -- Unsigned subtraction
        o_sum <= std_logic_vector(op1_u - op2_u);
      end if;
    else
      -- Signed operation
      if i_sub = '0' then
        -- Signed addition
        o_sum <= std_logic_vector(op1_s + op2_s);
      else
        -- Signed subtraction
        o_sum <= std_logic_vector(op1_s - op2_s);
      end if;
    end if;
  end process;

end architecture beh;
