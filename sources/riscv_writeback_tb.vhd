library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_riscv_write_back is
end entity;

architecture testbench of tb_riscv_write_back is
    -- Constantes
    constant XLEN : integer := 32;

    -- Signaux pour connecter au DUT
    signal i_mem_data  : std_logic_vector(XLEN-1 downto 0) := (others => '0');
    signal i_alu_result: std_logic_vector(XLEN-1 downto 0) := (others => '0');
    signal i_rd_addr   : std_logic_vector(4 downto 0) := (others => '0');
    signal i_control   : std_logic_vector(15 downto 0) := (others => '0');

    signal o_wb_data   : std_logic_vector(XLEN-1 downto 0);
    signal o_wb_addr   : std_logic_vector(4 downto 0);
    signal o_wb_enable : std_logic;

    -- Instance du DUT
    component riscv_write_back is
        generic (
            XLEN : integer := 32
        );
        port (
            i_mem_data    : in  std_logic_vector(XLEN-1 downto 0);
            i_alu_result  : in  std_logic_vector(XLEN-1 downto 0);
            i_rd_addr     : in  std_logic_vector(4 downto 0);
            i_control     : in  std_logic_vector(15 downto 0);
            o_wb_data     : out std_logic_vector(XLEN-1 downto 0);
            o_wb_addr     : out std_logic_vector(4 downto 0);
            o_wb_enable   : out std_logic
        );
    end component;

begin
    -- Instanciation du DUT
    uut : riscv_write_back
        port map (
            i_mem_data   => i_mem_data,
            i_alu_result => i_alu_result,
            i_rd_addr    => i_rd_addr,
            i_control    => i_control,
            o_wb_data    => o_wb_data,
            o_wb_addr    => o_wb_addr,
            o_wb_enable  => o_wb_enable
        );

    -- Stimuli
    process
    begin
        -- Test 1 : Écriture depuis la mémoire (LW)
        i_mem_data <= x"12345678"; -- Donnée mémoire
        i_alu_result <= x"ABCDEF01"; -- Résultat ALU (ne doit pas être utilisé)
        i_rd_addr <= "01010"; -- Adresse x10
        i_control <= "0000000000000100"; -- Signal de lecture mémoire (LW)
        wait for 10 ns;
        assert o_wb_data = x"12345678" report "Write Back from memory failed" severity error;
        assert o_wb_addr = "01010" report "Write Back address for memory failed" severity error;
        assert o_wb_enable = '1' report "Write Back enable for memory failed" severity error;

        -- Test 2 : Écriture depuis l'ALU (ADD)
        i_mem_data <= x"00000000"; -- Donnée mémoire (ne doit pas être utilisée)
        i_alu_result <= x"ABCDEF01"; -- Résultat ALU
        i_control <= "0000000000000001"; -- Signal pour ALU (ADD)
        wait for 10 ns;
        assert o_wb_data = x"ABCDEF01" report "Write Back from ALU failed" severity error;
        assert o_wb_enable = '1' report "Write Back enable for ALU failed" severity error;

        -- Test 3 : Pas d'écriture
        i_control <= "0000000000000000"; -- Aucun contrôle activé
        wait for 10 ns;
        assert o_wb_enable = '0' report "Write Back enable disabled failed" severity error;

        -- Test 4 : Transmission correcte de l'adresse
        i_rd_addr <= "01100"; -- Adresse x12
        i_control <= "0000000000000001"; -- Écriture ALU
        wait for 10 ns;
        assert o_wb_addr = "01100" report "Write Back address transmission failed" severity error;

        -- Fin du test
        report "All tests passed successfully" severity note;
        wait;
    end process;

end architecture;
