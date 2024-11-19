library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.riscv_pkg.all;

entity tb_riscv_rf is
end entity tb_riscv_rf;

architecture test of tb_riscv_rf is

  constant CLK_PERIOD : time := 20 ns;       -- Clock period

  -- Signals to connect to the Register File (RF)
  signal i_clk     : std_logic;                               -- Clock signal
  signal i_rstn    : std_logic;                               -- Reset (active low)
  signal i_we      : std_logic;                               -- Write enable
  signal i_addr_ra : std_logic_vector(REG_WIDTH-1 downto 0);  -- Read address for port A
  signal o_data_ra : std_logic_vector(XLEN-1 downto 0);       -- Data output from port A
  signal i_addr_rb : std_logic_vector(REG_WIDTH-1 downto 0);  -- Read address for port B
  signal o_data_rb : std_logic_vector(XLEN-1 downto 0);       -- Data output from port B
  signal i_addr_w  : std_logic_vector(REG_WIDTH-1 downto 0);  -- Write address
  signal i_data_w  : std_logic_vector(XLEN-1 downto 0);       -- Data to write to the register

  -- Instantiate the Register File (RF)
  component riscv_rf
    port (
      i_clk     : in  std_logic;
      i_rstn    : in  std_logic;
      i_we      : in  std_logic;
      i_addr_ra : in  std_logic_vector(REG_WIDTH-1 downto 0);
      o_data_ra : out std_logic_vector(XLEN-1 downto 0);
      i_addr_rb : in  std_logic_vector(REG_WIDTH-1 downto 0);
      o_data_rb : out std_logic_vector(XLEN-1 downto 0);
      i_addr_w  : in  std_logic_vector(REG_WIDTH-1 downto 0);
      i_data_w  : in  std_logic_vector(XLEN-1 downto 0)
    );
  end component;

begin

  -- Instantiate the Device Under Test (DUT)
  DUT: riscv_rf
    port map (
      i_clk     => i_clk,
      i_rstn    => i_rstn,
      i_we      => i_we,
      i_addr_ra => i_addr_ra,
      o_data_ra => o_data_ra,
      i_addr_rb => i_addr_rb,
      o_data_rb => o_data_rb,
      i_addr_w  => i_addr_w,
      i_data_w  => i_data_w
    );

  -- Clock generation process
  clk_process : process
  begin
    i_clk <= '0';
    wait for CLK_PERIOD / 2;
    i_clk <= '1';
    wait for CLK_PERIOD / 2;
  end process;

  -- Stimulus process for test cases
  stim_process : process
  begin
    -- Test Case Initialization
    i_rstn <= '0';          -- Activate reset
    i_we <= '0';            -- Disable write
    i_addr_ra <= (others => '0'); -- Initialize read address A
    i_addr_rb <= (others => '0'); -- Initialize read address B
    i_addr_w <= (others => '0');  -- Initialize write address
    i_data_w <= (others => '0');  -- Initialize write data
    wait for CLK_PERIOD;
    i_rstn <= '1';          -- Deactivate reset
    wait for CLK_PERIOD;

     -- Test 1: Write value 1 to register 1
     i_we <= '1';
     i_addr_w <= std_logic_vector(to_unsigned(1, REG_WIDTH)); -- Write address = 1
     i_data_w <= std_logic_vector(to_unsigned(1, XLEN)); -- Write data = 1
     wait for CLK_PERIOD;
 
     -- Read from register 1 to confirm the write
     i_we <= '0';
     i_addr_ra <= std_logic_vector(to_unsigned(1, REG_WIDTH));
     wait for CLK_PERIOD;
 
     if o_data_ra = std_logic_vector(to_unsigned(1, XLEN)) then
       assert false report "Test 1 Passed: Register 1 correctly written with value 1." severity note;
     else
       assert false report "Test 1 Failed: Register 1 did not correctly store value 1." severity error;
     end if;


     -- Test 2: Write value 2 to register 2
    i_we <= '1';
    i_addr_w <= std_logic_vector(to_unsigned(2, REG_WIDTH)); -- Write address = 2
    i_data_w <= std_logic_vector(to_unsigned(2, XLEN)); -- Write data = 2
    wait for CLK_PERIOD;

    -- Read from register 2 to confirm the write
    i_we <= '0';
    i_addr_ra <= std_logic_vector(to_unsigned(2, REG_WIDTH));
    wait for CLK_PERIOD*2;

    if o_data_ra = std_logic_vector(to_unsigned(2, XLEN)) then
      assert false report "Test 2 Passed: Register 2 correctly written with value 2." severity note;
    else
      assert false report "Test 2 Failed: Register 2 did not correctly store value 2." severity error;
    end if;

    -- Test 3: Attempt to write value 1 to register 0 (should fail)
    i_we <= '1';
    i_addr_w <= std_logic_vector(to_unsigned(0, REG_WIDTH)); -- Write address = 0
    i_data_w <= std_logic_vector(to_unsigned(1, XLEN)); -- Write data = 1
    wait for CLK_PERIOD;

    -- Read from register 0 to confirm no write happened
    i_we <= '0';
    i_addr_ra <= std_logic_vector(to_unsigned(0, REG_WIDTH));
    wait for CLK_PERIOD*2;

    if o_data_ra = std_logic_vector(to_unsigned(0, XLEN)) then
      assert false report "Test 3 Passed: Register 0 remains 0 as expected." severity note;
    else
      assert false report "Test 3 Failed: Register 0 was incorrectly modified." severity error;
    end if;

    -- Test 4: Attempt to write with write enable off (should not write)
    i_we <= '0'; -- Disable write enable
    i_addr_w <= std_logic_vector(to_unsigned(3, REG_WIDTH)); -- Write address = 3
    i_data_w <= std_logic_vector(to_unsigned(3, XLEN)); -- Write data = 3
    wait for CLK_PERIOD;

    -- Read from register 3 to confirm no write happened
    i_addr_ra <= std_logic_vector(to_unsigned(3, REG_WIDTH));
    wait for CLK_PERIOD*2;

    if o_data_ra = std_logic_vector(to_unsigned(0, XLEN)) then
      assert false report "Test 4 Passed: Register 3 was not written to when write enable was off." severity note;
    else
      assert false report "Test 4 Failed: Register 3 was incorrectly written to." severity error;
    end if;


    -- Test 5: Asynchronous reset, confirm all registers reset to 0
    i_rstn <= '0'; -- Activate reset
    wait for CLK_PERIOD/2;
    i_rstn <= '1'; -- Deactivate reset

    i_addr_ra <= std_logic_vector(to_unsigned(1, REG_WIDTH));
    i_addr_rb <= std_logic_vector(to_unsigned(2, REG_WIDTH));
    wait for CLK_PERIOD*2;
    
    if o_data_ra = std_logic_vector(to_unsigned(0, XLEN)) and  o_data_rb = std_logic_vector(to_unsigned(0, XLEN)) then
        assert false report "Test 5 Passed: All registers correctly reset to 0." severity note;
    
    else
        assert false report "Test 5 Failed: Not all registers reset to 0." severity error;
    end if;

    wait;
  end process;

end architecture test;