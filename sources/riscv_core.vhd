library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.riscv_pkg.all;

entity riscv_core is
    port (
    i_rstn : in std_logic;
    i_clk : in std_logic;
    o_imem_en : out std_logic;
    o_imem_addr : out std_logic_vector(8 downto 0);
    i_imem_read : in std_logic_vector(31 downto 0);
    o_dmem_en : out std_logic;
    o_dmem_we : out std_logic;
    o_dmem_addr : out std_logic_vector(8 downto 0);
    i_dmem_read : in std_logic_vector(31 downto 0);
    o_dmem_write : out std_logic_vector(31 downto 0);
    -- DFT
    i_scan_en : in std_logic;
    i_test_mode : in std_logic;
    i_tdi : in std_logic;
    o_tdo : out std_logic);
end entity riscv_core;

architecture beh of riscv_core is

    -- IF to ID
    signal if_id_pc_current : std_logic_vector(XLEN-1 downto 0);
    signal if_id_instr      : std_logic_vector(XLEN-1 downto 0);

    --EX to IF
    signal ex_if_transfert : std_logic;
    signal ex_if_target    : std_logic_vector(XLEN-1 downto 0);

    --Control (EX)
    signal ex_stall         : std_logic;
    signal ex_flush         : std_logic;

    -- WB to ID
    signal wb_id_wb        : std_logic ;
    signal wb_id_rd_addr   : std_logic_vector(REG_WIDTH-1 downto 0) ;
    signal wb_id_rd_data   : std_logic_vector(XLEN-1 downto 0) ;

    --ID to EX
    signal id_ex_rs1_data   : std_logic_vector(XLEN-1 downto 0);
    signal id_ex_rs2_data   : std_logic_vector(XLEN-1 downto 0);
    signal id_ex_rs1_addr   : std_logic_vector(REG_WIDTH-1 downto 0);
    signal id_ex_rs2_addr   : std_logic_vector(REG_WIDTH-1 downto 0);
    signal id_ex_rd_addr    : std_logic_vector(REG_WIDTH-1 downto 0);
    signal id_ex_arith      : std_logic;
    signal id_ex_sign       : std_logic;
    signal id_ex_opcode     : std_logic_vector(ALUOP_WIDTH-1 downto 0);
    signal id_ex_shamt      : std_logic_vector(SHAMT_WIDTH-1 downto 0);
    signal id_ex_imm        : std_logic_vector(XLEN-1 downto 0);
    signal id_ex_jmp        : std_logic;
    signal id_ex_jalr       : std_logic;
    signal id_ex_brnch      : std_logic;
    signal id_ex_src_imm    : std_logic;
    signal id_ex_rshmt      : std_logic;
    signal id_ex_wb         : std_logic;
    signal id_ex_we         : std_logic;
    signal id_ex_re         : std_logic;
    signal id_ex_pc_current : std_logic_vector(XLEN-1 downto 0);
    signal id_ex_spc        : std_logic;
    signal id_ex_odd        : std_logic;
    signal id_ex_neg        : std_logic;

    --MEM to EX
    signal mem_ex_rd_addr : std_logic_vector(REG_WIDTH-1 downto 0); 
    signal mem_ex_rd_data : std_logic_vector(XLEN-1 downto 0); 
    signal mem_ex_rd_wb   : std_logic;
    signal mem_ex_rd_re   : std_logic;

    --WB to EX
    signal wb_ex_rd_addr :  std_logic_vector(REG_WIDTH-1 downto 0);  
    signal wb_ex_rd_data :  std_logic_vector(XLEN-1 downto 0); 
    signal wb_ex_rd_wb   :  std_logic;


    --EX to MEM
    signal ex_mem_we         :  std_logic;   
    signal ex_mem_re         :  std_logic;  
    signal ex_mem_alu_result :  std_logic_vector(XLEN-1 downto 0); 
    signal ex_mem_wb         :  std_logic; 
    signal ex_mem_rd_addr    :  std_logic_vector(REG_WIDTH-1 downto 0); 
    signal ex_mem_store_data :  std_logic_vector(XLEN-1 downto 0);

    --MEM to WB
    signal mem_wb_load_data : std_logic_vector(XLEN-1 downto 0);
    signal mem_wb_alu_result : std_logic_vector(XLEN-1 downto 0);
    signal mem_wb_wb        : std_logic;
    signal mem_wb_rd_addr   : std_logic_vector(REG_WIDTH-1 downto 0);
    signal mem_wb_re_wb     : std_logic;


   -- Memory intermediate
   signal imem_addr_32      :std_logic_vector(XLEN-1 downto 0);

   signal dmem_addr_32      :std_logic_vector(XLEN-1 downto 0);




