library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.riscv_pkg.all;


entity riscv_execute is
    port (
      i_clk       : in  std_logic;
      i_rstn      : in  std_logic;

      -- Forwarding
      -- From MEM 
      i_mem_rd_addr : in std_logic_vector(REG_WIDTH-1 downto 0); -- Destination register adress from memory stage
      i_mem_rd_data : in std_logic_vector(XLEN-1 downto 0); --Destination register data from memory
      i_mem_rd_wb   : in std_logic; -- Will the data be written
      i_mem_rd_re   : in std_logic; -- Will the data be read from memory (stall)

      -- From WB
      i_wb_rd_addr : in std_logic_vector(REG_WIDTH-1 downto 0); -- Destination register adress from write back stage
      i_wb_rd_data : in std_logic_vector(XLEN-1 downto 0); --Destination register data from memory
      i_wb_rd_wb   : in std_logic; -- Will the data be written

      --From ID :
      -- Registers
      i_rs1_data  : in std_logic_vector(XLEN-1 downto 0); --register 1 data
      i_rs2_data  : in std_logic_vector(XLEN-1 downto 0); --register 2 data
      i_rs1_addr  : in std_logic_vector(REG_WIDTH-1 downto 0); -- register 1 adress
      i_rs2_addr  : in std_logic_vector(REG_WIDTH-1 downto 0); -- register 2 adress
      i_rd_addr   : in std_logic_vector(REG_WIDTH-1 downto 0); -- Destination register adress

      -- ALU 
      i_arith     : in  std_logic;                                -- Arith/Logic
      i_sign      : in  std_logic;                                -- Signed/Unsigned
      i_opcode    : in  std_logic_vector(ALUOP_WIDTH-1 downto 0); -- ALU opcodes
      i_shamt     : in  std_logic_vector(SHAMT_WIDTH-1 downto 0); -- Shift Amount

      -- Immediate value
      i_imm       : in  std_logic_vector(XLEN-1 downto 0); -- Immediate value
      
      -- Flags
      i_jmp       : in std_logic;   --jmp instr
      i_jalr       : in std_logic;   --is jal instr
      i_brnch     : in std_logic;   --branch instr
      i_src_imm   : in std_logic;   --immediate value
      i_rshmt     : in std_logic;   --use rs2 for shamt
      i_wb        : in std_logic;   --write register back
      i_we        : in std_logic;   --write memory
      i_re        : in std_logic;  --read memory

      i_pc_current  : in std_logic_vector(XLEN-1 downto 0); --pc_current value

      -- Control 

      o_stall     : out  std_logic;
      o_flush     : out  std_logic;
      o_transfert : out  std_logic;
      o_target    : out  std_logic_vector(XLEN-1 downto 0);

      -- To ME
      o_we         : out std_logic;   --write memory
      o_re         : out std_logic;  --read memory

      o_alu_result : out std_logic_vector(XLEN-1 downto 0); --alu_result
      o_wb         : out std_logic; -- write back result
      o_rd_addr    : out std_logic_vector(REG_WIDTH-1 downto 0); -- Destination register adress 

      o_store_data : out std_logic_vector(XLEN-1 downto 0));-- Adress to store in memory


end entity riscv_execute;

architecture beh of riscv_execute is
    -- Internal signals :
    signal shamt     : std_logic_vector(SHAMT_WIDTH-1 downto 0);
    signal op1_alu   : std_logic_vector(XLEN-1 downto 0);
    signal op2_alu   : std_logic_vector(XLEN-1 downto 0);
    signal target    : std_logic_vector(XLEN downto 0);

    signal op1_adder : std_logic_vector(XLEN-1 downto 0);

    signal rs1_data  : std_logic_vector(XLEN-1 downto 0);
    signal rs2_data  : std_logic_vector(XLEN-1 downto 0);

    signal stall_rs1 : std_logic;
    signal stall_rs2 : std_logic;
    signal stall     : std_logic;

    -- Intermediate signals   
    signal alu_result : std_logic_vector(XLEN-1 downto 0); 

    
