library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.riscv_pkg.all;

entity riscv_core is
    generic (
        XLEN : integer := 32; -- Taille des registres
        ALUOP_WIDTH : integer := 4;
        SHAMT_WIDTH : integer := 5
    );
    port (
        -- Entrées globales
        i_clk       : in  std_logic;
        i_rstn      : in  std_logic;

        -- Interface mémoire
        i_mem_rdata : in  std_logic_vector(XLEN-1 downto 0); -- Donnée mémoire lue
        o_mem_addr  : out std_logic_vector(XLEN-1 downto 0); -- Adresse mémoire
        o_mem_wdata : out std_logic_vector(XLEN-1 downto 0); -- Donnée à écrire
        o_mem_write : out std_logic; -- Signal d'écriture
        o_mem_read  : out std_logic -- Signal de lecture
    );
end entity;

architecture Behavioral of riscv_core is
    -- Registres inter-étapes
    signal pc          : std_logic_vector(XLEN-1 downto 0);
    signal instruction : std_logic_vector(XLEN-1 downto 0);

    signal rs1_data    : std_logic_vector(XLEN-1 downto 0);
    signal rs2_data    : std_logic_vector(XLEN-1 downto 0);
    signal imm         : std_logic_vector(XLEN-1 downto 0);
    signal rd_addr     : std_logic_vector(4 downto 0);
    signal alu_result  : std_logic_vector(XLEN-1 downto 0);
    signal mem_data    : std_logic_vector(XLEN-1 downto 0);
    signal wb_data     : std_logic_vector(XLEN-1 downto 0);

    signal control     : std_logic_vector(15 downto 0);

    -- Signaux de branchement
    signal branch_taken : std_logic;
    signal branch_target: std_logic_vector(XLEN-1 downto 0);

begin
    -- Étape Fetch
    u_fetch : entity work.riscv_fetch
        port map (
            i_clk          => i_clk,
            i_rstn         => i_rstn,
            i_pc_transfert => branch_taken,
            i_target       => branch_target,
            i_imem_read    => instruction, -- Reçu depuis la mémoire
            o_pc           => pc,
            o_imem_addr    => o_mem_addr,
            o_instruction  => instruction
        );

    -- Étape Decode
    u_decode : entity work.riscv_decode
        port map (
            i_clk         => i_clk,
            i_rstn        => i_rstn,
            i_instruction => instruction,
            i_pc          => pc,
            i_we          => '1', -- Activation de l’écriture dans RF
            i_wb_addr     => rd_addr,
            i_wb_data     => wb_data,
            o_rs1_data    => rs1_data,
            o_rs2_data    => rs2_data,
            o_imm         => imm,
            o_rd_addr     => rd_addr,
            o_control     => control
        );

    -- Étape Execute
    u_execute : entity work.riscv_execute
        port map (
            i_clk         => i_clk,
            i_rstn        => i_rstn,
            i_pc          => pc,
            i_rs1_data    => rs1_data,
            i_rs2_data    => rs2_data,
            i_imm         => imm,
            i_shamt       => instruction(24 downto 20), -- Décalage
            i_control     => control,
            i_rd_addr     => rd_addr,
            o_alu_result  => alu_result,
            o_target      => branch_target,
            o_branch_taken=> branch_taken,
            o_rd_addr     => rd_addr
        );

    -- Étape Memory
    u_memory : entity work.riscv_memory
        port map (
            i_clk         => i_clk,
            i_rstn        => i_rstn,
            i_alu_result  => alu_result,
            i_rs2_data    => rs2_data,
            i_control     => control,
            i_rd_addr     => rd_addr,
            o_mem_data    => mem_data,
            o_alu_result  => alu_result,
            o_rd_addr     => rd_addr,
            o_mem_addr    => o_mem_addr,
            o_mem_write   => o_mem_write,
            o_mem_read    => o_mem_read,
            o_mem_wdata   => o_mem_wdata,
            i_mem_rdata   => i_mem_rdata
        );

    -- Étape Write Back
    u_write_back : entity work.riscv_write_back
        port map (
            i_mem_data    => mem_data,
            i_alu_result  => alu_result,
            i_rd_addr     => rd_addr,
            i_control     => control,
            o_wb_data     => wb_data,
            o_wb_addr     => rd_addr,
            o_wb_enable   => open -- Peut être utilisé pour vérifier l’état de WB
        );

end Behavioral;
