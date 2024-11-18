library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.riscv_pkg.all;

entity tb_riscv_execute is
end entity;

architecture testbench of tb_riscv_execute is
    -- Constantes
    constant CLK_PERIOD : time := 10 ns;
    constant XLEN       : integer := 32;
    constant ALUOP_WIDTH : integer := 4;
    constant SHAMT_WIDTH : integer := 5;

    -- Signaux pour connecter au DUT
    signal i_clk         : std_logic := '0';
    signal i_rstn        : std_logic := '1';
    signal i_pc          : std_logic_vector(XLEN-1 downto 0) := (others => '0');
    signal i_rs1_data    : std_logic_vector(XLEN-1 downto 0) := (others => '0');
    signal i_rs2_data    : std_logic_vector(XLEN-1 downto 0) := (others => '0');
    signal i_imm         : std_logic_vector(XLEN-1 downto 0) := (others => '0');
    signal i_shamt       : std_logic_vector(SHAMT_WIDTH-1 downto 0) := (others => '0');
    signal i_control     : std_logic_vector(15 downto 0) := (others => '0');
    signal i_rd_addr     : std_logic_vector(4 downto 0) := (others => '0');

    signal o_alu_result  : std_logic_vector(XLEN-1 downto 0);
    signal o_target      : std_logic_vector(XLEN-1 downto 0);
    signal o_branch_taken: std_logic;
    signal o_rd_addr     : std_logic_vector(4 downto 0);

    -- Instance du DUT
    component riscv_execute is
        generic (
            XLEN        : integer := 32;
            ALUOP_WIDTH : integer := 4;
            SHAMT_WIDTH : integer := 5
        );
        port (
            i_clk         : in  std_logic;
            i_rstn        : in  std_logic;
            i_pc          : in  std_logic_vector(XLEN-1 downto 0);
            i_rs1_data    : in  std_logic_vector(XLEN-1 downto 0);
            i_rs2_data    : in  std_logic_vector(XLEN-1 downto 0);
            i_imm         : in  std_logic_vector(XLEN-1 downto 0);
            i_shamt       : in  std_logic_vector(SHAMT_WIDTH-1 downto 0);
            i_control     : in  std_logic_vector(15 downto 0);
            i_rd_addr     : in  std_logic_vector(4 downto 0);
            o_alu_result  : out std_logic_vector(XLEN-1 downto 0);
            o_target      : out std_logic_vector(XLEN-1 downto 0);
            o_branch_taken: out std_logic;
            o_rd_addr     : out std_logic_vector(4 downto 0)
        );
    end component;

begin
    -- Instanciation du DUT
    uut : riscv_execute
        port map (
            i_clk         => i_clk,
            i_rstn        => i_rstn,
            i_pc          => i_pc,
            i_rs1_data    => i_rs1_data,
            i_rs2_data    => i_rs2_data,
            i_imm         => i_imm,
            i_shamt       => i_shamt,
            i_control     => i_control,
            i_rd_addr     => i_rd_addr,
            o_alu_result  => o_alu_result,
            o_target      => o_target,
            o_branch_taken=> o_branch_taken,
            o_rd_addr     => o_rd_addr
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

        -- Test 1 : ADD (R-Type)
        i_rs1_data <= x"00000005";
        i_rs2_data <= x"00000003";
        i_control <= "0000000000000001"; -- ALU op: ADD
        wait for CLK_PERIOD;
        assert o_alu_result = x"00000008" report "ADD operation failed" severity error;

        -- Test 2 : SUB (R-Type)
        i_control <= "0000000000000001"; -- ALU op: SUB
        wait for CLK_PERIOD;
        assert o_alu_result = x"00000002" report "SUB operation failed" severity error;

        -- Test 3 : AND (R-Type)
        i_control <= "0000000000000010"; -- ALU op: AND
        i_rs1_data <= x"0000000F";
        i_rs2_data <= x"00000003";
        wait for CLK_PERIOD;
        assert o_alu_result = x"00000003" report "AND operation failed" severity error;

        -- Test 4 : OR (R-Type)
        i_control <= "0000000000000011"; -- ALU op: OR
        wait for CLK_PERIOD;
        assert o_alu_result = x"0000000F" report "OR operation failed" severity error;

        -- Test 5 : Branch Equal (BEQ)
        i_control <= "0000000000010000"; -- Branch
        i_rs1_data <= x"0000000A";
        i_rs2_data <= x"0000000A";
        i_imm <= x"00000004"; -- Offset
        i_pc <= x"00000010";
        wait for CLK_PERIOD;
        assert o_branch_taken = '1' report "Branch taken failed" severity error;
        assert o_target = x"00000014" report "Branch target calculation failed" severity error;

        -- Test 6 : Shift Left Logical (SLL)
        i_control <= "0000000000000100"; -- SLL
        i_rs1_data <= x"00000001";
        i_shamt <= "00011"; -- Shift by 3
        wait for CLK_PERIOD;
        assert o_alu_result = x"00000008" report "SLL operation failed" severity error;

        -- Fin du test
        report "All tests passed successfully" severity note;
        wait;
    end process;

end architecture;
