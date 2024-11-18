library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity riscv_memory is
    generic (
        XLEN : integer := 32
    );
    port (
        -- Entrées
        i_clk         : in  std_logic;
        i_rstn        : in  std_logic;
        i_alu_result  : in  std_logic_vector(XLEN-1 downto 0); -- Adresse calculée par l'ALU
        i_rs2_data    : in  std_logic_vector(XLEN-1 downto 0); -- Donnée à écrire (pour SW)
        i_control     : in  std_logic_vector(15 downto 0); -- Signaux de contrôle
        i_rd_addr     : in  std_logic_vector(4 downto 0); -- Adresse de registre destination

        -- Sorties
        o_mem_data    : out std_logic_vector(XLEN-1 downto 0); -- Donnée lue de la mémoire
        o_alu_result  : out std_logic_vector(XLEN-1 downto 0); -- Résultat de l'ALU (bypass)
        o_rd_addr     : out std_logic_vector(4 downto 0); -- Adresse du registre destination

        -- Interface avec la mémoire
        o_mem_addr    : out std_logic_vector(XLEN-1 downto 0); -- Adresse mémoire
        o_mem_write   : out std_logic; -- Signal d'écriture
        o_mem_read    : out std_logic; -- Signal de lecture
        o_mem_wdata   : out std_logic_vector(XLEN-1 downto 0); -- Donnée à écrire en mémoire
        i_mem_rdata   : in  std_logic_vector(XLEN-1 downto 0)  -- Donnée lue de la mémoire
    );
end entity riscv_memory;

architecture Behavioral of riscv_memory is
begin

    -- Transmission des résultats de l'ALU
    o_alu_result <= i_alu_result;

    -- Adresse mémoire
    o_mem_addr <= i_alu_result;

    -- Gestion des signaux de contrôle
    o_mem_write <= i_control(3); -- Signal d'écriture mémoire (SW)
    o_mem_read <= i_control(2); -- Signal de lecture mémoire (LW)

    -- Donnée à écrire en mémoire
    o_mem_wdata <= i_rs2_data;

    -- Donnée lue ou bypass
    process (i_control, i_mem_rdata, i_alu_result)
    begin
        if i_control(2) = '1' then -- Lecture mémoire
            o_mem_data <= i_mem_rdata;
        else -- Pas d'accès mémoire, bypass de l'ALU
            o_mem_data <= i_alu_result;
        end if;
    end process;

    -- Adresse de destination transmise
    o_rd_addr <= i_rd_addr;

end Behavioral;
