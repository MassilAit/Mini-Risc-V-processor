library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.riscv_pkg.all;

entity riscv_execute is
    generic (
        XLEN : integer := 32; -- Taille des registres
        ALUOP_WIDTH : integer := 4; -- Largeur des opcodes de l'ALU
        SHAMT_WIDTH : integer := 5  -- Largeur du décalage
    );
    port (
        -- Entrées
        i_clk         : in  std_logic;
        i_rstn        : in  std_logic;
        i_pc          : in  std_logic_vector(XLEN-1 downto 0); -- PC courant
        i_rs1_data    : in  std_logic_vector(XLEN-1 downto 0); -- Donnée source 1
        i_rs2_data    : in  std_logic_vector(XLEN-1 downto 0); -- Donnée source 2
        i_imm         : in  std_logic_vector(XLEN-1 downto 0); -- Valeur immédiate
        i_shamt       : in  std_logic_vector(SHAMT_WIDTH-1 downto 0); -- Décalage
        i_control     : in  std_logic_vector(15 downto 0); -- Signaux de contrôle
        i_rd_addr     : in  std_logic_vector(4 downto 0); -- Adresse du registre destination

        -- Sorties
        o_alu_result  : out std_logic_vector(XLEN-1 downto 0); -- Résultat de l'ALU
        o_target      : out std_logic_vector(XLEN-1 downto 0); -- Adresse cible (branchements)
        o_branch_taken: out std_logic; -- Branchement pris ou non
        o_rd_addr     : out std_logic_vector(4 downto 0) -- Adresse du registre destination
    );
end entity riscv_execute;

architecture Behavioral of riscv_execute is
    -- Signaux internes
    signal alu_src2 : std_logic_vector(XLEN-1 downto 0); -- Sélection de l'opérande B
    signal alu_result : std_logic_vector(XLEN-1 downto 0);
    signal branch_target : std_logic_vector(XLEN-1 downto 0);
    signal branch_taken : std_logic;
begin

    -- Sélection de l'opérande B pour l'ALU
    alu_src2 <= i_rs2_data when i_control(1) = '0' else i_imm;

    -- Instanciation de l'ALU
    u_alu : entity work.riscv_alu
        port map (
            i_arith  => i_control(0), -- 0 pour ADD, 1 pour SUB
            i_sign   => i_control(2), -- 0 pour non signé, 1 pour signé
            i_opcode => i_control(6 downto 3), -- Opcode de l'ALU
            i_shamt  => i_shamt,
            i_src1   => i_rs1_data,
            i_src2   => alu_src2,
            o_res    => alu_result
        );

    -- Calcul de l'adresse cible pour les branchements
    branch_target <= std_logic_vector(unsigned(i_pc) + unsigned(i_imm));

    -- Résolution des branchements
    process (alu_result, i_control)
    begin
        if i_control(4) = '1' then -- Instruction de branchement
            branch_taken <= '1' when alu_result = (others => '0') else '0'; -- BEQ
        else
            branch_taken <= '0';
        end if;
    end process;

    -- Transmission des résultats
    o_alu_result <= alu_result; -- Résultat de l'ALU
    o_target <= branch_target; -- Adresse cible pour branchements
    o_branch_taken <= branch_taken; -- Indique si le branchement est pris
    o_rd_addr <= i_rd_addr; -- Adresse du registre destination

end Behavioral;
