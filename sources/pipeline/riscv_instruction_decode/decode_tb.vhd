library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.riscv_pkg.all;


entity decode_tb is
end entity decode_tb;


architecture tb of decode_tb is
    signal i_instr     : std_logic_vector(XLEN-1 downto 0);
    signal o_rs1_addr  : std_logic_vector(REG_WIDTH-1 downto 0);
    signal o_rs2_addr  : std_logic_vector(REG_WIDTH-1 downto 0);
    signal o_rd_addr   : std_logic_vector(REG_WIDTH-1 downto 0);
    signal o_arith     : std_logic;
    signal o_sign      : std_logic;
    signal o_opcode    : std_logic_vector(ALUOP_WIDTH-1 downto 0);
    signal o_shamt     : std_logic_vector(SHAMT_WIDTH-1 downto 0);
    signal o_imm       : std_logic_vector(XLEN-1 downto 0);
    signal o_jmp       : std_logic;
    signal o_jal       : std_logic;
    signal o_brnch     : std_logic;
    signal o_src_imm   : std_logic;
    signal o_rshmt     : std_logic;
    signal o_wb        : std_logic;
    signal o_we        : std_logic;
    signal o_re        : std_logic;
begin
    -- Instantiate the DUT (Device Under Test)
    uut: entity work.decode
        port map (
            i_instr => i_instr,
            o_rs1_addr => o_rs1_addr,
            o_rs2_addr => o_rs2_addr,
            o_rd_addr => o_rd_addr,
            o_arith => o_arith,
            o_sign => o_sign,
            o_opcode => o_opcode,
            o_shamt => o_shamt,
            o_imm => o_imm,
            o_jmp => o_jmp,
            o_jal => o_jal,
            o_brnch => o_brnch,
            o_src_imm => o_src_imm,
            o_rshmt => o_rshmt,
            o_wb => o_wb,
            o_we => o_we,
            o_re => o_re
        );

    -- LUI instruction LUT
    process
        -- Zero constant for registers
        constant ZERO_REG : std_logic_vector(REG_WIDTH-1 downto 0) := (others => '0');

        -- Zero constant for shift amounts
        constant ZERO_SHAMT : std_logic_vector(SHAMT_WIDTH-1 downto 0) := (others => '0');

        -- Zero constant for immediate values
        constant ZERO_IMM : std_logic_vector(XLEN-1 downto 0) := (others => '0');

        constant U_IMM : std_logic_vector(19 downto 0) := "10101010101010101010";
        constant U_IMM_32 : std_logic_vector(31 downto 0) := "10101010101010101010000000000000";

        constant J_IMM : std_logic_vector(19 downto 0) := "10101010101010101010";
        constant J_IMM_32 : std_logic_vector(31 downto 0) := "11111111111110101010001010101010";

        constant I_IMM : std_logic_vector(11 downto 0) := "101010101010";
        constant I_IMM_32 : std_logic_vector(31 downto 0) := "11111111111111111111101010101010";

        constant B_IMM1 : std_logic_vector(6 downto 0) := "1010101";
        constant B_IMM2 : std_logic_vector(4 downto 0) := "10101";
        constant B_IMM_32 : std_logic_vector(31 downto 0) :="11111111111111111111101010110100";

        constant S_IMM1 : std_logic_vector(6 downto 0) := "1010101";
        constant S_IMM2 : std_logic_vector(4 downto 0) := "10101";
        constant S_IMM_32 : std_logic_vector(31 downto 0) :="11111111111111111111101010110101";

        constant RD : std_logic_vector(REG_WIDTH-1 downto 0) := "00011";
        constant R1 : std_logic_vector(REG_WIDTH-1 downto 0) := "00001";
        constant R2 : std_logic_vector(REG_WIDTH-1 downto 0) := "00010";

    begin
        -- LUI instruction
        
        i_instr <= U_IMM & RD & "0110111"; 
        wait for 10 ns;

        report "Result for instruction LUI : " severity note;
        
        assert o_rs1_addr = ZERO_REG
            report "rs1 address incorrect" severity error;

        assert o_rs2_addr = ZERO_REG
            report "rs2 address incorrect" severity error;

        assert o_rd_addr = RD  
            report "rd address incorrect" severity error;

        assert o_arith = '0'
            report "arith flag incorrect" severity error;

        assert o_sign = '0'
            report "sign flag incorrect" severity error;

        assert o_opcode = ALUOP_ADD
            report "opcode incorrect" severity error;

        assert o_shamt = ZERO_SHAMT
            report "shift amount incorrect" severity error;

        assert o_imm = U_IMM_32
            report "immediate incorrect" severity error;

        assert o_jmp = '0'
            report "jump flag incorrect" severity error;

        assert o_jal = '0'
            report "jal flag incorrect" severity error;

        assert o_brnch = '0'
            report "branch flag incorrect" severity error;

        assert o_src_imm = '1'
            report "src_imm flag incorrect" severity error;

        assert o_rshmt = '0'
            report "rshmt flag incorrect" severity error;

        assert o_wb = '1'
            report "write-back flag incorrect" severity error;

        assert o_we = '0'
            report "write-enable flag incorrect" severity error;

        assert o_re = '0'
            report "read-enable flag incorrect" severity error;

        
        -- JAL
        
        i_instr <= J_IMM & RD & "1101111";
        wait for 10 ns;

        -- Assertions for JAL instruction

        report "Result for instruction JAL : " severity note;
        
        assert o_rs1_addr = ZERO_REG
            report "rs1 address incorrect" severity error;

        assert o_rs2_addr = ZERO_REG
            report "rs2 address incorrect" severity error;

        assert o_rd_addr = RD  
            report "rd address incorrect" severity error;

        assert o_arith = '0'
            report "arith flag incorrect" severity error;

        assert o_sign = '1'
            report "sign flag incorrect" severity error;

        assert o_opcode = ALUOP_ADD
            report "opcode incorrect" severity error;

        assert o_shamt = ZERO_SHAMT
            report "shift amount incorrect" severity error;

        assert o_imm = J_IMM_32  
            report "immediate incorrect" severity error;

        assert o_jmp = '1'
            report "jump flag incorrect" severity error;

        assert o_jal = '1'
            report "jal flag incorrect" severity error;

        assert o_brnch = '0'
            report "branch flag incorrect" severity error;

        assert o_src_imm = '1'
            report "src_imm flag incorrect" severity error;

        assert o_rshmt = '0'
            report "rshmt flag incorrect" severity error;

        assert o_wb = '1'
            report "write-back flag incorrect" severity error;

        assert o_we = '0'
            report "write-enable flag incorrect" severity error;

        assert o_re = '0'
            report "read-enable flag incorrect" severity error;


        -- JALR
        
        i_instr <= I_IMM & R1 & "000" & RD & "1100111";
        wait for 10 ns;

        -- Assertions for JALR instruction

        report "Result for instruction JALR : " severity note;
        
        assert o_rs1_addr = R1
            report "rs1 address incorrect" severity error;

        assert o_rs2_addr = ZERO_REG
            report "rs2 address incorrect" severity error;

        assert o_rd_addr = RD  
            report "rd address incorrect" severity error;

        assert o_arith = '0'
            report "arith flag incorrect" severity error;

        assert o_sign = '1'
            report "sign flag incorrect" severity error;

        assert o_opcode = ALUOP_ADD
            report "opcode incorrect" severity error;

        assert o_shamt = ZERO_SHAMT
            report "shift amount incorrect" severity error;

        assert o_imm = I_IMM_32  
            report "immediate incorrect" severity error;

        assert o_jmp = '1'
            report "jump flag incorrect" severity error;

        assert o_jal = '0'
            report "jal flag incorrect" severity error;

        assert o_brnch = '0'
            report "branch flag incorrect" severity error;

        assert o_src_imm = '1'
            report "src_imm flag incorrect" severity error;

        assert o_rshmt = '0'
            report "rshmt flag incorrect" severity error;

        assert o_wb = '1'
            report "write-back flag incorrect" severity error;

        assert o_we = '0'
            report "write-enable flag incorrect" severity error;

        assert o_re = '0'
            report "read-enable flag incorrect" severity error;

        -- BEQ
        
        i_instr <= B_IMM1 & R2 & R1 & "000" & B_IMM2 & "1100011";
        wait for 10 ns;

        -- Assertions for BEQ instruction

        report "Result for instruction BEQ : " severity note;
        
        assert o_rs1_addr = R1
            report "rs1 address incorrect" severity error;

        assert o_rs2_addr = R2
            report "rs2 address incorrect" severity error;

        assert o_rd_addr = ZERO_REG  
            report "rd address incorrect" severity error;

        assert o_arith = '1'
            report "arith flag incorrect" severity error;

        assert o_sign = '0'
            report "sign flag incorrect" severity error;

        assert o_opcode = ALUOP_ADD
            report "opcode incorrect" severity error;

        assert o_shamt = ZERO_SHAMT
            report "shift amount incorrect" severity error;

        assert o_imm = B_IMM_32  
            report "immediate incorrect" severity error;

        assert o_jmp = '0'
            report "jump flag incorrect" severity error;

        assert o_jal = '0'
            report "jal flag incorrect" severity error;

        assert o_brnch = '1'
            report "branch flag incorrect" severity error;

        assert o_src_imm = '0'
            report "src_imm flag incorrect" severity error;

        assert o_rshmt = '0'
            report "rshmt flag incorrect" severity error;

        assert o_wb = '0'
            report "write-back flag incorrect" severity error;

        assert o_we = '0'
            report "write-enable flag incorrect" severity error;

        assert o_re = '0'
            report "read-enable flag incorrect" severity error;

        -- LW
        
        i_instr <= I_IMM & R1 & "010" & RD & "0000011";
        wait for 10 ns;

        -- Assertions for LW instruction

        report "Result for instruction LW : " severity note;
        
        assert o_rs1_addr = R1
            report "rs1 address incorrect" severity error;

        assert o_rs2_addr = ZERO_REG
            report "rs2 address incorrect" severity error;

        assert o_rd_addr = RD 
            report "rd address incorrect" severity error;

        assert o_arith = '0'
            report "arith flag incorrect" severity error;

        assert o_sign = '1'
            report "sign flag incorrect" severity error;

        assert o_opcode = ALUOP_ADD
            report "opcode incorrect" severity error;

        assert o_shamt = ZERO_SHAMT
            report "shift amount incorrect" severity error;

        assert o_imm = I_IMM_32  
            report "immediate incorrect" severity error;

        assert o_jmp = '0'
            report "jump flag incorrect" severity error;

        assert o_jal = '0'
            report "jal flag incorrect" severity error;

        assert o_brnch = '0'
            report "branch flag incorrect" severity error;

        assert o_src_imm = '1'
            report "src_imm flag incorrect" severity error;

        assert o_rshmt = '0'
            report "rshmt flag incorrect" severity error;

        assert o_wb = '1'
            report "write-back flag incorrect" severity error;

        assert o_we = '0'
            report "write-enable flag incorrect" severity error;

        assert o_re = '1'
            report "read-enable flag incorrect" severity error;

        -- SW
        
        i_instr <= S_IMM1 & R2 & R1 & "010" & S_IMM2 & "0100011";
        wait for 10 ns;

        -- Assertions for SW instruction

        report "Result for instruction SW : " severity note;
        
        assert o_rs1_addr = R1
            report "rs1 address incorrect" severity error;

        assert o_rs2_addr = R2
            report "rs2 address incorrect" severity error;

        assert o_rd_addr = ZERO_REG 
            report "rd address incorrect" severity error;

        assert o_arith = '0'
            report "arith flag incorrect" severity error;

        assert o_sign = '1'
            report "sign flag incorrect" severity error;

        assert o_opcode = ALUOP_ADD
            report "opcode incorrect" severity error;

        assert o_shamt = ZERO_SHAMT
            report "shift amount incorrect" severity error;

        assert o_imm = S_IMM_32  
            report "immediate incorrect" severity error;

        assert o_jmp = '0'
            report "jump flag incorrect" severity error;

        assert o_jal = '0'
            report "jal flag incorrect" severity error;

        assert o_brnch = '0'
            report "branch flag incorrect" severity error;

        assert o_src_imm = '1'
            report "src_imm flag incorrect" severity error;

        assert o_rshmt = '0'
            report "rshmt flag incorrect" severity error;

        assert o_wb = '0'
            report "write-back flag incorrect" severity error;

        assert o_we = '1'
            report "write-enable flag incorrect" severity error;

        assert o_re = '0'
            report "read-enable flag incorrect" severity error;

        -- ADDI
        
        i_instr <= I_IMM & R1 & "000" & RD & "0010011";
        wait for 10 ns;

        -- Assertions for ADDI instruction

        report "Result for instruction ADDI : " severity note;
        
        assert o_rs1_addr = R1
            report "rs1 address incorrect" severity error;

        assert o_rs2_addr = ZERO_REG
            report "rs2 address incorrect" severity error;

        assert o_rd_addr = RD 
            report "rd address incorrect" severity error;

        assert o_arith = '0'
            report "arith flag incorrect" severity error;

        assert o_sign = '0'
            report "sign flag incorrect" severity error;

        assert o_opcode = ALUOP_ADD
            report "opcode incorrect" severity error;

        assert o_shamt = ZERO_SHAMT
            report "shift amount incorrect" severity error;

        assert o_imm = I_IMM_32  
            report "immediate incorrect" severity error;

        assert o_jmp = '0'
            report "jump flag incorrect" severity error;

        assert o_jal = '0'
            report "jal flag incorrect" severity error;

        assert o_brnch = '0'
            report "branch flag incorrect" severity error;

        assert o_src_imm = '1'
            report "src_imm flag incorrect" severity error;

        assert o_rshmt = '0'
            report "rshmt flag incorrect" severity error;

        assert o_wb = '1'
            report "write-back flag incorrect" severity error;

        assert o_we = '0'
            report "write-enable flag incorrect" severity error;

        assert o_re = '0'
            report "read-enable flag incorrect" severity error;

        -- SLTI
        
        i_instr <= I_IMM & R1 & "010" & RD & "0010011";
        wait for 10 ns;

        -- Assertions for SLTI instruction

        report "Result for instruction SLTI : " severity note;
        
        assert o_rs1_addr = R1
            report "rs1 address incorrect" severity error;

        assert o_rs2_addr = ZERO_REG
            report "rs2 address incorrect" severity error;

        assert o_rd_addr = RD 
            report "rd address incorrect" severity error;

        assert o_arith = '0'
            report "arith flag incorrect" severity error;

        assert o_sign = '1'
            report "sign flag incorrect" severity error;

        assert o_opcode = ALUOP_SLT
            report "opcode incorrect" severity error;

        assert o_shamt = ZERO_SHAMT
            report "shift amount incorrect" severity error;

        assert o_imm = I_IMM_32  
            report "immediate incorrect" severity error;

        assert o_jmp = '0'
            report "jump flag incorrect" severity error;

        assert o_jal = '0'
            report "jal flag incorrect" severity error;

        assert o_brnch = '0'
            report "branch flag incorrect" severity error;

        assert o_src_imm = '1'
            report "src_imm flag incorrect" severity error;

        assert o_rshmt = '0'
            report "rshmt flag incorrect" severity error;

        assert o_wb = '1'
            report "write-back flag incorrect" severity error;

        assert o_we = '0'
            report "write-enable flag incorrect" severity error;

        assert o_re = '0'
            report "read-enable flag incorrect" severity error;


        -- SLTIU
        
        i_instr <= I_IMM & R1 & "011" & RD & "0010011";
        wait for 10 ns;

        -- Assertions for SLTIU instruction

        report "Result for instruction SLTIU : " severity note;
        
        assert o_rs1_addr = R1
            report "rs1 address incorrect" severity error;

        assert o_rs2_addr = ZERO_REG
            report "rs2 address incorrect" severity error;

        assert o_rd_addr = RD 
            report "rd address incorrect" severity error;

        assert o_arith = '0'
            report "arith flag incorrect" severity error;

        assert o_sign = '0'
            report "sign flag incorrect" severity error;

        assert o_opcode = ALUOP_SLT
            report "opcode incorrect" severity error;

        assert o_shamt = ZERO_SHAMT
            report "shift amount incorrect" severity error;

        assert o_imm = I_IMM_32  
            report "immediate incorrect" severity error;

        assert o_jmp = '0'
            report "jump flag incorrect" severity error;

        assert o_jal = '0'
            report "jal flag incorrect" severity error;

        assert o_brnch = '0'
            report "branch flag incorrect" severity error;

        assert o_src_imm = '1'
            report "src_imm flag incorrect" severity error;

        assert o_rshmt = '0'
            report "rshmt flag incorrect" severity error;

        assert o_wb = '1'
            report "write-back flag incorrect" severity error;

        assert o_we = '0'
            report "write-enable flag incorrect" severity error;

        assert o_re = '0'
            report "read-enable flag incorrect" severity error;

        -- XORI
        
        i_instr <= I_IMM & R1 & "100" & RD & "0010011";
        wait for 10 ns;

        -- Assertions for XORI instruction

        report "Result for instruction XORI : " severity note;
        
        assert o_rs1_addr = R1
            report "rs1 address incorrect" severity error;

        assert o_rs2_addr = ZERO_REG
            report "rs2 address incorrect" severity error;

        assert o_rd_addr = RD 
            report "rd address incorrect" severity error;

        assert o_arith = '0'
            report "arith flag incorrect" severity error;

        assert o_sign = '0'
            report "sign flag incorrect" severity error;

        assert o_opcode = ALUOP_XOR
            report "opcode incorrect" severity error;

        assert o_shamt = ZERO_SHAMT
            report "shift amount incorrect" severity error;

        assert o_imm = I_IMM_32  
            report "immediate incorrect" severity error;

        assert o_jmp = '0'
            report "jump flag incorrect" severity error;

        assert o_jal = '0'
            report "jal flag incorrect" severity error;

        assert o_brnch = '0'
            report "branch flag incorrect" severity error;

        assert o_src_imm = '1'
            report "src_imm flag incorrect" severity error;

        assert o_rshmt = '0'
            report "rshmt flag incorrect" severity error;

        assert o_wb = '1'
            report "write-back flag incorrect" severity error;

        assert o_we = '0'
            report "write-enable flag incorrect" severity error;

        assert o_re = '0'
            report "read-enable flag incorrect" severity error;

        -- ORI
        
        i_instr <= I_IMM & R1 & "110" & RD & "0010011";
        wait for 10 ns;

        -- Assertions for ORI instruction

        report "Result for instruction ORI : " severity note;
        
        assert o_rs1_addr = R1
            report "rs1 address incorrect" severity error;

        assert o_rs2_addr = ZERO_REG
            report "rs2 address incorrect" severity error;

        assert o_rd_addr = RD 
            report "rd address incorrect" severity error;

        assert o_arith = '0'
            report "arith flag incorrect" severity error;

        assert o_sign = '0'
            report "sign flag incorrect" severity error;

        assert o_opcode = ALUOP_OR
            report "opcode incorrect" severity error;

        assert o_shamt = ZERO_SHAMT
            report "shift amount incorrect" severity error;

        assert o_imm = I_IMM_32  
            report "immediate incorrect" severity error;

        assert o_jmp = '0'
            report "jump flag incorrect" severity error;

        assert o_jal = '0'
            report "jal flag incorrect" severity error;

        assert o_brnch = '0'
            report "branch flag incorrect" severity error;

        assert o_src_imm = '1'
            report "src_imm flag incorrect" severity error;

        assert o_rshmt = '0'
            report "rshmt flag incorrect" severity error;

        assert o_wb = '1'
            report "write-back flag incorrect" severity error;

        assert o_we = '0'
            report "write-enable flag incorrect" severity error;

        assert o_re = '0'
            report "read-enable flag incorrect" severity error;

        -- ANDI
        
        i_instr <= I_IMM & R1 & "111" & RD & "0010011";
        wait for 10 ns;

        -- Assertions for ANDI instruction

        report "Result for instruction ANDI : " severity note;
        
        assert o_rs1_addr = R1
            report "rs1 address incorrect" severity error;

        assert o_rs2_addr = ZERO_REG
            report "rs2 address incorrect" severity error;

        assert o_rd_addr = RD 
            report "rd address incorrect" severity error;

        assert o_arith = '0'
            report "arith flag incorrect" severity error;

        assert o_sign = '0'
            report "sign flag incorrect" severity error;

        assert o_opcode = ALUOP_AND
            report "opcode incorrect" severity error;

        assert o_shamt = ZERO_SHAMT
            report "shift amount incorrect" severity error;

        assert o_imm = I_IMM_32  
            report "immediate incorrect" severity error;

        assert o_jmp = '0'
            report "jump flag incorrect" severity error;

        assert o_jal = '0'
            report "jal flag incorrect" severity error;

        assert o_brnch = '0'
            report "branch flag incorrect" severity error;

        assert o_src_imm = '1'
            report "src_imm flag incorrect" severity error;

        assert o_rshmt = '0'
            report "rshmt flag incorrect" severity error;

        assert o_wb = '1'
            report "write-back flag incorrect" severity error;

        assert o_we = '0'
            report "write-enable flag incorrect" severity error;

        assert o_re = '0'
            report "read-enable flag incorrect" severity error;

        -- SLLI

        i_instr <= I_IMM & R1 & "001" & RD & "0010011";
        wait for 10 ns;

        -- Assertions for SLLI instruction

        report "Result for instruction SLLI : " severity note;
        
        assert o_rs1_addr = R1
            report "rs1 address incorrect" severity error;

        assert o_rs2_addr = ZERO_REG
            report "rs2 address incorrect" severity error;

        assert o_rd_addr = RD 
            report "rd address incorrect" severity error;

        assert o_arith = '0'
            report "arith flag incorrect" severity error;

        assert o_sign = '0'
            report "sign flag incorrect" severity error;

        assert o_opcode = ALUOP_SL
            report "opcode incorrect" severity error;

        assert o_shamt =  i_instr(24 downto 20)
            report "shift amount incorrect" severity error;

        assert o_imm = I_IMM_32  
            report "immediate incorrect" severity error;

        assert o_jmp = '0'
            report "jump flag incorrect" severity error;

        assert o_jal = '0'
            report "jal flag incorrect" severity error;

        assert o_brnch = '0'
            report "branch flag incorrect" severity error;

        assert o_src_imm = '0'
            report "src_imm flag incorrect" severity error;

        assert o_rshmt = '0'
            report "rshmt flag incorrect" severity error;

        assert o_wb = '1'
            report "write-back flag incorrect" severity error;

        assert o_we = '0'
            report "write-enable flag incorrect" severity error;

        assert o_re = '0'
            report "read-enable flag incorrect" severity error;
        
        -- SRLI

        i_instr <= "0000000" & "11111" & R1 & "101" & RD & "0010011";
        wait for 10 ns;

        -- Assertions for SRLI instruction

        report "Result for instruction SRLI : " severity note;
        
        assert o_rs1_addr = R1
            report "rs1 address incorrect" severity error;

        assert o_rs2_addr = ZERO_REG
            report "rs2 address incorrect" severity error;

        assert o_rd_addr = RD 
            report "rd address incorrect" severity error;

        assert o_arith = '0'
            report "arith flag incorrect" severity error;

        assert o_sign = '0'
            report "sign flag incorrect" severity error;

        assert o_opcode = ALUOP_SR
            report "opcode incorrect" severity error;

        assert o_shamt =  i_instr(24 downto 20)
            report "shift amount incorrect" severity error;

        assert o_jmp = '0'
            report "jump flag incorrect" severity error;

        assert o_jal = '0'
            report "jal flag incorrect" severity error;

        assert o_brnch = '0'
            report "branch flag incorrect" severity error;

        assert o_src_imm = '0'
            report "src_imm flag incorrect" severity error;

        assert o_rshmt = '0'
            report "rshmt flag incorrect" severity error;

        assert o_wb = '1'
            report "write-back flag incorrect" severity error;

        assert o_we = '0'
            report "write-enable flag incorrect" severity error;

        assert o_re = '0'
            report "read-enable flag incorrect" severity error;
        
        -- SRAI

        i_instr <= "0100000" & "11111" & R1 & "101" & RD & "0010011";
        wait for 10 ns;

        -- Assertions for SRAI instruction

        report "Result for instruction SRAI : " severity note;
        
        assert o_rs1_addr = R1
            report "rs1 address incorrect" severity error;

        assert o_rs2_addr = ZERO_REG
            report "rs2 address incorrect" severity error;

        assert o_rd_addr = RD 
            report "rd address incorrect" severity error;

        assert o_arith = '1'
            report "arith flag incorrect" severity error;

        assert o_sign = '0'
            report "sign flag incorrect" severity error;

        assert o_opcode = ALUOP_SR
            report "opcode incorrect" severity error;

        assert o_shamt =  i_instr(24 downto 20)
            report "shift amount incorrect" severity error;

        assert o_jmp = '0'
            report "jump flag incorrect" severity error;

        assert o_jal = '0'
            report "jal flag incorrect" severity error;

        assert o_brnch = '0'
            report "branch flag incorrect" severity error;

        assert o_src_imm = '0'
            report "src_imm flag incorrect" severity error;

        assert o_rshmt = '0'
            report "rshmt flag incorrect" severity error;

        assert o_wb = '1'
            report "write-back flag incorrect" severity error;

        assert o_we = '0'
            report "write-enable flag incorrect" severity error;

        assert o_re = '0'
            report "read-enable flag incorrect" severity error;

         -- ADD
        
         i_instr <= "0000000" & R2 & R1 & "000" & RD & "0110011";
         wait for 10 ns;
 
         -- Assertions for ADD instruction
 
         report "Result for instruction ADD : " severity note;
         
         assert o_rs1_addr = R1
             report "rs1 address incorrect" severity error;
 
         assert o_rs2_addr = R2
             report "rs2 address incorrect" severity error;
 
         assert o_rd_addr = RD 
             report "rd address incorrect" severity error;
 
         assert o_arith = '0'
             report "arith flag incorrect" severity error;
 
         assert o_sign = '0'
             report "sign flag incorrect" severity error;
 
         assert o_opcode = ALUOP_ADD
             report "opcode incorrect" severity error;
 
         assert o_shamt = ZERO_SHAMT
             report "shift amount incorrect" severity error;
 
         assert o_imm = ZERO_IMM  
             report "immediate incorrect" severity error;
 
         assert o_jmp = '0'
             report "jump flag incorrect" severity error;
 
         assert o_jal = '0'
             report "jal flag incorrect" severity error;
 
         assert o_brnch = '0'
             report "branch flag incorrect" severity error;
 
         assert o_src_imm = '0'
             report "src_imm flag incorrect" severity error;
 
         assert o_rshmt = '0'
             report "rshmt flag incorrect" severity error;
 
         assert o_wb = '1'
             report "write-back flag incorrect" severity error;
 
         assert o_we = '0'
             report "write-enable flag incorrect" severity error;
 
         assert o_re = '0'
             report "read-enable flag incorrect" severity error;

        -- SUB
        
        i_instr <= "0100000" & R2 & R1 & "000" & RD & "0110011";
        wait for 10 ns;

        -- Assertions for SUB instruction

        report "Result for instruction SUB : " severity note;
        
        assert o_rs1_addr = R1
            report "rs1 address incorrect" severity error;

        assert o_rs2_addr = R2
            report "rs2 address incorrect" severity error;

        assert o_rd_addr = RD 
            report "rd address incorrect" severity error;

        assert o_arith = '1'
            report "arith flag incorrect" severity error;

        assert o_sign = '0'
            report "sign flag incorrect" severity error;

        assert o_opcode = ALUOP_ADD
            report "opcode incorrect" severity error;

        assert o_shamt = ZERO_SHAMT
            report "shift amount incorrect" severity error;

        assert o_imm = ZERO_IMM  
            report "immediate incorrect" severity error;

        assert o_jmp = '0'
            report "jump flag incorrect" severity error;

        assert o_jal = '0'
            report "jal flag incorrect" severity error;

        assert o_brnch = '0'
            report "branch flag incorrect" severity error;

        assert o_src_imm = '0'
            report "src_imm flag incorrect" severity error;

        assert o_rshmt = '0'
            report "rshmt flag incorrect" severity error;

        assert o_wb = '1'
            report "write-back flag incorrect" severity error;

        assert o_we = '0'
            report "write-enable flag incorrect" severity error;

        assert o_re = '0'
            report "read-enable flag incorrect" severity error;

        -- SLL
        
        i_instr <= "0000000" & R2 & R1 & "001" & RD & "0110011";
        wait for 10 ns;

        -- Assertions for SLL instruction

        report "Result for instruction SLL : " severity note;
        
        assert o_rs1_addr = R1
            report "rs1 address incorrect" severity error;

        assert o_rs2_addr = R2
            report "rs2 address incorrect" severity error;

        assert o_rd_addr = RD 
            report "rd address incorrect" severity error;

        assert o_arith = '0'
            report "arith flag incorrect" severity error;

        assert o_sign = '0'
            report "sign flag incorrect" severity error;

        assert o_opcode = ALUOP_SL
            report "opcode incorrect" severity error;

        assert o_shamt = ZERO_SHAMT
            report "shift amount incorrect" severity error;

        assert o_imm = ZERO_IMM  
            report "immediate incorrect" severity error;

        assert o_jmp = '0'
            report "jump flag incorrect" severity error;

        assert o_jal = '0'
            report "jal flag incorrect" severity error;

        assert o_brnch = '0'
            report "branch flag incorrect" severity error;

        assert o_src_imm = '0'
            report "src_imm flag incorrect" severity error;

        assert o_rshmt = '1'
            report "rshmt flag incorrect" severity error;

        assert o_wb = '1'
            report "write-back flag incorrect" severity error;

        assert o_we = '0'
            report "write-enable flag incorrect" severity error;

        assert o_re = '0'
            report "read-enable flag incorrect" severity error;

        -- SLT
        
        i_instr <= "0000000" & R2 & R1 & "010" & RD & "0110011";
        wait for 10 ns;

        -- Assertions for SLT instruction

        report "Result for instruction SLT : " severity note;
        
        assert o_rs1_addr = R1
            report "rs1 address incorrect" severity error;

        assert o_rs2_addr = R2
            report "rs2 address incorrect" severity error;

        assert o_rd_addr = RD 
            report "rd address incorrect" severity error;

        assert o_arith = '0'
            report "arith flag incorrect" severity error;

        assert o_sign = '1'
            report "sign flag incorrect" severity error;

        assert o_opcode = ALUOP_SLT
            report "opcode incorrect" severity error;

        assert o_shamt = ZERO_SHAMT
            report "shift amount incorrect" severity error;

        assert o_imm = ZERO_IMM  
            report "immediate incorrect" severity error;

        assert o_jmp = '0'
            report "jump flag incorrect" severity error;

        assert o_jal = '0'
            report "jal flag incorrect" severity error;

        assert o_brnch = '0'
            report "branch flag incorrect" severity error;

        assert o_src_imm = '0'
            report "src_imm flag incorrect" severity error;

        assert o_rshmt = '0'
            report "rshmt flag incorrect" severity error;

        assert o_wb = '1'
            report "write-back flag incorrect" severity error;

        assert o_we = '0'
            report "write-enable flag incorrect" severity error;

        assert o_re = '0'
            report "read-enable flag incorrect" severity error;

         -- SLTU
        
         i_instr <= "0000000" & R2 & R1 & "011" & RD & "0110011";
         wait for 10 ns;
 
         -- Assertions for SLTU instruction
 
         report "Result for instruction SLTU : " severity note;
         
         assert o_rs1_addr = R1
             report "rs1 address incorrect" severity error;
 
         assert o_rs2_addr = R2
             report "rs2 address incorrect" severity error;
 
         assert o_rd_addr = RD 
             report "rd address incorrect" severity error;
 
         assert o_arith = '0'
             report "arith flag incorrect" severity error;
 
         assert o_sign = '0'
             report "sign flag incorrect" severity error;
 
         assert o_opcode = ALUOP_SLT
             report "opcode incorrect" severity error;
 
         assert o_shamt = ZERO_SHAMT
             report "shift amount incorrect" severity error;
 
         assert o_imm = ZERO_IMM  
             report "immediate incorrect" severity error;
 
         assert o_jmp = '0'
             report "jump flag incorrect" severity error;
 
         assert o_jal = '0'
             report "jal flag incorrect" severity error;
 
         assert o_brnch = '0'
             report "branch flag incorrect" severity error;
 
         assert o_src_imm = '0'
             report "src_imm flag incorrect" severity error;
 
         assert o_rshmt = '0'
             report "rshmt flag incorrect" severity error;
 
         assert o_wb = '1'
             report "write-back flag incorrect" severity error;
 
         assert o_we = '0'
             report "write-enable flag incorrect" severity error;
 
         assert o_re = '0'
             report "read-enable flag incorrect" severity error;

        
         -- XOR
        
         i_instr <= "0000000" & R2 & R1 & "100" & RD & "0110011";
         wait for 10 ns;
 
         -- Assertions for XOR instruction
 
         report "Result for instruction XOR : " severity note;
         
         assert o_rs1_addr = R1
             report "rs1 address incorrect" severity error;
 
         assert o_rs2_addr = R2
             report "rs2 address incorrect" severity error;
 
         assert o_rd_addr = RD 
             report "rd address incorrect" severity error;
 
         assert o_arith = '0'
             report "arith flag incorrect" severity error;
 
         assert o_sign = '0'
             report "sign flag incorrect" severity error;
 
         assert o_opcode = ALUOP_XOR
             report "opcode incorrect" severity error;
 
         assert o_shamt = ZERO_SHAMT
             report "shift amount incorrect" severity error;
 
         assert o_imm = ZERO_IMM  
             report "immediate incorrect" severity error;
 
         assert o_jmp = '0'
             report "jump flag incorrect" severity error;
 
         assert o_jal = '0'
             report "jal flag incorrect" severity error;
 
         assert o_brnch = '0'
             report "branch flag incorrect" severity error;
 
         assert o_src_imm = '0'
             report "src_imm flag incorrect" severity error;
 
         assert o_rshmt = '0'
             report "rshmt flag incorrect" severity error;
 
         assert o_wb = '1'
             report "write-back flag incorrect" severity error;
 
         assert o_we = '0'
             report "write-enable flag incorrect" severity error;
 
         assert o_re = '0'
             report "read-enable flag incorrect" severity error;


        -- SRL
        
        i_instr <= "0000000" & R2 & R1 & "101" & RD & "0110011";
        wait for 10 ns;

        -- Assertions for SRL instruction

        report "Result for instruction SRL : " severity note;
        
        assert o_rs1_addr = R1
            report "rs1 address incorrect" severity error;

        assert o_rs2_addr = R2
            report "rs2 address incorrect" severity error;

        assert o_rd_addr = RD 
            report "rd address incorrect" severity error;

        assert o_arith = '0'
            report "arith flag incorrect" severity error;

        assert o_sign = '0'
            report "sign flag incorrect" severity error;

        assert o_opcode = ALUOP_SR
            report "opcode incorrect" severity error;

        assert o_shamt = ZERO_SHAMT
            report "shift amount incorrect" severity error;

        assert o_imm = ZERO_IMM  
            report "immediate incorrect" severity error;

        assert o_jmp = '0'
            report "jump flag incorrect" severity error;

        assert o_jal = '0'
            report "jal flag incorrect" severity error;

        assert o_brnch = '0'
            report "branch flag incorrect" severity error;

        assert o_src_imm = '0'
            report "src_imm flag incorrect" severity error;

        assert o_rshmt = '1'
            report "rshmt flag incorrect" severity error;

        assert o_wb = '1'
            report "write-back flag incorrect" severity error;

        assert o_we = '0'
            report "write-enable flag incorrect" severity error;

        assert o_re = '0'
            report "read-enable flag incorrect" severity error;
    
    
        -- SRA
        
        i_instr <= "0100000" & R2 & R1 & "101" & RD & "0110011";
        wait for 10 ns;

        -- Assertions for SRA instruction

        report "Result for instruction SRA : " severity note;
        
        assert o_rs1_addr = R1
            report "rs1 address incorrect" severity error;

        assert o_rs2_addr = R2
            report "rs2 address incorrect" severity error;

        assert o_rd_addr = RD 
            report "rd address incorrect" severity error;

        assert o_arith = '1'
            report "arith flag incorrect" severity error;

        assert o_sign = '0'
            report "sign flag incorrect" severity error;

        assert o_opcode = ALUOP_SR
            report "opcode incorrect" severity error;

        assert o_shamt = ZERO_SHAMT
            report "shift amount incorrect" severity error;

        assert o_imm = ZERO_IMM  
            report "immediate incorrect" severity error;

        assert o_jmp = '0'
            report "jump flag incorrect" severity error;

        assert o_jal = '0'
            report "jal flag incorrect" severity error;

        assert o_brnch = '0'
            report "branch flag incorrect" severity error;

        assert o_src_imm = '0'
            report "src_imm flag incorrect" severity error;

        assert o_rshmt = '1'
            report "rshmt flag incorrect" severity error;

        assert o_wb = '1'
            report "write-back flag incorrect" severity error;

        assert o_we = '0'
            report "write-enable flag incorrect" severity error;

        assert o_re = '0'
            report "read-enable flag incorrect" severity error;

        -- OR
        
        i_instr <= "0000000" & R2 & R1 & "110" & RD & "0110011";
        wait for 10 ns;

        -- Assertions for OR instruction

        report "Result for instruction OR : " severity note;
        
        assert o_rs1_addr = R1
            report "rs1 address incorrect" severity error;

        assert o_rs2_addr = R2
            report "rs2 address incorrect" severity error;

        assert o_rd_addr = RD 
            report "rd address incorrect" severity error;

        assert o_arith = '0'
            report "arith flag incorrect" severity error;

        assert o_sign = '0'
            report "sign flag incorrect" severity error;

        assert o_opcode = ALUOP_OR
            report "opcode incorrect" severity error;

        assert o_shamt = ZERO_SHAMT
            report "shift amount incorrect" severity error;

        assert o_imm = ZERO_IMM  
            report "immediate incorrect" severity error;

        assert o_jmp = '0'
            report "jump flag incorrect" severity error;

        assert o_jal = '0'
            report "jal flag incorrect" severity error;

        assert o_brnch = '0'
            report "branch flag incorrect" severity error;

        assert o_src_imm = '0'
            report "src_imm flag incorrect" severity error;

        assert o_rshmt = '0'
            report "rshmt flag incorrect" severity error;

        assert o_wb = '1'
            report "write-back flag incorrect" severity error;

        assert o_we = '0'
            report "write-enable flag incorrect" severity error;

        assert o_re = '0'
            report "read-enable flag incorrect" severity error;


        -- AND
        
        i_instr <= "0000000" & R2 & R1 & "111" & RD & "0110011";
        wait for 10 ns;

        -- Assertions for AND instruction

        report "Result for instruction AND : " severity note;
        
        assert o_rs1_addr = R1
            report "rs1 address incorrect" severity error;

        assert o_rs2_addr = R2
            report "rs2 address incorrect" severity error;

        assert o_rd_addr = RD 
            report "rd address incorrect" severity error;

        assert o_arith = '0'
            report "arith flag incorrect" severity error;

        assert o_sign = '0'
            report "sign flag incorrect" severity error;

        assert o_opcode = ALUOP_AND
            report "opcode incorrect" severity error;

        assert o_shamt = ZERO_SHAMT
            report "shift amount incorrect" severity error;

        assert o_imm = ZERO_IMM  
            report "immediate incorrect" severity error;

        assert o_jmp = '0'
            report "jump flag incorrect" severity error;

        assert o_jal = '0'
            report "jal flag incorrect" severity error;

        assert o_brnch = '0'
            report "branch flag incorrect" severity error;

        assert o_src_imm = '0'
            report "src_imm flag incorrect" severity error;

        assert o_rshmt = '0'
            report "rshmt flag incorrect" severity error;

        assert o_wb = '1'
            report "write-back flag incorrect" severity error;

        assert o_we = '0'
            report "write-enable flag incorrect" severity error;

        assert o_re = '0'
            report "read-enable flag incorrect" severity error;


        wait; -- Stop simulation
    end process;

    
end architecture tb;
