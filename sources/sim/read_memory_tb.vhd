library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.riscv_pkg.all;


entity tb_read_memory is
end entity tb_read_memory;

architecture testbench of tb_read_memory is 

    constant DEPTH : integer := 9;

    --Instruction memory signals (not used)
    signal imem_en : std_logic := '0';
    signal imem_addr : std_logic_vector(DEPTH-1 downto 0):= (others => '0');
    signal imem_read : std_logic_vector(31 downto 0) := (others => '0');

    -- Data memory signals 

    signal dmem_en : std_logic;
    signal dmem_we : std_logic;
    signal dmem_addr : std_logic_vector(DEPTH-1 downto 0);
    signal dmem_read : std_logic_vector(31 downto 0);
    signal dmem_write : std_logic_vector(31 downto 0);


    constant CLK_PERIOD : time := 10 ns; -- Clock period

    -- DUT Signals
    signal i_clk       : std_logic := '0';
    signal i_rstn      : std_logic := '0';

    signal o_mem_adress : std_logic_vector(XLEN-1 downto 0);

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

            i_load_data => dmem_read,
            o_store_data => dmem_write,
            o_mem_adress => o_mem_adress,
            o_we => dmem_we,
            o_re => dmem_en,

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

        MEM0 : entity work.dpm 
          generic map (
            WIDTH => 32,
            DEPTH => 9,
            RESET => 16#00000000#,
            INIT  => "riscv_basic.mem")
          port map (
            -- Port A
            i_a_clk   => i_clk,          -- Clock
            i_a_rstn  => i_rstn,         -- Reset Address
            i_a_en    => imem_en,            -- Port enable
            i_a_we    => '0',            -- Write enable
            i_a_addr  => imem_addr,     	 -- Address port			
            i_a_write => X"00000000",      	 -- Data write port
            o_a_read  => imem_read,-- Data read port
            -- Port B
            i_b_clk   => i_clk,          -- Clock
            i_b_rstn  => i_rstn,           -- Reset Address
            i_b_en    => dmem_en,            -- Port enable
            i_b_we    => dmem_we,                -- Write enable
            i_b_addr  => o_mem_adress(10 downto 2),      -- Address port  --Mettre adresse initiale a 1000 kb
            i_b_write => dmem_write,     -- Data write port
            o_b_read  => dmem_read    	 -- Data read port
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

        wait for CLK_PERIOD;

        
        i_rstn <= '1';
        i_we <= '0';
        i_re <= '0';
        i_alu_result <= (others => '0');
        i_wb <= '0';
        i_rd_addr <= (others => '0');
        i_store_data <= (others => '0');

        wait for CLK_PERIOD;

        -- Write to memory
        i_we <= '1';
        i_re <= '0';
        i_alu_result <= x"00000010"; -- Address
        i_store_data <= x"DEADBEEF"; -- Data to write
        wait for CLK_PERIOD;

        -- Read from memory
        i_we <= '0';
        i_re <= '1';
        i_alu_result <= x"00000010"; -- Address
        wait for CLK_PERIOD;

        -- Validate read data
        assert o_load_data = x"DEADBEEF"
          report "Memory read/write mismatch!" severity error;

        -- Stop simulation
        wait;

        -- Stop simulation
        wait;
    end process stim_proc;


end architecture testbench;