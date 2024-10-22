library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.riscv_pkg.all;

entity tb_riscv_pc is
end entity tb_riscv_pc;

architecture test of tb_riscv_pc is


  -- Signals to connect to the Program Counter (PC)
  signal i_clk       : std_logic;                               -- Clock signal
  signal i_rstn      : std_logic;                               -- Reset (active low)
  signal i_stall     : std_logic;                               -- Stall signal
  signal i_transfert : std_logic;                               -- Transfer signal
  signal i_target    : std_logic_vector(XLEN-1 downto 0);       -- Target address
  signal o_pc        : std_logic_vector(XLEN-1 downto 0);       -- Program counter output

  -- Clock generation signals
  constant CLK_PERIOD : time := 20 ns;

  -- Instantiate the Program Counter (PC)
  component riscv_pc
    generic (RESET_VECTOR : natural := 16#00000000#);
    port (
      i_clk       : in  std_logic;
      i_rstn      : in  std_logic;
      i_stall     : in  std_logic;
      i_transfert : in  std_logic;
      i_target    : in  std_logic_vector(XLEN-1 downto 0);
      o_pc        : out std_logic_vector(XLEN-1 downto 0)
    );
  end component;

begin

  -- Instantiate the Device Under Test (DUT)
  DUT: riscv_pc
    port map (
      i_clk       => i_clk,
      i_rstn      => i_rstn,
      i_stall     => i_stall,
      i_transfert => i_transfert,
      i_target    => i_target,
      o_pc        => o_pc
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
     -- Test Case 1: Reset the PC
     i_rstn <= '0';  -- Activate reset
     i_stall <= '0'; -- Ensure no stall
     i_transfert <= '0'; -- No transfer
     i_target <= (others => '0'); -- Default target address
     wait for CLK_PERIOD; 
     
     if o_pc = std_logic_vector(to_unsigned(16#00000000#, XLEN)) then
       assert false report "Test Case 1 Passed: PC reset to the reset vector." severity note;
     else
       assert false report "Test Case 1 Failed: PC did not reset correctly." severity error;
     end if;

     i_rstn <= '1';  -- Deactivate reset
     wait for CLK_PERIOD;

    
     -- Test Case 2: Normal PC increment
     i_stall <= '0'; -- Ensure no stall
     i_transfert <= '0'; -- No transfer
     wait for CLK_PERIOD*3;


     if o_pc = std_logic_vector(to_unsigned(16#00000000#, XLEN) + 16) then
       assert false report "Test Case 2 Passed: PC incremented correctly over multiple cycles." severity note;
     else
       assert false report "Test Case 2 Failed: PC did not increment correctly over multiple cycles." severity error;
     end if;


 
     -- Test Case 3: i_transfert functionality
     i_transfert <= '1'; -- Enable transfer
     i_target <= std_logic_vector(to_unsigned(16#00001000#, XLEN)); -- Example target address
     wait for CLK_PERIOD;
 
     -- Assert PC has been set to the target address
     if o_pc = std_logic_vector(to_unsigned(16#00001000#, XLEN)) then
       assert false report "Test Case 3 Passed: PC correctly transferred to target address." severity note;
     else
       assert false report "Test Case 3 Failed: PC did not transfer to target address." severity error;
     end if;
 
     -- Disable transfer
     i_transfert <= '0';
 
     -- Test Case 4: i_stall test
     i_stall <= '1'; -- Enable stall
     wait for CLK_PERIOD * 3; -- Allow some clock cycles to pass while stalled
 
     -- Assert PC remains at the last value before stalling
     if o_pc = std_logic_vector(to_unsigned(16#00001000#, XLEN)) then
       assert false report "Test Case 4 Passed: PC correctly remained stalled." severity note;
     else
       assert false report "Test Case 4 Failed: PC should have remained stalled." severity error;
     end if;
 
     -- Disable stall and check for normal increment
     i_stall <= '0';
     wait for CLK_PERIOD;
 
     -- Assert PC increments after stall is removed
     if o_pc = std_logic_vector(to_unsigned(16#00001000#, XLEN) + 4) then
       assert false report "Test Case 4 Passed: PC incremented correctly after stall was removed." severity note;
     else
       assert false report "Test Case 4 Failed: PC did not increment correctly after stall was removed." severity error;
     end if;
 
     -- End of simulation
     wait;
   end process;

end architecture test;