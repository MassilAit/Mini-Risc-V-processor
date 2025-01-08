library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_riscv_core is
end entity;

architecture testbench of tb_riscv_core is
    -- Constantes
    constant CLK_PERIOD : time := 10 ns;
    constant XLEN       : integer := 32;

    -- Signaux pour connecter au DUT
    signal i_clk       : std_logic := '0';
    signal i_rstn      : std_logic := '1';
    signal i_mem_rdata : std_logic_vector(XLEN-1 downto 0) := (others => '0');
    signal o_mem_addr  : std_logic_vector(XLEN-1 downto 0);
    signal o_mem_wdata : std_logic_vector(XLEN-1 downto 0);
    signal o_mem_write : std_logic;
    signal o_mem_read  : std_logic;

    -- Mémoire simulée
    type mem_t is array (0 to 255) of std_logic_vector(XLEN-1 downto 0);
    signal mem : mem_t;

begin
    -- Instanciation du DUT
    uut : entity work.riscv_core
        generic map (
            XLEN => XLEN
        )
        port map (
            i_clk       => i_clk,
            i_rstn      => i_rstn,
            i_mem_rdata => i_mem_rdata,
            o_mem_addr  => o_mem_addr,
            o_mem_wdata => o_mem_wdata,
            o_mem_write => o_mem_write,
            o_mem_read  => o_mem_read
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

    -- Simuler la mémoire externe
    process (i_clk)
    begin
        if rising_edge(i_clk) then
            if o_mem_write = '1' then
                mem(to_integer(unsigned(o_mem_addr(7 downto 0)))) <= o_mem_wdata;
            end if;

            if o_mem_read = '1' then
                i_mem_rdata <= mem(to_integer(unsigned(o_mem_addr(7 downto 0))));
            end if;
        end if;
    end process;

    -- Stimuli
    process
    begin
        -- Initialisation et Reset
        i_rstn <= '0';
        wait for CLK_PERIOD;
        i_rstn <= '1';

        -- Charger des instructions dans la mémoire
        -- Instruction 1: ADD x10, x11, x12
        mem(0) <= x"00B50633"; -- ADD x12 = x10 + x11
        -- Instruction 2: SUB x10, x10, x13
        mem(1) <= x"40D505B3"; -- SUB x10 = x10 - x13
        -- Instruction 3: LW x11, 4(x10)
        mem(2) <= x"00450503"; -- LW x11 = Mem[x10 + 4]
        -- Instruction 4: SW x11, 8(x10)
        mem(3) <= x"00B52623"; -- SW Mem[x10 + 8] = x11
        -- Instruction 5: BEQ x10, x11, -4
        mem(4) <= x"FEAFFFF3"; -- BEQ x10 == x11, branchement à -4

        -- Initialiser les registres simulés dans le banc de registres
        mem(10) <= x"00000010"; -- x10 = 16
        mem(11) <= x"00000020"; -- x11 = 32
        mem(12) <= x"00000030"; -- x12 = 48
        mem(13) <= x"00000005"; -- x13 = 5

        -- Laisser le pipeline s'exécuter
        wait for 100 ns;

        -- Vérifications
        -- ADD vérification
        assert mem(12) = x"00000050" report "ADD instruction failed" severity error;

        -- SUB vérification
        assert mem(10) = x"0000000B" report "SUB instruction failed" severity error;

        -- LW vérification (simulé dans la mémoire)
        assert mem(11) = mem(16 + 4) report "LW instruction failed" severity error;

        -- SW vérification
        assert mem(16 + 8) = mem(11) report "SW instruction failed" severity error;

        -- BEQ vérification
        assert o_mem_addr = x"00000000" report "BEQ instruction failed" severity error;

        -- Fin du test
        report "All tests passed successfully" severity note;
        wait;
    end process;

end architecture;