begin
    alu: entity work.riscv_alu
    port map (
      i_arith  => i_arith,
      i_sign   => i_sign,
      i_opcode => i_opcode,
      i_shamt  => shamt,
      i_src1   => op1_alu,
      i_src2   => op2_alu,
      o_res    => alu_result
    );

    adder: entity work.riscv_adder
    generic map (
      N => 32
    )
    port map (
      i_a    => op1_adder,
      i_b    => i_imm,
      i_sign => '1',
      i_sub  => '0',
      o_sum  => target
    );
    
    o_target <= target(XLEN-1 downto 0);


    -- Forwarding for rs1
    process(i_rs1_data, i_rs1_addr, i_mem_rd_addr, i_mem_rd_data, i_mem_rd_wb, i_mem_rd_re, i_wb_rd_addr, i_wb_rd_data, i_wb_rd_wb)
    begin

      stall_rs1 <= '0';

      if i_mem_rd_wb = '1' then -- check mem stage
        
        if i_rs1_addr = i_mem_rd_addr then -- hazard
          case i_mem_rd_re is  
            
            when '0' => -- no stall needed
              rs1_data <= i_mem_rd_data;
          
            when others => -- stall needed
              rs1_data  <= i_rs1_data;
              stall_rs1 <= '1';
          
          end case;

        else -- no hazard
          rs1_data <= i_rs1_data;
          
        end if;
      
      
      elsif i_wb_rd_wb = '1' then -- chek wb stage
        
        if i_rs1_addr = i_wb_rd_addr then -- hazard
          rs1_data <= i_wb_rd_data;

        else -- no hazard
         rs1_data <= i_rs1_data;
         
        end if;

      
      else -- no hazard
        rs1_data <= i_rs1_data;
        
      end if;
       
    end process;

    process(i_rs2_data, i_rs2_addr, i_mem_rd_addr, i_mem_rd_data, i_mem_rd_wb, i_mem_rd_re, i_wb_rd_addr, i_wb_rd_data, i_wb_rd_wb)
    begin
      stall_rs2 <= '0';

      if i_mem_rd_wb = '1' then -- check mem stage
        
        if i_rs2_addr = i_mem_rd_addr then -- hazard
          case i_mem_rd_re is  
            
            when '0' => -- no stall needed
              rs2_data <= i_mem_rd_data;
          
            when others => -- stall needed
              rs2_data  <= i_rs1_data;
              stall_rs2 <= '1';
          
          end case;

        else -- no hazard
          rs2_data <= i_rs2_data;
          
        end if;
      
      
      elsif i_wb_rd_wb = '1' then -- chek wb stage
        
        if i_rs2_addr = i_wb_rd_addr then -- hazard
          rs2_data <= i_wb_rd_data;

        else -- no hazard
         rs2_data <= i_rs2_data;

      end if;
      
      else -- no hazard
        rs2_data <= i_rs2_data;
        
      end if;
      
    end process;

    stall <= stall_rs1 or stall_rs2;
    o_stall <= stall;

    -- Computes the value of operand 1 of ALU
    OP1ALU: process(rs1_data, i_pc_current, i_jmp)
    begin
      case( i_jmp ) is
      
        when '0' =>
          op1_alu <= rs1_data;
        
        when others =>
          op1_alu <= i_pc_current;
      
      end case ;
       
    end process OP1ALU;

    

    -- Computes the value of operand 2 of ALU
    OP2ALU: process(rs2_data, i_imm, i_jmp, i_src_imm)
    begin
      if i_jmp='1' then
        op2_alu <= std_logic_vector(to_signed(4,XLEN));
      
      else
        case( i_src_imm ) is
        
          when '0' =>
            op2_alu <= rs2_data;
        
          when others =>
            op2_alu <= i_imm;
        
        end case ;
      end if;

        
    end process OP2ALU;


    -- Computes the value of shamt 
    SHAM: process(rs2_data, i_shamt, i_rshmt )
    begin
      case( i_rshmt ) is
      
        when '0' =>
          shamt <= i_shamt;
        
        when others =>
          shamt <= rs2_data(SHAMT_WIDTH-1 downto 0);
      
      end case ;
        
    end process SHAM;

    --Computes the value of op1 of adder (RS1(JALR) or IMM(JAL-BEQ))
    OP1ADDER: process(rs1_data, i_imm, i_jalr)
    begin
      case( i_jalr ) is
      
        when '0' =>
          op1_adder <= i_pc_current;
        
        when others =>
          op1_adder <= rs1_data;
      
      end case ;
        
    end process OP1ADDER;

    -- Computes the pc_transfert
    pc_transfer: process(i_jmp, i_brnch, alu_result)
    begin
      -- BEQ
      if i_brnch = '1' and alu_result = std_logic_vector (to_signed(0, XLEN)) then
        o_transfert <= '1' ;
        o_flush <= '1' ;

      -- JAL & JALR
      elsif i_jmp = '1' then
        o_transfert <= '1' ;
        o_flush <= '1' ;

      else 
        o_transfert <= '0' ;
        o_flush <= '0' ;
           
      end if ;
        
    end process pc_transfer;


    -- Register EX/ME
    ME: process(i_clk, i_rstn)
    begin
        if i_rstn = '0' then
          o_we <= '0';
          o_re <= '0';

          o_alu_result <= (others => '0');
          o_wb         <= '0';          
          o_rd_addr    <= (others => '0');

          o_store_data <= (others => '0');
            
        elsif rising_edge(i_clk) then
          if stall ='1' then
            o_we <= '0';
            o_re <= '0';

            o_alu_result <= (others => '0');
            o_wb         <= '0';          
            o_rd_addr    <= (others => '0');

            o_store_data <= (others => '0');

          else
            o_we <= i_we;
            o_re <= i_re;
  
            o_alu_result <= alu_result;
            o_wb         <= i_wb;          
            o_rd_addr    <= i_rd_addr;
  
            o_store_data <= i_rs2_data;
              
            
          end if;
          
        end if;
    end process ME;



    
    
    
end architecture beh;