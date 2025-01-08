library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


library work;
use work.riscv_pkg.all;

entity tb_riscv_memory_acces is
end entity tb_riscv_memory_acces;

architecture testbench of tb_riscv_memory_acces is


    constant CLK_PERIOD : time := 10 ns; -- Clock period

    -- DUT Signals
    signal i_clk       : std_logic := '0';
    signal i_rstn      : std_logic := '0';

    signal i_load_data : std_logic_vector(XLEN-1 downto 0);
    signal o_store_data : std_logic_vector(XLEN-1 downto 0);
    signal o_mem_adress : std_logic_vector(XLEN-1 downto 0);
    signal o_we        : std_logic;
    signal o_re        : std_logic;

    signal i_we        : std_logic;
    signal i_re        : std_logic;

    signal i_alu_result : std_logic_vector(XLEN-1 downto 0);
    signal i_wb        : std_logic;
    signal i_rd_addr   : std_logic_vector(REG_WIDTH-1 downto 0);
    signal i_store_data : std_logic_vector(XLEN-1 downto 0);

    signal o_load_data : std_logic_vector(XLEN-1 downto 0);
    signal o_alu_result : std_logic_vector(XLEN-1 downto 0);
    signal o_wb        : std_logic;
    signal o_rd_addr   : std_logic_vector(REG_WIDTH-1 downto 0);
    signal o_re_wb     : std_logic;

    signal o_mem_rd_addr : std_logic_vector(REG_WIDTH-1 downto 0); 
    signal o_mem_rd_data : std_logic_vector(XLEN-1 downto 0); 
    signal o_mem_rd_wb   : std_logic;
    signal o_mem_rd_re   : std_logic;

begin

    -- Instantiate the DUT
    DUT: entity work.riscv_memory_acces
        port map (
            i_clk => i_clk,
            i_rstn => i_rstn,

            i_load_data => i_load_data,
            o_store_data => o_store_data,
            o_mem_adress => o_mem_adress,
            o_we => o_we,
            o_re => o_re,

            i_we => i_we,
            i_re => i_re,
            i_alu_result => i_alu_result,
            i_wb => i_wb,
            i_rd_addr => i_rd_addr,
            i_store_data => i_store_data,

            o_load_data => o_load_data,
            o_alu_result => o_alu_result,
            o_wb => o_wb,
            o_rd_addr => o_rd_addr,
            o_re_wb => o_re_wb,

            o_mem_rd_addr => o_mem_rd_addr,
            o_mem_rd_data => o_mem_rd_data,
            o_mem_rd_wb   => o_mem_rd_wb,
            o_mem_rd_re   => o_mem_rd_re
        );

            -- Clock generation
    clk_gen: process
    begin
        while true loop
            i_clk <= '1';
            wait for CLK_PERIOD / 2;
            i_clk <= '0';
            wait for CLK_PERIOD / 2;
        end loop;
    end process clk_gen;

    -- Stimulus process
    stim_proc: process
    begin
        -- Initialize inputs
        i_rstn <= '0';
        i_we <= '0';
        i_re <= '0';
        i_alu_result <= (others => '0');
        i_wb <= '0';
        i_rd_addr <= (others => '0');
        i_store_data <= (others => '0');
        i_load_data <= (others => '0');

        wait for CLK_PERIOD;

        -- Release reset
        i_rstn <= '1';
        wait for CLK_PERIOD;

        -- Test Case 1: Write to memory

        assert false report "Test Case 1 Write to memory." severity note;

        i_we <= '1';
        i_alu_result <= x"00000004";
        i_store_data <= x"DEADBEEF";

        wait for CLK_PERIOD;

        assert o_store_data = x"DEADBEEF" report "Test Case 1 Failed: Incorrect store data" severity error;
        assert o_mem_adress = x"00000004" report "Test Case 1 Failed: Incorrect memory address" severity error;


        -- Test Case 2: Read from memory
        assert false report "Test Case 2 Read from memory." severity note;
        i_we <= '0';
        i_re <= '1';
        i_load_data <= x"CAFEBABE";

        wait for CLK_PERIOD;

        assert o_load_data = x"CAFEBABE" report "Test Case 2 Failed: Incorrect load data" severity error;

         -- Test Case 3: Pass-through ALU result to WB
         assert false report "Test Case 3 Pass ALU result to WB" severity note;
         i_alu_result <= x"12345678";
         i_wb <= '1';
         i_re <= '0';
         i_rd_addr <= "01010";

         wait for CLK_PERIOD/100;

         assert o_mem_rd_data = x"12345678" report "Test Case 3 Failed: forwarding data" severity error;
         assert o_mem_rd_addr = "01010" report "Test Case 3 Failed: forwarding adress" severity error;
         assert o_mem_rd_wb = '1' report "Test Case 3 Failed: forwarding write back" severity error;
         assert o_mem_rd_re = '0' report "Test Case 3 Failed: forwarding read enable" severity error;
 
         wait for CLK_PERIOD;
 
         assert  i_alu_result= x"12345678" report "Test Case 4 Failed: Incorrect ALU result" severity error;
         assert o_rd_addr = "01010" report "Test Case 4 Failed: Incorrect rd_addr" severity error;
         assert o_wb = '1' report "Test Case 4 Failed: Incorrect WB signal" severity error;


        -- Stop simulation
        wait;
    end process stim_proc;


end architecture testbench;

