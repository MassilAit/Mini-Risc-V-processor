library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.riscv_pkg.all;

entity tb_riscv_decode is
end entity;

architecture testbench of tb_riscv_decode is
    -- Constantes
    constant CLK_PERIOD : time := 10 ns;
    constant XLEN       : integer := 32;
    constant REG        : integer := 5;

    -- Signaux pour connecter au DUT
    signal i_clk         : std_logic := '0';
    signal i_rstn        : std_logic := '1';
    signal i_instruction : std_logic_vector(XLEN-1 downto 0) := (others => '0');
    signal i_pc          : std_logic_vector(XLEN-1 downto 0) := (others => '0');
    signal i_we          : std_logic := '0';
    signal i_wb_addr     : std_logic_vector(REG-1 downto 0) := (others => '0');
    signal i_wb_data     : std_logic_vector(XLEN-1 downto 0) := (others => '0');

    signal o_rs1_data    : std_logic_vector(XLEN-1 downto 0);
    signal o_rs2_data    : std_logic_vector(XLEN-1 downto 0);
    signal o_imm         : std_logic_vector(XLEN-1 downto 0);
    signal o_shamt       : std_logic_vector(4 downto 0);
    signal o_rd_addr     : std_logic_vector(REG-1 downto 0);
    signal o_control     : std_logic_vector(15 downto 0);

    -- Instance du DUT
    component riscv_decode is
        generic (
            XLEN : integer := 32;
            REG  : integer := 5
        );
        port (
            i_clk         : in  std_logic;
            i_rstn        : in  std_logic;
            i_instruction : in  std_logic_vector(XLEN-1 downto 0);
            i_pc          : in  std_logic_vector(XLEN-1 downto 0);
            i_we          : in  std_logic;
            i_wb_addr     : in  std_logic_vector(REG-1 downto 0);
            i_wb_data     : in  std_logic_vector(XLEN-1 downto 0);
            o_rs1_data    : out std_logic_vector(XLEN-1 downto 0);
            o_rs2_data    : out std_logic_vector(XLEN-1 downto 0);
            o_imm         : out std_logic_vector(XLEN-1 downto 0);
            o_shamt       : out std_logic_vector(4 downto 0);
            o_rd_addr     : out std_logic_vector(REG-1 downto 0);
            o_control     : out std_logic_vector(15 downto 0)
        );
    end component;

begin
    -- Instanciation du DUT
    uut : riscv_decode
        port map (
            i_clk         => i_clk,
            i_rstn        => i_rstn,
            i_instruction => i_instruction,
            i_pc          => i_pc,
            i_we          => i_we,
            i_wb_addr     => i_wb_addr,
            i_wb_data     => i_wb_data,
            o_rs1_data    => o_rs1_data,
            o_rs2_data    => o_rs2_data,
            o_imm         => o_imm,
            o_shamt       => o_shamt,
            o_rd_addr     => o_rd_addr,
            o_control     => o_control
        );

    -- Génération de l'horloge
    process
    begin
        while true loop
            i_clk <= '0';
            wait for CLK_PERIOD / 2;
            i_clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;

    -- Stimuli
    process
    begin
        -- Initialisation et Reset
        i_rstn <= '0';
        wait for CLK_PERIOD;
        i_rstn <= '1';

        -- Test 1 : R-Type Instruction (ADD)
        i_instruction <= x"00B50533"; -- ADD x10, x10, x11
        wait for CLK_PERIOD;
        assert o_rd_addr = "01010" report "R-Type rd extraction failed" severity error;
        assert o_control(0) = '1' report "R-Type control signal failed" severity error;

        -- Test 2 : I-Type Instruction (ADDI)
        i_instruction <= x"00450513"; -- ADDI x10, x10, 4
        wait for CLK_PERIOD;
        assert o_rd_addr = "01010" report "I-Type rd extraction failed" severity error;
        assert o_imm = x"00000004" report "I-Type immediate failed" severity error;
        assert o_control(1) = '1' report "I-Type control signal failed" severity error;

        -- Test 3 : S-Type Instruction (SW)
        i_instruction <= x"00A52023"; -- SW x10, 0(x10)
        wait for CLK_PERIOD;
        assert o_control(3) = '1' report "S-Type control signal failed" severity error;

        -- Test 4 : B-Type Instruction (BEQ)
        i_instruction <= x"00A50863"; -- BEQ x10, x10, offset
        wait for CLK_PERIOD;
        assert o_control(4) = '1' report "B-Type control signal failed" severity error;

        -- Test 5 : Lecture dans le banc de registres
        i_we      <= '1';
        i_wb_addr <= "01010"; -- x10
        i_wb_data <= x"12345678"; -- Écriture dans x10
        wait for CLK_PERIOD;
        i_we <= '0'; -- Désactivation du WB
        i_instruction <= x"00450513"; -- ADDI x10, x10, 4
        wait for CLK_PERIOD;
        assert o_rs1_data = x"12345678" report "Register read failed for rs1" severity error;

        -- Fin du test
        report "All tests passed successfully" severity note;
        wait;
    end process;

end architecture;
