library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.riscv_pkg.all;


entity tb_riscv_execute is
end entity tb_riscv_execute;


architecture tb of tb_riscv_execute is
    -- Clock and Reset
    signal i_clk       : std_logic := '1';
    signal i_rstn      : std_logic := '1';

    -- WB Signals
    signal i_wb_wb        : std_logic := '0';
    signal i_rd_addr_wb   : std_logic_vector(REG_WIDTH-1 downto 0) := (others => '0');
    signal i_rd_data_wb   : std_logic_vector(XLEN-1 downto 0) := (others => '0');

    -- IF Signals
    signal i_pc_current : std_logic_vector(XLEN-1 downto 0) := (others => '0');
    signal i_instr      : std_logic_vector(XLEN-1 downto 0) := (others => '0');

    -- ID -> EX (signals)
    signal rs1_data   : std_logic_vector(XLEN-1 downto 0);
    signal rs2_data   : std_logic_vector(XLEN-1 downto 0);
    signal rs1_addr   : std_logic_vector(REG_WIDTH-1 downto 0);
    signal rs2_addr   : std_logic_vector(REG_WIDTH-1 downto 0);
    signal rd_addr    : std_logic_vector(REG_WIDTH-1 downto 0);
    signal arith      : std_logic;
    signal sign       : std_logic;
    signal opcode     : std_logic_vector(ALUOP_WIDTH-1 downto 0);
    signal shamt      : std_logic_vector(SHAMT_WIDTH-1 downto 0);
    signal imm        : std_logic_vector(XLEN-1 downto 0);
    signal jmp        : std_logic;
    signal jalr       : std_logic;
    signal brnch      : std_logic;
    signal src_imm    : std_logic;
    signal rshmt      : std_logic;
    signal wb         : std_logic;
    signal we         : std_logic;
    signal re         : std_logic;
    signal pc_current : std_logic_vector(XLEN-1 downto 0);

    -- Forwarding
    
    signal i_mem_rd_addr : std_logic_vector(REG_WIDTH-1 downto 0) := (others => '0'); 
    signal i_mem_rd_data : std_logic_vector(XLEN-1 downto 0) := (others => '0'); 
    signal i_mem_rd_wb   : std_logic := '0';
    signal i_mem_rd_re   : std_logic := '0';
    
    signal i_wb_rd_addr :  std_logic_vector(REG_WIDTH-1 downto 0) := (others => '0');  
    signal i_wb_rd_data :  std_logic_vector(XLEN-1 downto 0) := (others => '0'); 
    signal i_wb_rd_wb   :  std_logic := '0';

    --EX outputs

    -- Control 

    signal o_stall     : std_logic;
    signal o_flush     : std_logic;
    signal o_transfert : std_logic;
    signal o_target    : std_logic_vector(XLEN-1 downto 0);

    -- To ME
    signal o_we         :  std_logic;   --write memory
    signal o_re         :  std_logic;  --read memory
    signal o_alu_result :  std_logic_vector(XLEN-1 downto 0); --alu_result
    signal o_wb         :  std_logic; -- write back result
    signal o_rd_addr    :  std_logic_vector(REG_WIDTH-1 downto 0); -- Destination register adress 
    signal o_store_data :  std_logic_vector(XLEN-1 downto 0);-- Adress to store in memory

    -- Clock generation constant
    constant CLK_PERIOD : time := 10 ns;

