library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.riscv_pkg.all;

entity riscv_decode is
    generic (
        XLEN : integer := 32; -- Longueur des registres (32 bits)
        REG  : integer := 5   -- Largeur des adresses de registre
    );
    port (
        -- Entrées
        i_clk         : in  std_logic;                             -- Horloge
        i_rstn        : in  std_logic;                             -- Reset actif bas
        i_instruction : in  std_logic_vector(XLEN-1 downto 0);     -- Instruction à décoder
        i_pc          : in  std_logic_vector(XLEN-1 downto 0);     -- PC courant
        i_we          : in  std_logic;                             -- Signal d'écriture dans le banc de registres
        i_wb_addr     : in  std_logic_vector(REG-1 downto 0);      -- Adresse pour l'écriture WB
        i_wb_data     : in  std_logic_vector(XLEN-1 downto 0);     -- Donnée à écrire dans WB
        
        -- Sorties
        o_rs1_data    : out std_logic_vector(XLEN-1 downto 0);     -- Donnée du registre source 1
        o_rs2_data    : out std_logic_vector(XLEN-1 downto 0);     -- Donnée du registre source 2
        o_imm         : out std_logic_vector(XLEN-1 downto 0);     -- Valeur immédiate
        o_shamt       : out std_logic_vector(4 downto 0);          -- Décalage
        o_rd_addr     : out std_logic_vector(REG-1 downto 0);      -- Adresse de registre destination
        o_control     : out std_logic_vector(15 downto 0)          -- Signaux de contrôle pour Execute
    );
end entity riscv_decode;

architecture Behavioral of riscv_decode is
    -- Signaux internes pour extraire les champs de l'instruction
    signal rs1_addr : std_logic_vector(REG-1 downto 0);
    signal rs2_addr : std_logic_vector(REG-1 downto 0);
    signal rd_addr  : std_logic_vector(REG-1 downto 0);
    signal opcode   : std_logic_vector(6 downto 0);
    signal funct3   : std_logic_vector(2 downto 0);
    signal funct7   : std_logic_vector(6 downto 0);
    signal imm      : std_logic_vector(XLEN-1 downto 0); -- Valeur immédiate
begin

    -- Extraction des champs de l'instruction
    rs1_addr <= i_instruction(19 downto 15);
    rs2_addr <= i_instruction(24 downto 20);
    rd_addr  <= i_instruction(11 downto 7);
    opcode   <= i_instruction(6 downto 0);
    funct3   <= i_instruction(14 downto 12);
    funct7   <= i_instruction(31 downto 25);

    -- Décodage des valeurs immédiates
    process (opcode, funct3, funct7, i_instruction)
    begin
        case opcode is
            when "0010011" => -- I-Type (e.g., ADDI)
                imm <= (others => i_instruction(31)); -- Extension de signe
                imm(30 downto 0) <= i_instruction(30 downto 20);

            when "0100011" => -- S-Type (e.g., SW)
                imm <= (others => i_instruction(31));
                imm(30 downto 25) <= i_instruction(30 downto 25);
                imm(11 downto 7)  <= i_instruction(11 downto 7);

            when "1100011" => -- B-Type (e.g., BEQ)
                imm <= (others => i_instruction(31));
                imm(30 downto 25) <= i_instruction(30 downto 25);
                imm(11 downto 8)  <= i_instruction(11 downto 8);
                imm(0) <= '0';

            when others =>
                imm <= (others => '0'); -- Aucun immédiat
        end case;
    end process;

    -- Instanciation du banc de registres (RF)
    u_rf : entity work.riscv_rf
        port map (
            i_clk     => i_clk,
            i_rstn    => i_rstn,
            i_we      => i_we,
            i_addr_ra => rs1_addr,
            o_data_ra => o_rs1_data,
            i_addr_rb => rs2_addr,
            o_data_rb => o_rs2_data,
            i_addr_w  => i_wb_addr,
            i_data_w  => i_wb_data
        );

    -- Génération des signaux de contrôle
    process (opcode, funct3, funct7)
    begin
        o_control <= (others => '0'); -- Par défaut, aucun signal actif
        case opcode is
            when "0110011" => -- R-Type
                o_control(0) <= '1'; -- ALU op
            when "0010011" => -- I-Type
                o_control(1) <= '1'; -- Immédiat ALU op
            when "0000011" => -- Load
                o_control(2) <= '1'; -- Lecture mémoire
            when "0100011" => -- Store
                o_control(3) <= '1'; -- Écriture mémoire
            when "1100011" => -- Branch (e.g., BEQ)
                o_control(4) <= '1'; -- Branchement
            when others =>
                null; -- Aucun signal activé
        end case;
    end process;

    -- Sorties supplémentaires
    o_rd_addr <= rd_addr;              -- Adresse de destination
    o_imm     <= imm;                  -- Valeur immédiate
    o_shamt   <= i_instruction(24 downto 20); -- Décalage pour SLLI, SRLI, SRAI
end Behavioral;
