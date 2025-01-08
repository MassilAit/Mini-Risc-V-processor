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
