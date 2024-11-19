library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.riscv_pkg.all;


entity riscv_execute is
    port (
      i_clk       : in  std_logic;
      i_rstn      : in  std_logic;

      --From ID :
      -- Registers
      i_rs1_data  : in std_logic_vector(XLEN-1 downto 0); --register 1 data
      i_rs2_data  : in std_logic_vector(XLEN-1 downto 0); --register 2 data
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
      i_jal       : in std_logic;   --is jal instr
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
      o_rd_addr    : out std_logic_vector(REG_WIDTH-1 downto 0)); -- Destination register adress 


end entity riscv_execute;

architecture beh of riscv_execute is
    -- Internal signals :
    signal shamt     : std_logic_vector(SHAMT_WIDTH-1 downto 0);
    signal op1_alu   : std_logic_vector(XLEN-1 downto 0);
    signal op2_alu   : std_logic_vector(XLEN-1 downto 0);

    signal op1_adder : std_logic_vector(XLEN-1 downto 0);

    -- Intermediate signals 
    signal we         : std_logic;   
    signal re         : std_logic;   
    signal alu_result : std_logic_vector(XLEN-1 downto 0); 
    signal wb         : std_logic; 
    signal rd_addr    : std_logic_vector(REG_WIDTH-1 downto 0);  
    
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
      i_b    => i_pc_current,
      i_sign => '1',
      i_sub  => '0',
      o_sum  => o_target
    );


    -- Computes the value of operand 1 of ALU
    OP1ALU: process(i_rs1_data, i_pc_current, i_jmp)
    begin
        
    end process OP1ALU;


    -- Computes the value of operand 2 of ALU
    OP2ALU: process(i_rs2_data, i_imm, i_jmp, i_src_imm)
    begin
        
    end process OP2ALU;


    -- Computes the value of shamt 
    SHAM: process(i_rs2_data, i_shamt, i_rshmt )
    begin
        
    end process SHAM;

    --Computes the value of op1 of adder (RS1(JALR) or IMM(JAL-BEQ))
    OP1ADDER: process(i_rs1_data, i_imm, i_jal, i_brnch)
    begin
        
    end process OP1ADDER;

    -- Computes the pc_transfert
    pc_transfer: process(i_jmp, i_brnch, alu_result)
    begin
        
    end process pc_transfer;


    -- Register EX/ME
    ME: process(i_clk, i_rstn)
    begin
        if i_rstn = '0' then
            
        elsif rising_edge(i_clk) then
            
        end if;
    end process ME;

    
    
    
end architecture beh;