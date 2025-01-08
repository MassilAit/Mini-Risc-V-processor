library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.riscv_pkg.all;


entity riscv_memory_acces is
    port (
      i_clk       : in  std_logic;
      i_rstn      : in  std_logic;

     -- Forwarding (to EX)
      o_mem_rd_addr : out std_logic_vector(REG_WIDTH-1 downto 0); -- Destination register adress from memory stage
      o_mem_rd_data : out std_logic_vector(XLEN-1 downto 0); --Destination register data from memory
      o_mem_rd_wb   : out std_logic; -- Will the data be written
      o_mem_rd_re   : out std_logic; -- Will the data be read from memory (stall)

      -- Memory signals

      i_load_data  : in std_logic_vector(XLEN-1 downto 0); --Memory data read
      o_store_data : out std_logic_vector(XLEN-1 downto 0); --Memory data to write    
      o_mem_adress : out std_logic_vector(XLEN-1 downto 0); --Memory adress
      o_we         : out std_logic;   --write memory
      o_re         : out std_logic;  --read memory


      -- From EX
      i_we         : in std_logic;   --write memory
      i_re         : in std_logic;  --read memory
  
      i_alu_result : in std_logic_vector(XLEN-1 downto 0); --alu_result
      i_wb         : in std_logic; -- write back result
      i_rd_addr    : in std_logic_vector(REG_WIDTH-1 downto 0); -- Destination register adress 
  
      i_store_data : in std_logic_vector(XLEN-1 downto 0);-- Adress to store in memory


     --To WB 
     o_load_data  : out std_logic_vector(XLEN-1 downto 0); --Memory data read
     o_alu_result : out std_logic_vector(XLEN-1 downto 0); --alu_result
     o_wb         : out std_logic; -- write back result
     o_rd_addr    : out std_logic_vector(REG_WIDTH-1 downto 0); -- Destination register adress
     o_re_wb      : out std_logic);  --memory or alu result

end entity riscv_memory_acces;



architecture beh of riscv_memory_acces is

begin

    -- ME/WB
    WB: process(i_clk, i_rstn)
    begin
        if i_rstn = '0' then
            o_alu_result <= (others => '0');
            o_wb  <= '0';       
            o_rd_addr <= (others => '0');   
            o_re_wb <= '0'; 
            
        elsif rising_edge(i_clk) then
            
            o_alu_result <= i_alu_result;
            o_wb  <= i_wb;       
            o_rd_addr <= i_rd_addr;   
            o_re_wb <= i_re;     
       
            
        end if;
    end process WB;


    -- Memory acces
    o_store_data <= i_store_data;    
    o_mem_adress <= i_alu_result;
    o_we <= i_we;        
    o_re <= i_re or i_we; -- when we write we need both enabled on
    
    o_load_data <= i_load_data;


    -- Forwarding 
    o_mem_rd_addr <= i_rd_addr;
    o_mem_rd_data <= i_alu_result;
    o_mem_rd_wb <= i_wb;
    o_mem_rd_re <= i_re;

end architecture beh;
=======
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