begin
    -- Decode stage 
    decode: entity work.riscv_instruction_decode
        port map (
            i_clk         => i_clk,
            i_rstn        => i_rstn,
            i_wb          => i_wb_wb,
            i_rd_addr     => i_rd_addr_wb,
            i_rd_data     => i_rd_data_wb,
            i_flush       => o_flush,
            i_stall       => o_stall,
            i_pc_current  => i_pc_current,
            i_instr       => i_instr,
            o_rs1_data    => rs1_data,
            o_rs2_data    => rs2_data,
            o_rs1_addr    => rs1_addr,
            o_rs2_addr    => rs2_addr,
            o_rd_addr     => rd_addr,
            o_arith       => arith,
            o_sign        => sign,
            o_opcode      => opcode,
            o_shamt       => shamt,
            o_imm         => imm,
            o_jmp         => jmp,
            o_jalr        => jalr,
            o_brnch       => brnch,
            o_src_imm     => src_imm,
            o_rshmt       => rshmt,
            o_wb          => wb,
            o_we          => we,
            o_re          => re,
            o_pc_current  => pc_current
        );

        DUT: entity work.riscv_execute
        port map (
            i_clk         => i_clk,
            i_rstn        => i_rstn,
            i_mem_rd_addr => i_mem_rd_addr,
            i_mem_rd_data => i_mem_rd_data,
            i_mem_rd_wb   => i_mem_rd_wb,
            i_mem_rd_re   => i_mem_rd_re,
            i_wb_rd_addr  => i_wb_rd_addr,
            i_wb_rd_data  => i_wb_rd_data,
            i_wb_rd_wb    => i_wb_rd_wb,
            i_rs1_data    => rs1_data,
            i_rs2_data    => rs2_data,
            i_rs1_addr    => rs1_addr,
            i_rs2_addr    => rs2_addr,
            i_rd_addr     => rd_addr,
            i_arith       => arith,
            i_sign        => sign,
            i_opcode      => opcode,
            i_shamt       => shamt,
            i_imm         => imm,
            i_jmp         => jmp,
            i_jalr        => jalr,
            i_brnch       => brnch,
            i_src_imm     => src_imm,
            i_rshmt       => rshmt,
            i_wb          => wb,
            i_we          => we,
            i_re          => re,
            i_pc_current  => pc_current,
            o_stall       => o_stall,     
            o_flush       => o_flush,     
            o_transfert   => o_transfert,
            o_target      => o_target,    
            o_we          => o_we,      
            o_re          => o_re,        
            o_alu_result  => o_alu_result,
            o_wb          => o_wb,       
            o_rd_addr     => o_rd_addr,   
            o_store_data  => o_store_data
        );

    -- Clock Generation Process
    clk_process : process
    begin
        while true loop
            i_clk <= '0';
            wait for CLK_PERIOD / 2;
            i_clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process clk_process;

    stimulus_process : process
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
        constant R1_VALUE : std_logic_vector(XLEN-1 downto 0) := std_logic_vector(to_unsigned(3, XLEN));
        constant R2_VALUE : std_logic_vector(XLEN-1 downto 0) := std_logic_vector(to_unsigned(4, XLEN));

        constant PC_VALUE : std_logic_vector(31 downto 0) :="00000000000000000000000000000100";
    begin
        i_rstn <= '0'; -- Activate reset
        wait for CLK_PERIOD/2;
        i_rstn <= '1'; -- Deactivate reset

        -- Write value 1 to register 1
        i_wb_wb <= '1';
        i_rd_addr_wb <= R1; -- Write address = 1
        i_rd_data_wb <= R1_VALUE; -- Write data = 3
        wait for CLK_PERIOD;
    
    
        -- Write value 2 to register 2
        i_wb_wb <= '1';
        i_rd_addr_wb <= R2; -- Write address = 2
        i_rd_data_wb <= R2_VALUE; -- Write data = 4
        wait for CLK_PERIOD;

        i_wb_wb <= '0';
        i_pc_current <= PC_VALUE;

        -- LUI instruction
        i_instr <= U_IMM & RD & "0110111";
        wait for CLK_PERIOD*2;
        wait for CLK_PERIOD/2;

        report "Result for instruction LUI : " severity note;

        assert o_stall = '0'
            report "stall flag incorrect" severity error;

        assert o_flush = '0'
            report "flush flag incorrect" severity error;
        
        assert o_transfert = '0'
            report "transfert flag incorrect" severity error;

        assert o_target = std_logic_vector(signed(PC_VALUE)+signed(U_IMM_32))
            report "target value incorrect" severity error;

        assert o_we = '0'
            report "write memory flag incorrect" severity error;

        assert o_re = '0'
            report "read memory flag incorrect" severity error;
        
        assert o_alu_result = U_IMM_32
            report "alu result incorrect" severity error;

        assert o_rd_addr = RD
            report "rd addr incorrect" severity error;

        assert o_store_data = ZERO_IMM
            report "store data incorrect" severity error;

        
        -- JAL instruction
        i_instr <= J_IMM & RD & "1101111";
        wait for CLK_PERIOD; -- assertion on not clocked signals
        assert o_stall = '0'
            report "stall flag incorrect" severity error;

        assert o_flush = '1'
            report "flush flag incorrect" severity error;
        
        assert o_transfert = '1'
            report "transfert flag incorrect" severity error;

        assert o_target = std_logic_vector(signed(PC_VALUE)+signed(J_IMM_32))
            report "target value incorrect" severity error; 


        wait for CLK_PERIOD; --assertion on clocked signals

        report "Result for instruction JALL : " severity note;

        assert o_we = '0'
            report "write memory flag incorrect" severity error;

        assert o_re = '0'
            report "read memory flag incorrect" severity error;
        
        assert o_alu_result = std_logic_vector(signed(PC_VALUE)+4)
            report "alu result incorrect" severity error;

        assert o_rd_addr = RD
            report "rd addr incorrect" severity error;

        assert o_wb = '1'
            report "write back flag incorrect" severity error;

        assert o_store_data = ZERO_IMM
            report "store data incorrect" severity error;


        -- JALR instruction
        i_instr <= I_IMM & R1 & "000" & RD & "1100111";
        wait for CLK_PERIOD; -- assertion on not clocked signals

        report "Result for instruction JALR : " severity note;

        assert o_stall = '0'
            report "stall flag incorrect" severity error;

        assert o_flush = '1'
            report "flush flag incorrect" severity error;
        
        assert o_transfert = '1'
            report "transfert flag incorrect" severity error;

        assert o_target = std_logic_vector(signed(R1_VALUE)+signed(I_IMM_32))
            report "target value incorrect" severity error; 


        wait for CLK_PERIOD; --assertion on clocked signals

        assert o_we = '0'
            report "write memory flag incorrect" severity error;

        assert o_re = '0'
            report "read memory flag incorrect" severity error;
        
        assert o_alu_result = std_logic_vector(signed(PC_VALUE)+4)
            report "alu result incorrect" severity error;

        assert o_rd_addr = RD
            report "rd addr incorrect" severity error;
        
        assert o_wb = '1'
            report "write back flag incorrect" severity error;

        assert o_store_data = ZERO_IMM
            report "store data incorrect" severity error;


         -- BEQ instruction
         i_instr <= B_IMM1 & R2 & R1 & "000" & B_IMM2 & "1100011";
         wait for CLK_PERIOD; -- assertion on not clocked signals
 
         report "Result for instruction BEQ : " severity note;
 
         assert o_stall = '0'
             report "stall flag incorrect" severity error;
 
         assert o_flush = '0'
             report "flush flag incorrect" severity error;
         
         assert o_transfert = '0'
             report "transfert flag incorrect" severity error;
 
         assert o_target = std_logic_vector(signed(PC_VALUE)+signed(B_IMM_32))
             report "target value incorrect" severity error; 
 
 
         wait for CLK_PERIOD; --assertion on clocked signals
 
         assert o_we = '0'
             report "write memory flag incorrect" severity error;
 
         assert o_re = '0'
             report "read memory flag incorrect" severity error;
         
         assert o_alu_result = std_logic_vector(to_signed(-1,XLEN))
             report "alu result incorrect" severity error;
 
         assert o_rd_addr = ZERO_REG
             report "rd addr incorrect" severity error;

        assert o_wb = '0'
             report "write back flag incorrect" severity error;
 
         assert o_store_data = R2_VALUE
             report "store data incorrect" severity error;

        -- LW instruction
        i_instr <= I_IMM & R1 & "010" & RD & "0000011";
        wait for CLK_PERIOD; -- assertion on not clocked signals

        report "Result for instruction LW : " severity note;

        assert o_stall = '0'
            report "stall flag incorrect" severity error;

        assert o_flush = '0'
            report "flush flag incorrect" severity error;
        
        assert o_transfert = '0'
            report "transfert flag incorrect" severity error;

        assert o_target = std_logic_vector(signed(PC_VALUE)+signed(I_IMM_32))
            report "target value incorrect" severity error; 


        wait for CLK_PERIOD; --assertion on clocked signals

        assert o_we = '0'
            report "write memory flag incorrect" severity error;

        assert o_re = '1'
            report "read memory flag incorrect" severity error;
        
        assert o_alu_result = std_logic_vector(signed(R1_VALUE)+signed(I_IMM_32))
            report "alu result incorrect" severity error;

        assert o_rd_addr = RD
            report "rd addr incorrect" severity error;

       assert o_wb = '1'
            report "write back flag incorrect" severity error;

        assert o_store_data = ZERO_IMM
            report "store data incorrect" severity error;


        -- SW instruction
        i_instr <= S_IMM1 & R2 & R1 & "010" & S_IMM2 & "0100011";
        wait for CLK_PERIOD; -- assertion on not clocked signals

        report "Result for instruction SW : " severity note;

        assert o_stall = '0'
            report "stall flag incorrect" severity error;

        assert o_flush = '0'
            report "flush flag incorrect" severity error;
        
        assert o_transfert = '0'
            report "transfert flag incorrect" severity error;

        assert o_target = std_logic_vector(signed(PC_VALUE)+signed(S_IMM_32))
            report "target value incorrect" severity error; 


        wait for CLK_PERIOD; --assertion on clocked signals

        assert o_we = '1'
            report "write memory flag incorrect" severity error;

        assert o_re = '0'
            report "read memory flag incorrect" severity error;
        
        assert o_alu_result = std_logic_vector(signed(R1_VALUE)+signed(S_IMM_32))
            report "alu result incorrect" severity error;

        assert o_rd_addr = ZERO_REG
            report "rd addr incorrect" severity error;

       assert o_wb = '0'
            report "write back flag incorrect" severity error;

        assert o_store_data = R2_VALUE
            report "store data incorrect" severity error;


        -- ADDI instruction
        i_instr <= I_IMM & R1 & "000" & RD & "0010011";
        wait for CLK_PERIOD; -- assertion on not clocked signals

        report "Result for instruction ADDI : " severity note;

        assert o_stall = '0'
            report "stall flag incorrect" severity error;

        assert o_flush = '0'
            report "flush flag incorrect" severity error;
        
        assert o_transfert = '0'
            report "transfert flag incorrect" severity error;

        assert o_target = std_logic_vector(signed(PC_VALUE)+signed(I_IMM_32))
            report "target value incorrect" severity error; 


        wait for CLK_PERIOD; --assertion on clocked signals

        assert o_we = '0'
            report "write memory flag incorrect" severity error;

        assert o_re = '0'
            report "read memory flag incorrect" severity error;
        
        assert o_alu_result = std_logic_vector(unsigned(R1_VALUE)+unsigned(I_IMM_32))
            report "alu result incorrect" severity error;

        assert o_rd_addr = RD
            report "rd addr incorrect" severity error;

       assert o_wb = '1'
            report "write back flag incorrect" severity error;

        assert o_store_data = ZERO_IMM
            report "store data incorrect" severity error;


        -- SLTI instruction
        i_instr <= I_IMM & R1 & "010" & RD & "0010011";
        wait for CLK_PERIOD; -- assertion on not clocked signals

        report "Result for instruction SLTI : " severity note;

        assert o_stall = '0'
            report "stall flag incorrect" severity error;

        assert o_flush = '0'
            report "flush flag incorrect" severity error;
        
        assert o_transfert = '0'
            report "transfert flag incorrect" severity error;

        assert o_target = std_logic_vector(signed(PC_VALUE)+signed(I_IMM_32))
            report "target value incorrect" severity error; 


        wait for CLK_PERIOD; --assertion on clocked signals

        assert o_we = '0'
            report "write memory flag incorrect" severity error;

        assert o_re = '0'
            report "read memory flag incorrect" severity error;
        
        assert o_alu_result = std_logic_vector(to_unsigned(1, XLEN))
            report "alu result incorrect" severity error;

        assert o_rd_addr = RD
            report "rd addr incorrect" severity error;

       assert o_wb = '1'
            report "write back flag incorrect" severity error;

        assert o_store_data = ZERO_IMM
            report "store data incorrect" severity error;


        -- SLTUI instruction
        i_instr <= I_IMM & R1 & "011" & RD & "0010011";
        wait for CLK_PERIOD; -- assertion on not clocked signals

        report "Result for instruction SLTUI : " severity note;

        assert o_stall = '0'
            report "stall flag incorrect" severity error;

        assert o_flush = '0'
            report "flush flag incorrect" severity error;
        
        assert o_transfert = '0'
            report "transfert flag incorrect" severity error;

        assert o_target = std_logic_vector(signed(PC_VALUE)+signed(I_IMM_32))
            report "target value incorrect" severity error; 


        wait for CLK_PERIOD; --assertion on clocked signals

        assert o_we = '0'
            report "write memory flag incorrect" severity error;

        assert o_re = '0'
            report "read memory flag incorrect" severity error;
        
        assert o_alu_result = std_logic_vector(to_unsigned(1, XLEN))
            report "alu result incorrect" severity error;

        assert o_rd_addr = RD
            report "rd addr incorrect" severity error;

       assert o_wb = '1'
            report "write back flag incorrect" severity error;

        assert o_store_data = ZERO_IMM
            report "store data incorrect" severity error;



        -- XORI instruction
        i_instr <= I_IMM & R1 & "100" & RD & "0010011";
        wait for CLK_PERIOD; -- assertion on not clocked signals

        report "Result for instruction XORI : " severity note;

        assert o_stall = '0'
            report "stall flag incorrect" severity error;

        assert o_flush = '0'
            report "flush flag incorrect" severity error;
        
        assert o_transfert = '0'
            report "transfert flag incorrect" severity error;

        assert o_target = std_logic_vector(signed(PC_VALUE)+signed(I_IMM_32))
            report "target value incorrect" severity error; 


        wait for CLK_PERIOD; --assertion on clocked signals

        assert o_we = '0'
            report "write memory flag incorrect" severity error;

        assert o_re = '0'
            report "read memory flag incorrect" severity error;
        
        assert o_alu_result = (R1_VALUE xor I_IMM_32)
            report "alu result incorrect" severity error;

        assert o_rd_addr = RD
            report "rd addr incorrect" severity error;

       assert o_wb = '1'
            report "write back flag incorrect" severity error;

        assert o_store_data = ZERO_IMM
            report "store data incorrect" severity error;



        -- ADD instruction
        i_instr <= "0000000" & R2 & R1 & "000" & RD & "0110011";
        wait for CLK_PERIOD; -- assertion on not clocked signals

        report "Result for instruction ADD : " severity note;

        assert o_stall = '0'
            report "stall flag incorrect" severity error;

        assert o_flush = '0'
            report "flush flag incorrect" severity error;
        
        assert o_transfert = '0'
            report "transfert flag incorrect" severity error;

        assert o_target = std_logic_vector(signed(PC_VALUE)+to_signed(0,XlEN))
            report "target value incorrect" severity error; 


        wait for CLK_PERIOD; --assertion on clocked signals

        assert o_we = '0'
            report "write memory flag incorrect" severity error;

        assert o_re = '0'
            report "read memory flag incorrect" severity error;
        
        assert o_alu_result = std_logic_vector(unsigned(R1_VALUE)+unsigned(R2_VALUE))
            report "alu result incorrect" severity error;

        assert o_rd_addr = RD
            report "rd addr incorrect" severity error;

       assert o_wb = '1'
            report "write back flag incorrect" severity error;

        assert o_store_data = R2_VALUE
            report "store data incorrect" severity error;


        -- SLL instruction
        i_instr <= "0000000" & R2 & R1 & "001" & RD & "0110011";
        wait for CLK_PERIOD; -- assertion on not clocked signals

        report "Result for instruction SLL : " severity note;

        assert o_stall = '0'
            report "stall flag incorrect" severity error;

        assert o_flush = '0'
            report "flush flag incorrect" severity error;
        
        assert o_transfert = '0'
            report "transfert flag incorrect" severity error;

        assert o_target = std_logic_vector(signed(PC_VALUE)+to_signed(0,XlEN))
            report "target value incorrect" severity error; 


        wait for CLK_PERIOD; --assertion on clocked signals

        assert o_we = '0'
            report "write memory flag incorrect" severity error;

        assert o_re = '0'
            report "read memory flag incorrect" severity error;
        
        assert o_alu_result = std_logic_vector(shift_left(unsigned(R1_VALUE), to_integer(unsigned(R2_VALUE(SHAMT_WIDTH-1 downto 0)))))
            report "alu result incorrect" severity error;

        assert o_rd_addr = RD
            report "rd addr incorrect" severity error;

       assert o_wb = '1'
            report "write back flag incorrect" severity error;

        assert o_store_data = R2_VALUE
            report "store data incorrect" severity error;


        wait;
    end process stimulus_process;


end architecture tb;

