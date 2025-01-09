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
      i_stall   : in  std_logic;

    
      -- From IF
      i_pc_current   : in std_logic_vector(XLEN-1 downto 0);
      i_instr        : in std_logic_vector(XLEN-1 downto 0);

      --To EX :
      -- Registers
      o_rs1_data  : out std_logic_vector(XLEN-1 downto 0); --register 1 data
      o_rs2_data  : out std_logic_vector(XLEN-1 downto 0); --register 2 data
      o_rs1_addr   : out std_logic_vector(REG_WIDTH-1 downto 0); -- register 1  adress
      o_rs2_addr   : out std_logic_vector(REG_WIDTH-1 downto 0); -- register 2  adress
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
      o_jalr      : out std_logic;   --is jalr instr
      o_brnch     : out std_logic;   --branch instr
      o_src_imm   : out std_logic;   --immediate value
      o_rshmt     : out std_logic;   --use rs2 for shamt
      o_wb        : out std_logic;   --write register back
      o_we        : out std_logic;   --write memory
      o_re        : out std_logic;  --read memory

      --Special Instruction
      o_spc      : out std_logic;  --Is special instr
      o_odd      : out std_logic;  --Is func3 odd
      o_neg      : out std_logic; --Is func3 negative

      o_pc_current   : out std_logic_vector(XLEN-1 downto 0)); --pc_current value
      

end entity riscv_instruction_decode;


architecture beh of riscv_instruction_decode is
    
    -- Intermediate signals : 
    signal i_rs1_addr  : std_logic_vector(REG_WIDTH-1 downto 0);
    signal i_rs2_addr  : std_logic_vector(REG_WIDTH-1 downto 0);
    signal rs1_addr  : std_logic_vector(REG_WIDTH-1 downto 0);
    signal rs2_addr  : std_logic_vector(REG_WIDTH-1 downto 0);
    signal rd_addr   : std_logic_vector(REG_WIDTH-1 downto 0);
    signal arith     : std_logic;
    signal sign      : std_logic;
    signal opcode    : std_logic_vector(ALUOP_WIDTH-1 downto 0);
    signal shamt     : std_logic_vector(SHAMT_WIDTH-1 downto 0);
    signal imm       : std_logic_vector(XLEN-1 downto 0);
    signal jmp       : std_logic;
    signal jalr       : std_logic;
    signal brnch     : std_logic;
    signal src_imm   : std_logic;
    signal rshmt     : std_logic;
    signal wb        : std_logic;
    signal we        : std_logic;
    signal re        : std_logic;
    signal spc       : std_logic;
    signal odd       : std_logic;
    signal neg       : std_logic;

    -- Register output signals :
    signal r_rs1_addr  : std_logic_vector(REG_WIDTH-1 downto 0);
    signal r_rs2_addr  : std_logic_vector(REG_WIDTH-1 downto 0);
    signal r_rd_addr   : std_logic_vector(REG_WIDTH-1 downto 0);
    signal r_arith     : std_logic;
    signal r_sign      : std_logic;
    signal r_opcode    : std_logic_vector(ALUOP_WIDTH-1 downto 0);
    signal r_shamt     : std_logic_vector(SHAMT_WIDTH-1 downto 0);
    signal r_imm       : std_logic_vector(XLEN-1 downto 0);
    signal r_jmp       : std_logic;
    signal r_jalr       : std_logic;
    signal r_brnch     : std_logic;
    signal r_src_imm   : std_logic;
    signal r_rshmt     : std_logic;
    signal r_wb        : std_logic;
    signal r_we        : std_logic;
    signal r_re        : std_logic;
    signal r_spc       : std_logic;
    signal r_odd       : std_logic;
    signal r_neg       : std_logic;
    signal r_pc_current: std_logic_vector(XLEN-1 downto 0);
    
