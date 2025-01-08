library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.riscv_pkg.all;

entity riscv_fetch is
    generic (
        RESET_VECTOR : natural := 16#00000000#
    );
    port (
        i_clk          : in  std_logic;                          -- Horloge
        i_rstn         : in  std_logic;                          -- Reset asynchrone actif bas
        i_stall        : in  std_logic;                          -- Blocage du pipeline
        i_flush        : in  std_logic;                          -- Réinitialisation du registre IF/ID
        i_pc_transfert : in  std_logic;                          -- Saut ou branchement
        i_target       : in  std_logic_vector(XLEN-1 downto 0);  -- Adresse cible pour saut/branchement
        i_imem_read    : in  std_logic_vector(XLEN-1 downto 0);  -- Instruction depuis la mémoire
        o_pc           : out std_logic_vector(XLEN-1 downto 0);  -- PC courant
        o_imem_addr    : out std_logic_vector(XLEN-1 downto 0);  -- Adresse pour la mémoire d'instruction
        o_instruction  : out std_logic_vector(XLEN-1 downto 0)   -- Instruction transmise à Decode
    );
end entity riscv_fetch;

architecture Behavioral of riscv_fetch is
    signal pc_internal : std_logic_vector(XLEN-1 downto 0); -- Signal interne pour le PC
    signal instruction : std_logic_vector(XLEN-1 downto 0) := (others => '0'); -- Registre IF/ID
begin

    -- Instanciation du compteur de programme (PC)
    u_pc : entity work.riscv_pc
        generic map (
            RESET_VECTOR => RESET_VECTOR
        )
        port map (
            i_clk       => i_clk,
            i_rstn      => i_rstn,
            i_stall     => i_stall,
            i_transfert => i_pc_transfert,
            i_target    => i_target,
            o_pc        => pc_internal
        );

    -- Connecter la sortie du PC à l'adresse de la mémoire
    o_imem_addr <= pc_internal;

    -- Registre IF/ID pour stocker l'instruction
    process (i_clk, i_rstn)
    begin
        if i_rstn = '0' or i_flush = '1' then
            -- Réinitialisation en cas de reset ou flush
            instruction <= (others => '0');
        elsif rising_edge(i_clk) then
            if i_stall = '0' then
                -- Stocker l'instruction seulement si pas de stall
                instruction <= i_imem_read;
            end if;
        end if;
    end process;

    -- Connecter la sortie du registre IF/ID
    o_instruction <= instruction;

    -- Connecter le PC à la sortie
    o_pc <= pc_internal;

end Behavioral;
