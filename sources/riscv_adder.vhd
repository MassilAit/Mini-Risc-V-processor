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

  -- Signals with bit extended
  signal op1  : std_logic_vector(N downto 0);
  signal op2  : std_logic_vector(N downto 0);

begin


-- Process to extend the bit and do the second complement
bit_extension: process(i_a, i_b, i_sign,i_sub)

  variable b_temp : std_logic_vector(N downto 0); 

begin
  if i_sign='1' then
    op1 <= (i_a(N-1) & i_a);
    b_temp := (i_b(N-1) & i_b);
  
  else
    op1 <= ('0' & i_a);
    b_temp := ('0' & i_b);
    
  end if;

  if i_sub='1' then
    op2 <= std_logic_vector(-signed(b_temp));
  
  else
    op2 <= b_temp;
    
  end if;
  
end process bit_extension;


--Process to do the addition
adder: process(op1,op2)
  variable carry_1 : std_logic_vector(N downto 0);
  variable carry_2 : std_logic_vector(N downto 0);
  variable s       : std_logic_vector(N downto 0);

begin
  s(0) := op1(0) xor op2(0);
  carry_1(0) := op1(0) and op2(0);
  carry_2(0) := '0';
  o_sum(0) <= s(0);

  for i in 1 to N loop

    s(i) := op1(i) xor op2(i);
    carry_1(i) := op1(i) and op2(i);

    o_sum(i) <= s(i) xor (carry_1(i-1) or carry_2(i-1));
    carry_2(i) := s(i) and (carry_1(i-1) or carry_2(i-1));

  end loop;


  
end process adder;


end architecture beh;
