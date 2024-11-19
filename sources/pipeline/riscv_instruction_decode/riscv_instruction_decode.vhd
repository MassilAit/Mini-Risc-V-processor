library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.riscv_pkg.all;


entity riscv_instruction_decode is
    port (
      i_clk       : in  std_logic;
      i_rstn      : in  std_logic;

      -- From WB
      i_wb      : in  std_logic;
      i_rd_addr : in  std_logic_vector(REG_WIDTH-1 downto 0);
      i_rd_data : in  std_logic_vector(XLEN-1 downto 0);
    
      -- From EX
      i_flush   : in  std_logic;

    
      -- From IF
      i_pc_current   : in std_logic_vector(XLEN-1 downto 0);
      i_instr        : in std_logic_vector(XLEN-1 downto 0);

      --To EX :
      -- Registers
      o_rs1_data  : out std_logic_vector(XLEN-1 downto 0); --register 1 data
      o_rs2_data  : out std_logic_vector(XLEN-1 downto 0); --register 2 data
      o_rd_addr   : out std_logic_vector(REG_WIDTH-1 downto 0); -- Destination register adress

      -- ALU 
      o_arith     : out  std_logic;                                -- Arith/Logic
      o_sign      : out  std_logic;                                -- Signed/Unsigned
      o_opcode    : out  std_logic_vector(ALUOP_WIDTH-1 downto 0); -- ALU opcodes
      o_shamt     : out  std_logic_vector(SHAMT_WIDTH-1 downto 0); -- Shift Amount

      -- Immediate value
      o_imm       : out  std_logic_vector(XLEN-1 downto 0); -- Immediate value
      
      -- Flags
      o_jmp       : out std_logic;   --jmp instr
      o_jal       : out std_logic;   --is jal instr
      o_brnch     : out std_logic;   --branch instr
      o_src_imm   : out std_logic;   --immediate value
      o_rshmt     : out std_logic;   --use rs2 for shamt
      o_wb        : out std_logic;   --write register back
      o_we        : out std_logic;   --write memory
      o_re        : out std_logic;  --read memory


      o_pc_current   : out std_logic_vector(XLEN-1 downto 0)); --pc_current value
      

end entity riscv_instruction_decode;


architecture beh of riscv_instruction_decode is
    
    -- Intermediate signals : 
    signal rs1_addr  : std_logic_vector(REG_WIDTH-1 downto 0);
    signal rs2_addr  : std_logic_vector(REG_WIDTH-1 downto 0);
    signal rd_addr   : std_logic_vector(REG_WIDTH-1 downto 0);
    signal arith     : std_logic;
    signal sign      : std_logic;
    signal opcode    : std_logic_vector(ALUOP_WIDTH-1 downto 0);
    signal shamt     : std_logic_vector(SHAMT_WIDTH-1 downto 0);
    signal imm       : std_logic_vector(XLEN-1 downto 0);
    signal jmp       : std_logic;
    signal jal       : std_logic;
    signal brnch     : std_logic;
    signal src_imm   : std_logic;
    signal rshmt     : std_logic;
    signal wb        : std_logic;
    signal we        : std_logic;
    signal re        : std_logic;
    
begin
    -- Decode Module 
    decode: entity work.decode
        port map (
            i_instr => i_instr,
            o_rs1_addr => rs1_addr,
            o_rs2_addr => rs2_addr,
            o_rd_addr => rd_addr,
            o_arith => arith,
            o_sign => sign,
            o_opcode => opcode,
            o_shamt => shamt,
            o_imm => imm,
            o_jmp => jmp,
            o_jal => jal,
            o_brnch => brnch,
            o_src_imm => src_imm,
            o_rshmt => rshmt,
            o_wb => wb,
            o_we => we,
            o_re => re
        );

    -- Register file module
    rf: entity work.riscv_rf
    port map (
      i_clk     => i_clk,
      i_rstn    => i_rstn,
      i_we      => i_wb,
      i_addr_ra => rs1_addr,
      o_data_ra => o_rs1_data,
      i_addr_rb => rs2_addr,
      o_data_rb => o_rs2_data,
      i_addr_w  => i_rd_addr,
      i_data_w  => i_rd_data
    );

    process(i_clk, i_rstn)
    begin
        if i_rstn = '0' then
            
            o_rd_addr <= (others => '0'); 
            o_arith <= '0';
            o_sign <= '0';
            o_opcode  <= ALUOP_ADD;
            o_shamt <= (others => '0');
            o_imm <= (others => '0');
            o_jmp <= '0';
            o_jal <= '0';
            o_brnch <= '0';
            o_src_imm <= '0';
            o_rshmt <= '0'; 
            o_wb <= '0';      
            o_we <= '0';
            o_re <= '0';
            o_pc_current <= (others => '0');

            
        elsif rising_edge(i_clk) then
            if i_flush = '1' then
                o_rd_addr <= (others => '0'); 
                o_arith <= '0';
                o_sign <= '0';
                o_opcode  <= ALUOP_ADD;
                o_shamt <= (others => '0');
                o_imm <= (others => '0');
                o_jmp <= '0';
                o_jal <= '0';
                o_brnch <= '0';
                o_src_imm <= '0';
                o_rshmt <= '0'; 
                o_wb <= '0';      
                o_we <= '0';
                o_re <= '0';
                o_pc_current <= (others => '0');

            else
                o_rd_addr <= rd_addr; 
                o_arith <= arith;
                o_sign <= sign;
                o_opcode  <= opcode;
                o_shamt <= shamt;
                o_imm <= imm;
                o_jmp <= jmp;
                o_jal <= jal;
                o_brnch <= brnch;
                o_src_imm <= src_imm;
                o_rshmt <= rshmt; 
                o_wb <= wb;      
                o_we <= we;
                o_re <= re;
                o_pc_current <= i_pc_current;
                
            end if;
            
        end if;
    end process;

    
    
    
end architecture beh;