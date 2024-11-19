library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity riscv_write_back is
    generic (
        XLEN : integer := 32
    );
    port (
        -- Entrées
        i_mem_data    : in  std_logic_vector(XLEN-1 downto 0); -- Donnée lue depuis la mémoire
        i_alu_result  : in  std_logic_vector(XLEN-1 downto 0); -- Résultat de l'ALU
        i_rd_addr     : in  std_logic_vector(4 downto 0); -- Adresse du registre destination
        i_control     : in  std_logic_vector(15 downto 0); -- Signaux de contrôle

        -- Sorties
        o_wb_data     : out std_logic_vector(XLEN-1 downto 0); -- Donnée à écrire
        o_wb_addr     : out std_logic_vector(4 downto 0); -- Adresse du registre destination
        o_wb_enable   : out std_logic -- Activation de l'écriture
    );
end entity riscv_write_back;

architecture Behavioral of riscv_write_back is
begin
    -- Sélection des données à écrire
    o_wb_data <= i_mem_data when i_control(2) = '1' else i_alu_result;

    -- Adresse de destination
    o_wb_addr <= i_rd_addr;

    -- Activation de l'écriture
    o_wb_enable <= '1' when i_control(2) = '1' or i_control(0) = '1' else '0';

end Behavioral;