begin

    -- Fetch stage
    FETCH: entity work.riscv_instruction_fetch
        port map (
            i_clk       => i_clk,
            i_rstn      => i_rstn,
            i_stall     => ex_stall,
            i_flush     => ex_flush,
            i_transfert => ex_if_transfert,
            i_target    => ex_if_target,
            i_imem_read => i_imem_read,
            o_imem_addr => imem_addr_32,
            o_pc_current=> if_id_pc_current,
            o_instr     => if_id_instr
        );
	
	o_imem_addr <= imem_addr_32(8 downto 0);
	


    --Decode stage
    DECODE: entity work.riscv_instruction_decode
        port map (
            i_clk         => i_clk,
            i_rstn        => i_rstn,
            i_wb          => wb_id_wb,
            i_rd_addr     => wb_id_rd_addr,
            i_rd_data     => wb_id_rd_data,
            i_flush       => ex_flush,
            i_stall       => ex_stall,
            i_pc_current  => if_id_pc_current,
            i_instr       => if_id_instr,
            o_rs1_data    => id_ex_rs1_data,
            o_rs2_data    => id_ex_rs2_data,
            o_rs1_addr    => id_ex_rs1_addr,
            o_rs2_addr    => id_ex_rs2_addr,
            o_rd_addr     => id_ex_rd_addr,
            o_arith       => id_ex_arith,
            o_sign        => id_ex_sign,
            o_opcode      => id_ex_opcode,
            o_shamt       => id_ex_shamt,
            o_imm         => id_ex_imm,
            o_jmp         => id_ex_jmp,
            o_jalr        => id_ex_jalr,
            o_brnch       => id_ex_brnch,
            o_src_imm     => id_ex_src_imm,
            o_rshmt       => id_ex_rshmt,
            o_wb          => id_ex_wb,
            o_we          => id_ex_we,
            o_re          => id_ex_re,
            o_spc         => id_ex_spc,
            o_odd         => id_ex_odd,
            o_neg         => id_ex_neg,
            o_pc_current  => id_ex_pc_current
        );


    --Execute stage 
    EXECUTE: entity work.riscv_execute
        port map (
            i_clk         => i_clk,
            i_rstn        => i_rstn,
            i_mem_rd_addr => mem_ex_rd_addr,
            i_mem_rd_data => mem_ex_rd_data,
            i_mem_rd_wb   => mem_ex_rd_wb,
            i_mem_rd_re   => mem_ex_rd_re,
            i_wb_rd_addr  => wb_ex_rd_addr,
            i_wb_rd_data  => wb_ex_rd_data,
            i_wb_rd_wb    => wb_ex_rd_wb,
            i_rs1_data    => id_ex_rs1_data,
            i_rs2_data    => id_ex_rs2_data,
            i_rs1_addr    => id_ex_rs1_addr,
            i_rs2_addr    => id_ex_rs2_addr,
            i_rd_addr     => id_ex_rd_addr,
            i_arith       => id_ex_arith,
            i_sign        => id_ex_sign,
            i_opcode      => id_ex_opcode,
            i_shamt       => id_ex_shamt,
            i_imm         => id_ex_imm,
            i_jmp         => id_ex_jmp,
            i_jalr        => id_ex_jalr,
            i_brnch       => id_ex_brnch,
            i_src_imm     => id_ex_src_imm,
            i_rshmt       => id_ex_rshmt,
            i_wb          => id_ex_wb,
            i_we          => id_ex_we,
            i_re          => id_ex_re,
            i_spc         => id_ex_spc,
            i_odd         => id_ex_odd,
            i_neg         => id_ex_neg,
            i_pc_current  => id_ex_pc_current,
            o_stall       => ex_stall,     
            o_flush       => ex_flush,     
            o_transfert   => ex_if_transfert,
            o_target      => ex_if_target,    
            o_we          => ex_mem_we,      
            o_re          => ex_mem_re,        
            o_alu_result  => ex_mem_alu_result,
            o_wb          => ex_mem_wb,       
            o_rd_addr     => ex_mem_rd_addr,   
            o_store_data  => ex_mem_store_data
        );



    --MEMORY STAGE
    MEMORY: entity work.riscv_memory_acces
        port map (
            i_clk        => i_clk,
            i_rstn       => i_rstn,

            i_load_data  => i_dmem_read,
            o_store_data => o_dmem_write,
            o_mem_adress => dmem_addr_32,
            o_we         => o_dmem_we,
            o_re         => o_dmem_en,

            i_we         => ex_mem_we,
            i_re         => ex_mem_re,
            i_alu_result => ex_mem_alu_result,
            i_wb         => ex_mem_wb,
            i_rd_addr    => ex_mem_rd_addr,
            i_store_data => ex_mem_store_data,

            o_load_data  => mem_wb_load_data,
            o_alu_result => mem_wb_alu_result,
            o_wb         => mem_wb_wb,
            o_rd_addr    => mem_wb_rd_addr,
            o_re_wb      => mem_wb_re_wb,

            o_mem_rd_addr => mem_ex_rd_addr,
            o_mem_rd_data => mem_ex_rd_data,
            o_mem_rd_wb   => mem_ex_rd_wb,
            o_mem_rd_re   => mem_ex_rd_re
        );


     o_dmem_addr <= dmem_addr_32(8 downto 0);



    WBACK: entity work.riscv_write_back
        port map (
            i_load_data  => mem_wb_load_data,
            i_alu_result => mem_wb_alu_result,
            i_wb         => mem_wb_wb,
            i_rd_addr    => mem_wb_rd_addr,
            i_re_wb      => mem_wb_re_wb,
            o_wb         => wb_id_wb,
            o_rd_addr    => wb_id_rd_addr,
            o_rd_data    => wb_id_rd_data,
            o_wb_rd_addr => wb_ex_rd_addr,
            o_wb_rd_data => wb_ex_rd_data,
            o_wb_rd_wb   => wb_ex_rd_wb
        );


    o_imem_en <= '1';
    
end architecture beh;
