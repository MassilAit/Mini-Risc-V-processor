library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.riscv_pkg.all;

entity tb_riscv_write_back is
end tb_riscv_write_back;

architecture tb of tb_riscv_write_back is

    constant CLK_PERIOD : time := 10 ns; -- Clock period

    -- DUT Signals
    signal i_load_data  : std_logic_vector(XLEN-1 downto 0);
    signal i_alu_result : std_logic_vector(XLEN-1 downto 0);
    signal i_wb         : std_logic;
    signal i_rd_addr    : std_logic_vector(REG_WIDTH-1 downto 0);
    signal i_re_wb      : std_logic;

    signal o_wb         : std_logic;
    signal o_rd_addr    : std_logic_vector(REG_WIDTH-1 downto 0);
    signal o_rd_data    : std_logic_vector(XLEN-1 downto 0);

    signal o_wb_rd_addr : std_logic_vector(REG_WIDTH-1 downto 0); 
    signal o_wb_rd_data : std_logic_vector(XLEN-1 downto 0); 
    signal o_wb_rd_wb   : std_logic;

begin
    -- Instantiate the DUT
    DUT: entity work.riscv_write_back
        port map (
            i_load_data  => i_load_data,
            i_alu_result => i_alu_result,
            i_wb         => i_wb,
            i_rd_addr    => i_rd_addr,
            i_re_wb      => i_re_wb,
            o_wb         => o_wb,
            o_rd_addr    => o_rd_addr,
            o_rd_data    => o_rd_data,
            o_wb_rd_addr => o_wb_rd_addr,
            o_wb_rd_data => o_wb_rd_data,
            o_wb_rd_wb   => o_wb_rd_wb
        );

    -- Test Process
    process
    begin
        -- Initialize inputs
        i_load_data  <= (others => '0');
        i_alu_result <= (others => '0');
        i_wb         <= '0';
        i_rd_addr    <= (others => '0');
        i_re_wb      <= '0';

        wait for CLK_PERIOD;

        -- Test 1: Select ALU result (i_re_wb = '0')

        assert false report "Test 1: Select ALU result (i_re_wb = '0')" severity note;
        i_alu_result <= x"12345678";
        i_load_data  <= x"DEADBEEF";
        i_re_wb      <= '0';
        i_wb         <= '1';
        i_rd_addr    <= "01010";
        wait for CLK_PERIOD;

        assert o_rd_data = x"12345678" report "Test 1 Failed: ALU result not selected" severity error;
        assert o_rd_addr = "01010" report "Test 1 Failed: RD address incorrect" severity error;

        -- Test 2: Select load data (i_re_wb = '1')
        assert false report "Test 2: Select load data (i_re_wb = '1')" severity note;
        i_re_wb <= '1';
        wait for CLK_PERIOD;

        assert o_rd_data = x"DEADBEEF" report "Test 2 Failed: Memory data not selected" severity error;
        assert o_rd_addr = "01010" report "Test 2 Failed: RD address incorrect" severity error;

        -- Test 3: Write-back enable (i_wb)
        assert false report "Test 3: Write-back enable (i_wb)" severity note;
        i_wb <= '0';
        wait for CLK_PERIOD;

        assert o_wb = '0' report "Test 3 Failed: Write-back signal should be disabled" severity error;

        i_wb <= '1';
        wait for CLK_PERIOD;

        assert o_wb = '1' report "Test 3 Failed: Write-back signal should be enabled" severity error;

        -- Stop simulation
        wait;
    end process;

end architecture tb;
