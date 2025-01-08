library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use     std.textio.all;                                                      
use     std.env.all;

library work;
use work.riscv_pkg.all;


entity tb_read_imem is
end entity tb_read_imem;

architecture tb of tb_read_imem is

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

    constant DEPTH : integer := 9;

    --Instruction memory signals 
    signal imem_en : std_logic :='1';
    signal imem_addr : std_logic_vector(31 downto 0);
    signal imem_read : std_logic_vector(31 downto 0) := (others => '0');
    signal imem_addr_div4 : std_logic_vector(DEPTH-1 downto 0) := (others => '0');

    -- Data memory signals  (not used)
    signal dmem_en : std_logic := '0' ;
    signal dmem_we : std_logic := '0';
    signal dmem_addr : std_logic_vector(DEPTH-1 downto 0):= (others => '0');
    signal dmem_read : std_logic_vector(31 downto 0) := (others => '0');
    signal dmem_write : std_logic_vector(31 downto 0):= (others => '0');
    signal dmem_addr_div4 : std_logic_vector(DEPTH-1 downto 0) := (others => '0');


    signal clk       : std_logic := '0';
    signal rstn      : std_logic := '1';
    signal stall     : std_logic := '0';
    signal flush     : std_logic := '0';
    signal transfert : std_logic := '0';
    signal target    : std_logic_vector(XLEN-1 downto 0) := (others => '0');
    signal pc_current: std_logic_vector(XLEN-1 downto 0);
    signal instr     : std_logic_vector(XLEN-1 downto 0);

    -- Clock generation constant
    constant CLK_PERIOD : time := 10 ns;

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

        MEM0 : entity work.dpm 
          generic map (
            WIDTH => 32,
            DEPTH => 9,
            RESET => 16#00000000#,
            INIT  => "riscv_basic.mem")
          port map (
            -- Port A
            i_a_clk   => clk,          -- Clock
            i_a_rstn  => rstn,         -- Reset Address
            i_a_en    => '1',            -- Port enable
            i_a_we    => '0',            -- Write enable
            i_a_addr  => imem_addr_div4(8 downto 0),     	 -- Address port			
            i_a_write => X"00000000",      	 -- Data write port
            o_a_read  => imem_read,-- Data read port
            -- Port B
            i_b_clk   => clk,          -- Clock
            i_b_rstn  => rstn,           -- Reset Address
            i_b_en    => dmem_en,            -- Port enable
            i_b_we    => dmem_we,                -- Write enable
            i_b_addr  => dmem_addr_div4(8 downto 0),      -- Address port  --Mettre adresse initiale a 1000 kb
            i_b_write => dmem_write,     -- Data write port
            o_b_read  => dmem_read    	 -- Data read port
        );

        imem_addr_div4 <= imem_addr(10 downto 2);
        dmem_addr_div4 <= imem_addr(10 downto 2); 

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
        
        rstn <= '0'; -- Assert reset
        wait for CLK_PERIOD/2;

        
        rstn <= '1'; 

        wait for 4*CLK_PERIOD+CLK_PERIOD/2;

        flush <= '1';
        transfert <='1';
        target <= "00000000000000000000000000000100";

        --stall<= '1';
        

        wait for CLK_PERIOD*1;

        flush <= '0';
        transfert <='0';
        target <= (others => '0');

        wait for CLK_PERIOD*3;

        stall<= '1';

        flush <= '0';
        transfert <='0';
        target <= (others => '0');

        wait for CLK_PERIOD;

        stall <= '0';
 



        
        
        
        

        wait;
    end process stimulus_process;



end architecture tb;
