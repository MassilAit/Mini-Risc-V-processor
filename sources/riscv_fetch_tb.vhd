library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_riscv_fetch is
end entity;

architecture testbench of tb_riscv_fetch is
    -- Constantes
    constant CLK_PERIOD      : time := 10 ns;
    constant RESET_VECTOR    : std_logic_vector(31 downto 0) := x"00000000";
    constant TARGET_ADDRESS  : std_logic_vector(31 downto 0) := x"00000010"; -- Saut vers adresse 16
    
    -- Signaux pour connecter au DUT
    signal i_clk          : std_logic := '0';
    signal i_rstn         : std_logic := '1';
    signal i_stall        : std_logic := '0';
    signal i_flush        : std_logic := '0';
    signal i_pc_transfert : std_logic := '0';
    signal i_target       : std_logic_vector(31 downto 0) := (others => '0');
    signal i_imem_read    : std_logic_vector(31 downto 0) := (others => '0');
    signal o_pc           : std_logic_vector(31 downto 0);
    signal o_imem_addr    : std_logic_vector(31 downto 0);
    signal o_instruction  : std_logic_vector(31 downto 0);

    -- Instance du DUT
    component riscv_fetch is
        generic (
            RESET_VECTOR : natural := 16#00000000#
        );
        port (
            i_clk          : in  std_logic;
            i_rstn         : in  std_logic;
            i_stall        : in  std_logic;
            i_flush        : in  std_logic;
            i_pc_transfert : in  std_logic;
            i_target       : in  std_logic_vector(31 downto 0);
            i_imem_read    : in  std_logic_vector(31 downto 0);
            o_pc           : out std_logic_vector(31 downto 0);
            o_imem_addr    : out std_logic_vector(31 downto 0);
            o_instruction  : out std_logic_vector(31 downto 0)
        );
    end component;

begin
    -- Instanciation du DUT
    uut : riscv_fetch
        generic map (
            RESET_VECTOR => 16#00000000#
        )
        port map (
            i_clk          => i_clk,
            i_rstn         => i_rstn,
            i_stall        => i_stall,
            i_flush        => i_flush,
            i_pc_transfert => i_pc_transfert,
            i_target       => i_target,
            i_imem_read    => i_imem_read,
            o_pc           => o_pc,
            o_imem_addr    => o_imem_addr,
            o_instruction  => o_instruction
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
        -- Initialisation
        i_rstn <= '0'; -- Reset actif
        wait for CLK_PERIOD;
        i_rstn <= '1'; -- Fin du reset

        -- Vérification du Reset
        assert o_pc = RESET_VECTOR report "Reset failed" severity error;

        -- Incrémentation normale
        wait for CLK_PERIOD;
        assert o_pc = x"00000004" report "PC increment failed" severity error;

        -- Lecture de mémoire
        i_imem_read <= x"12345678";
        wait for CLK_PERIOD;
        assert o_instruction = x"12345678" report "Instruction fetch failed" severity error;

        -- Test du saut/branchements
        i_pc_transfert <= '1';
        i_target <= TARGET_ADDRESS; -- Nouvelle adresse cible
        wait for CLK_PERIOD;
        i_pc_transfert <= '0';
        assert o_pc = TARGET_ADDRESS report "PC transfer failed" severity error;

        -- Blocage du pipeline (stall)
        i_stall <= '1';
        wait for CLK_PERIOD;
        assert o_pc = TARGET_ADDRESS report "Stall failed (PC changed)" severity error;
        i_stall <= '0';

        -- Flush (réinitialisation du registre IF/ID)
        i_flush <= '1';
        wait for CLK_PERIOD;
        i_flush <= '0';
        assert o_instruction = (others => '0') report "Flush failed" severity error;

        -- Fin du test
        report "All tests passed" severity note;
        wait;
    end process;
end architecture;
