library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.riscv_pkg.all;


entity riscv_write_back is
    port (

     -- Forwarding (to EX)
     o_wb_rd_addr : out std_logic_vector(REG_WIDTH-1 downto 0); -- Destination register adress from wb stage
     o_wb_rd_data : out std_logic_vector(XLEN-1 downto 0); --Destination register data from wb stage
     o_wb_rd_wb   : out std_logic; -- Will the data be written
 

      -- From MEM 
     i_load_data  : in std_logic_vector(XLEN-1 downto 0); --Memory data read
     i_alu_result : in std_logic_vector(XLEN-1 downto 0); --alu_result
     i_wb         : in std_logic; -- write back result
     i_rd_addr    : in std_logic_vector(REG_WIDTH-1 downto 0); -- Destination register adress
     i_re_wb      : in std_logic;  --memory or alu result

     -- To ID
     o_wb      : out  std_logic;
     o_rd_addr : out  std_logic_vector(REG_WIDTH-1 downto 0);
     o_rd_data : out  std_logic_vector(XLEN-1 downto 0));

end entity riscv_write_back; 


architecture beh of riscv_write_back is

    signal rd_data : std_logic_vector(XLEN-1 downto 0);

begin
    o_wb <= i_wb;
    o_rd_addr <= i_rd_addr;
    o_rd_data <= rd_data;

    -- rd_data
    process(i_alu_result, i_load_data, i_re_wb)
    begin
        case i_re_wb is
            when '0' =>
                rd_data <= i_alu_result;
                
            when others =>
                rd_data <= i_load_data;
        
        end case;
        
    end process; 

    --Forwarding
    o_wb_rd_addr <= i_rd_addr;
    o_wb_rd_data <= rd_data;
    o_wb_rd_wb <= i_wb;   
    
end architecture beh;