begin
    -- Decode Module 
    decode: entity work.decode
        port map (
            i_instr => i_instr,
            o_rs1_addr => i_rs1_addr,
            o_rs2_addr => i_rs2_addr,
            o_rd_addr => rd_addr,
            o_arith => arith,
            o_sign => sign,
            o_opcode => opcode,
            o_shamt => shamt,
            o_imm => imm,
            o_jmp => jmp,
            o_jalr => jalr,
            o_brnch => brnch,
            o_src_imm => src_imm,
            o_rshmt => rshmt,
            o_wb => wb,
            o_we => we,
            o_re => re,
            o_spc => spc,
            o_odd => odd,
            o_neg => neg
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



    -- In staling, we use the previous register adresses
    process(i_stall, i_rs1_addr,i_rs2_addr,r_rs1_addr,r_rs2_addr)
    begin
        case i_stall is
            when '0' =>
                rs1_addr <= i_rs1_addr;
                rs2_addr <= i_rs2_addr; 
     
            when others =>
                rs1_addr <= r_rs1_addr;
                rs2_addr <= r_rs2_addr;
        
        end case;

        
    end process;
     
    process(i_clk, i_rstn)
    begin
        if i_rstn = '0' then
            
            r_rd_addr    <= (others => '0'); 
            r_arith      <= '0';
            r_sign       <= '0';
            r_opcode     <= ALUOP_ADD;
            r_shamt      <= (others => '0');
            r_imm        <= (others => '0');
            r_jmp        <= '0';
            r_jalr       <= '0';
            r_brnch      <= '0';
            r_src_imm    <= '0';
            r_rshmt      <= '0'; 
            r_wb         <= '0';      
            r_we         <= '0';
            r_re         <= '0';
            r_spc        <= '0';
            r_odd        <= '0';
            r_neg        <= '0';
            r_pc_current <= (others => '0');
            r_rs1_addr   <= (others => '0');
            r_rs2_addr   <= (others => '0');

            
        elsif rising_edge(i_clk) then
            if i_flush = '1' then
                r_rd_addr <= (others => '0'); 
                r_arith <= '0';
                r_sign <= '0';
                r_opcode  <= ALUOP_ADD;
                r_shamt <= (others => '0');
                r_imm <= (others => '0');
                r_jmp <= '0';
                r_jalr <= '0';
                r_brnch <= '0';
                r_src_imm <= '0';
                r_rshmt <= '0'; 
                r_wb <= '0';      
                r_we <= '0';
                r_re <= '0';
                r_spc <= '0';
                r_odd <= '0';
                r_neg <= '0';
                r_pc_current <= (others => '0');
                r_rs1_addr   <= (others => '0');
                r_rs2_addr   <= (others => '0');

            elsif i_stall ='1' then
                r_rd_addr    <= r_rd_addr;
                r_arith      <= r_arith;
                r_sign       <= r_sign;
                r_opcode     <= r_opcode;
                r_shamt      <= r_shamt;
                r_imm        <= r_imm;
                r_jmp        <= r_jmp;
                r_jalr       <= r_jalr;
                r_brnch      <= r_brnch;
                r_src_imm    <= r_src_imm;
                r_rshmt      <= r_rshmt;
                r_wb         <= r_wb;
                r_we         <= r_we;
                r_re         <= r_re;
                r_spc        <= r_spc;
                r_odd        <= r_odd;
                r_neg        <= r_neg;
                r_pc_current <= r_pc_current;
                r_rs1_addr   <= r_rs1_addr;
                r_rs2_addr   <= r_rs2_addr; 
                

            else
                r_rd_addr <= rd_addr; 
                r_arith <= arith;
                r_sign <= sign;
                r_opcode  <= opcode;
                r_shamt <= shamt;
                r_imm <= imm;
                r_jmp <= jmp;
                r_jalr <= jalr;
                r_brnch <= brnch;
                r_src_imm <= src_imm;
                r_rshmt <= rshmt; 
                r_wb <= wb;      
                r_we <= we;
                r_re <= re;
                r_spc <= spc;
                r_odd <= odd;
                r_neg <= neg;
                r_pc_current <= i_pc_current;
                r_rs1_addr   <= rs1_addr;
                r_rs2_addr   <= rs2_addr;
                
            end if;
            
        end if;
    end process;

    o_rd_addr    <= r_rd_addr;
    o_arith      <= r_arith;
    o_sign       <= r_sign;
    o_opcode     <= r_opcode;
    o_shamt      <= r_shamt;
    o_imm        <= r_imm;
    o_jmp        <= r_jmp;
    o_jalr       <= r_jalr;
    o_brnch      <= r_brnch;
    o_src_imm    <= r_src_imm;
    o_rshmt      <= r_rshmt;
    o_wb         <= r_wb;
    o_we         <= r_we;
    o_re         <= r_re;
    o_spc        <= r_spc;
    o_odd        <= r_odd;
    o_neg        <= r_neg;
    o_pc_current <= r_pc_current;
    o_rs1_addr   <= r_rs1_addr;
    o_rs2_addr   <= r_rs2_addr; 

    
    
    
end architecture beh;