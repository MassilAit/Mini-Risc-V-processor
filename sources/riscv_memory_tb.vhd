library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.riscv_pkg.all;

entity tb_riscv_memory is
end entity;

architecture testbench of tb_riscv_memory is
    -- Constantes
    constant CLK_PERIOD : time := 10 ns;
    constant XLEN       : integer := 32;

    -- Signaux pour connecter au DUT
    signal i_clk         : std_logic := '0';
    signal i_rstn        : std_logic := '1';
    signal i_alu_result  : std_logic_vector(XLEN-1 downto 0) := (others => '0');
    signal i_rs2_data    : std_logic_vector(XLEN-1 downto 0) := (others => '0');
    signal i_control     : std_logic_vector(15 downto 0) := (others => '0');
    signal i_rd_addr     : std_logic_vector(4 downto 0) := (others => '0');

    signal o_mem_data    : std_logic_vector(XLEN-1 downto 0);
    signal o_alu_result  : std_logic_vector(XLEN-1 downto 0);
    signal o_rd_addr     : std_logic_vector(4 downto 0);

    signal o_mem_addr    : std_logic_vector(XLEN-1 downto 0);
    signal o_mem_write   : std_logic;
    signal o_mem_read    : std_logic;
    signal o_mem_wdata   : std_logic_vector(XLEN-1 downto 0);
    signal i_mem_rdata   : std_logic_vector(XLEN-1 downto 0) := (others => '0');

    -- Instance du DUT
    component riscv_memory is
        generic (
            XLEN : integer := 32
        );
        port (
            -- Entrées
            i_clk         : in  std_logic;
            i_rstn        : in  std_logic;
            i_alu_result  : in  std_logic_vector(XLEN-1 downto 0);
            i_rs2_data    : in  std_logic_vector(XLEN-1 downto 0);
            i_control     : in  std_logic_vector(15 downto 0);
            i_rd_addr     : in  std_logic_vector(4 downto 0);

            -- Sorties
            o_mem_data    : out std_logic_vector(XLEN-1 downto 0);
            o_alu_result  : out std_logic_vector(XLEN-1 downto 0);
            o_rd_addr     : out std_logic_vector(4 downto 0);

            -- Interface avec la mémoire
            o_mem_addr    : out std_logic_vector(XLEN-1 downto 0);
            o_mem_write   : out std_logic;
            o_mem_read    : out std_logic;
            o_mem_wdata   : out std_logic_vector(XLEN-1 downto 0);
            i_mem_rdata   : in  std_logic_vector(XLEN-1 downto 0)
        );
    end component;

begin
    -- Instanciation du DUT
    uut : riscv_memory
        port map (
            i_clk         => i_clk,
            i_rstn        => i_rstn,
            i_alu_result  => i_alu_result,
            i_rs2_data    => i_rs2_data,
            i_control     => i_control,
            i_rd_addr     => i_rd_addr,
            o_mem_data    => o_mem_data,
            o_alu_result  => o_alu_result,
            o_rd_addr     => o_rd_addr,
            o_mem_addr    => o_mem_addr,
            o_mem_write   => o_mem_write,
            o_mem_read    => o_mem_read,
            o_mem_wdata   => o_mem_wdata,
            i_mem_rdata   => i_mem_rdata
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

        -- Test 1 : Lecture mémoire (LW)
        i_alu_result <= x"00000010"; -- Adresse mémoire
        i_control <= "0000000000000100"; -- Lecture mémoire (LW)
        i_mem_rdata <= x"12345678"; -- Donnée lue depuis la mémoire
        wait for CLK_PERIOD;
        assert o_mem_read = '1' report "Memory read signal failed" severity error;
        assert o_mem_addr = x"00000010" report "Memory address for LW failed" severity error;
        assert o_mem_data = x"12345678" report "Memory data for LW failed" severity error;

        -- Test 2 : Écriture mémoire (SW)
        i_control <= "0000000000001000"; -- Écriture mémoire (SW)
        i_rs2_data <= x"87654321"; -- Donnée à écrire
        wait for CLK_PERIOD;
        assert o_mem_write = '1' report "Memory write signal failed" severity error;
        assert o_mem_addr = x"00000010" report "Memory address for SW failed" severity error;
        assert o_mem_wdata = x"87654321" report "Memory write data failed" severity error;

        -- Test 3 : Pas d'accès mémoire (bypass de l'ALU)
        i_control <= "0000000000000000"; -- Aucun accès mémoire
        i_alu_result <= x"ABCDEF01"; -- Résultat de l'ALU
        wait for CLK_PERIOD;
        assert o_mem_data = x"ABCDEF01" report "ALU bypass failed" severity error;

        -- Test 4 : Transmission de l'adresse de registre destination
        i_rd_addr <= "01010"; -- x10
        wait for CLK_PERIOD;
        assert o_rd_addr = "01010" report "RD address transmission failed" severity error;

        -- Fin du test
        report "All tests passed successfully" severity note;
        wait;
    end process;

end architecture;
