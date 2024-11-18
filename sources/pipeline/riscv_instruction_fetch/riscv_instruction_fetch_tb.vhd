library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.riscv_pkg.all;


entity tb_riscv_instruction_fetch is
end entity tb_riscv_instruction_fetch;

architecture tb of tb_riscv_instruction_fetch is

    component riscv_instruction_fetch
        port (
            i_clk       : in  std_logic;
            i_rstn      : in  std_logic;
            i_stall     : in  std_logic;
            i_flush     : in  std_logic;
            i_transfert : in  std_logic;
            i_target    : in  std_logic_vector(XLEN-1 downto 0);
            i_imem_read : in  std_logic_vector(XLEN-1 downto 0);
            o_imem_addr : out std_logic_vector(XLEN-1 downto 0);
            o_pc_current: out std_logic_vector(XLEN-1 downto 0);
            o_instr     : out std_logic_vector(XLEN-1 downto 0)
        );
    end component;


    signal clk       : std_logic := '0';
    signal rstn      : std_logic := '1';
    signal stall     : std_logic := '0';
    signal flush     : std_logic := '0';
    signal transfert : std_logic := '0';
    signal target    : std_logic_vector(XLEN-1 downto 0) := (others => '0');
    signal imem_read : std_logic_vector(XLEN-1 downto 0) := (others => '0');
    signal imem_addr : std_logic_vector(XLEN-1 downto 0);
    signal pc_current: std_logic_vector(XLEN-1 downto 0);
    signal instr     : std_logic_vector(XLEN-1 downto 0);

    -- Clock generation constant
    constant CLK_PERIOD : time := 100 ns;

begin
    -- Instantiate DUT
    DUT: riscv_instruction_fetch
        port map (
            i_clk       => clk,
            i_rstn      => rstn,
            i_stall     => stall,
            i_flush     => flush,
            i_transfert => transfert,
            i_target    => target,
            i_imem_read => imem_read,
            o_imem_addr => imem_addr,
            o_pc_current=>pc_current,
            o_instr     => instr
        );

    -- Clock Generation Process
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for CLK_PERIOD / 2;
            clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process clk_process;

-- Test Stimulus
    stimulus_process : process
    begin
        -- Test Case 1: Reset
        rstn <= '0'; -- Assert reset
        wait for CLK_PERIOD;
        
        -- Check reset behavior
        if imem_addr = std_logic_vector(to_unsigned(16#00000000#, XLEN)) then
            assert false report "Test Case 1 Passed: PC reset to the reset vector." severity note;
        else
            assert false report "Test Case 1 Failed: PC did not reset correctly." severity error;
        end if;

        rstn <= '1'; -- De-assert reset
        wait for CLK_PERIOD;

        -- Test Case 2: Normal Operation
        imem_read <= x"12345678"; 
        wait for CLK_PERIOD;
        
        if instr = x"12345678" then
            assert false report "Test Case 2 Passed: Instruction fetched successfully." severity note;
        else
            assert false report "Test Case 2 Failed: Instruction not fetched correctly." severity error;
        end if;


        -- Test Case 3: Stall Behavior
        stall <= '1'; -- Stall the pipeline
        imem_read <= x"DEADBEEF"; -- Change instruction
        wait for CLK_PERIOD;

        if instr = x"12345678" then
            assert false report "Test Case 3 Passed: Instruction held during stall." severity note;
        else
            assert false report "Test Case 3 Failed: Instruction changed during stall." severity error;
        end if;

        stall <= '0'; -- Release stall
        wait for CLK_PERIOD;

        if instr = x"DEADBEEF" then
            assert false report "Test Case 3.1 Passed: Instruction updated after stall release." severity note;
        else
            assert false report "Test Case 3.1 Failed: Instruction did not update after stall release." severity error;
        end if;


        -- Test Case 4: Flush Behavior
        flush <= '1'; -- Flush the pipeline
        wait for CLK_PERIOD;
        flush <= '0';

        if instr = x"00000013" then
            assert false report "Test Case 4 Passed: NOP instruction inserted during flush." severity note;
        else
            assert false report "Test Case 4 Failed: Incorrect behavior during flush." severity error;
        end if;

        -- Test Case 5: Transfert (Jump) Behavior
        transfert <= '1';
        target <= std_logic_vector(to_unsigned(16#00000010#, XLEN)); -- Jump target address
        wait for CLK_PERIOD;
        transfert <= '0';

        if imem_addr = std_logic_vector(to_unsigned(16#00000010#, XLEN)) then
            assert false report "Test Case 5 Passed: PC updated to jump target." severity note;
        else
            assert false report "Test Case 5 Failed: PC did not update correctly for jump." severity error;
        end if;

        -- Test Case 6: PC current Behavior

        if pc_current = std_logic_vector(to_unsigned(16#00000010#, XLEN)) then
            assert false report "Test Case 6 Passed: PC current do follows the PC value." severity note;
        else
            assert false report "Test Case 5 Failed: PC current do not follows the PC value." severity error;
        end if;

        wait;
    end process stimulus_process;



end architecture tb;
