library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_riscv_adder is
end entity tb_riscv_adder;

architecture test of tb_riscv_adder is

  -- Generic parameters
  constant N : integer := 32;

  -- Signals to connect to the adder
  signal i_a    : std_logic_vector(N-1 downto 0);
  signal i_b    : std_logic_vector(N-1 downto 0);
  signal i_sign : std_logic;  -- '0' for unsigned, '1' for signed
  signal i_sub  : std_logic;  -- '0' for addition, '1' for subtraction
  signal o_sum  : std_logic_vector(N downto 0);

  -- Instantiate the riscv_adder
  component riscv_adder
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
  end component;

begin

  -- Instantiate the Device Under Test (DUT)
  DUT: riscv_adder
    generic map (
      N => N
    )
    port map (
      i_a    => i_a,
      i_b    => i_b,
      i_sign => i_sign,
      i_sub  => i_sub,
      o_sum  => o_sum
    );

  -- Stimulus process with assertions and success messages
  stim_process : process
  begin

    -- Test 1: Unsigned Addition (10 + 20)
    i_a <= std_logic_vector(to_unsigned(10, N));
    i_b <= std_logic_vector(to_unsigned(20, N));
    i_sign <= '0';  -- Unsigned
    i_sub <= '0';   -- Addition
    wait for 40 ns;
    if o_sum = std_logic_vector(to_unsigned(30, N+1)) then
      assert false report "Test 1 Passed: Unsigned addition (10 + 20) = 30" severity note;
    else
      assert false report "Test 1 Failed: Unsigned addition (10 + 20) should be 30" severity error;
    end if;
    
    -- Test 2: Unsigned Subtraction (30 - 20)
    i_a <= std_logic_vector(to_unsigned(30, N));
    i_b <= std_logic_vector(to_unsigned(20, N));
    i_sign <= '0';  -- Unsigned
    i_sub <= '1';   -- Subtraction
    wait for 40 ns;
    if o_sum = std_logic_vector(to_unsigned(10, N+1)) then
      assert false report "Test 2 Passed: Unsigned subtraction (30 - 20) = 10" severity note;
    else
      assert false report "Test 2 Failed: Unsigned subtraction (30 - 20) should be 10" severity error;
    end if;

    -- Test 3: Unsigned Subtraction (15 - 20, expect underflow)
    i_a <= std_logic_vector(to_unsigned(15, N));
    i_b <= std_logic_vector(to_unsigned(20, N));
    i_sign <= '0';  -- Unsigned
    i_sub <= '1';   -- Subtraction
    wait for 40 ns;
    if o_sum = std_logic_vector(to_signed(-5, N+1)) then
        assert false report "Test 3 Passed: Unsigned subtraction (15 - 20) correctly underflows" severity note;
      else
        assert false report "Test 3 Failed: Unsigned subtraction (15 - 20) should underflow" severity error;
      end if;


    -- Test 4: Signed Addition (10 + 20)
    i_a <= std_logic_vector(to_signed(10, N));
    i_b <= std_logic_vector(to_signed(20, N));
    i_sign <= '1';  -- Signed
    i_sub <= '0';   -- Addition
    wait for 40 ns;
    if o_sum = std_logic_vector(to_signed(30, N+1)) then
      assert false report "Test 4 Passed: Signed addition (10 + 20) = 30" severity note;
    else
      assert false report "Test 4 Failed: Signed addition (10 + 20) should be 30" severity error;
    end if;

    -- Test 5: Signed Addition (10 + (-5))
    i_a <= std_logic_vector(to_signed(10, N));
    i_b <= std_logic_vector(to_signed(-5, N)); -- Corrected: use to_signed
    i_sign <= '1';  -- Signed
    i_sub <= '0';   -- Addition
    wait for 40 ns;
    if o_sum = std_logic_vector(to_signed(5, N+1)) then
      assert false report "Test 5 Passed: Signed addition (10 + -5) = 5" severity note;
    else
      assert false report "Test 5 Failed: Signed addition (10 + -5) should be 5" severity error;
    end if;

    -- Test 6: Signed Subtraction (-10 - 5)
    i_a <= std_logic_vector(to_signed(-10, N)); -- Corrected: use to_signed
    i_b <= std_logic_vector(to_signed(5, N));
    i_sign <= '1';  -- Signed
    i_sub <= '1';   -- Subtraction
    wait for 40 ns;
    if o_sum = std_logic_vector(to_signed(-15, N+1)) then
      assert false report "Test 6 Passed: Signed subtraction (-10 - 5) = -15" severity note;
    else
      assert false report "Test 6 Failed: Signed subtraction (-10 - 5) should be -15" severity error;
    end if;

    -- Test 7: Signed Subtraction (-10 - (-20))
    i_a <= std_logic_vector(to_signed(-10, N)); -- Corrected: use to_signed
    i_b <= std_logic_vector(to_signed(-20, N)); -- Corrected: use to_signed
    i_sign <= '1';  -- Signed
    i_sub <= '1';   -- Subtraction
    wait for 40 ns;
    if o_sum = std_logic_vector(to_signed(10, N+1)) then
      assert false report "Test 7 Passed: Signed subtraction (-10 - -20) = 10" severity note;
    else
      assert false report "Test 7 Failed: Signed subtraction (-10 - -20) should be 10" severity error;
    end if;

    -- End of simulation
    wait;
  end process;

end architecture test;
