library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.riscv_pkg.all;


entity tb_riscv_instruction_decode is
end entity tb_riscv_instruction_decode;


architecture tb of tb_riscv_instruction_decode is
    -- Clock and Reset
    signal i_clk       : std_logic := '1';
    signal i_rstn      : std_logic := '1';

    -- WB Signals
    signal i_wb        : std_logic := '0';
    signal i_rd_addr   : std_logic_vector(REG_WIDTH-1 downto 0) := (others => '0');
    signal i_rd_data   : std_logic_vector(XLEN-1 downto 0) := (others => '0');

    -- EX Signals
    signal i_flush     : std_logic := '0';
    signal i_stall     : std_logic := '0';

    -- IF Signals
    signal i_pc_current : std_logic_vector(XLEN-1 downto 0) := (others => '0');
    signal i_instr      : std_logic_vector(XLEN-1 downto 0) := (others => '0');

    -- Outputs to EX
    signal o_rs1_data   : std_logic_vector(XLEN-1 downto 0);
    signal o_rs2_data   : std_logic_vector(XLEN-1 downto 0);
    signal o_rs1_addr    : std_logic_vector(REG_WIDTH-1 downto 0);
    signal o_rs2_addr    : std_logic_vector(REG_WIDTH-1 downto 0);
    signal o_rd_addr    : std_logic_vector(REG_WIDTH-1 downto 0);
    signal o_arith      : std_logic;
    signal o_sign       : std_logic;
    signal o_opcode     : std_logic_vector(ALUOP_WIDTH-1 downto 0);
    signal o_shamt      : std_logic_vector(SHAMT_WIDTH-1 downto 0);
    signal o_imm        : std_logic_vector(XLEN-1 downto 0);
    signal o_jmp        : std_logic;
    signal o_jalr       : std_logic;
    signal o_brnch      : std_logic;
    signal o_src_imm    : std_logic;
    signal o_rshmt      : std_logic;
    signal o_wb         : std_logic;
    signal o_we         : std_logic;
    signal o_re         : std_logic;
    signal o_pc_current : std_logic_vector(XLEN-1 downto 0);

    -- Clock generation constant
    constant CLK_PERIOD : time := 100 ns;

begin

    -- DUT Instantiation
    DUT: entity work.riscv_instruction_decode
        port map (
            i_clk         => i_clk,
            i_rstn        => i_rstn,
            i_wb          => i_wb,
            i_rd_addr     => i_rd_addr,
            i_rd_data     => i_rd_data,
            i_flush       => i_flush,
            i_stall       => i_stall,
            i_pc_current  => i_pc_current,
            i_instr       => i_instr,
            o_rs1_data    => o_rs1_data,
            o_rs2_data    => o_rs2_data,
            o_rs1_addr    => o_rs1_addr,
            o_rs2_addr    => o_rs2_addr,
            o_rd_addr     => o_rd_addr,
            o_arith       => o_arith,
            o_sign        => o_sign,
            o_opcode      => o_opcode,
            o_shamt       => o_shamt,
            o_imm         => o_imm,
            o_jmp         => o_jmp,
            o_jalr        => o_jalr,
            o_brnch       => o_brnch,
            o_src_imm     => o_src_imm,
            o_rshmt       => o_rshmt,
            o_wb          => o_wb,
            o_we          => o_we,
            o_re          => o_re,
            o_pc_current  => o_pc_current
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
    begin

        i_rstn <= '0';

        wait for CLK_PERIOD;

        i_rstn <= '1';

        -- Write value 1 to register 1
        i_wb <= '1';
        i_rd_addr <= std_logic_vector(to_unsigned(1, REG_WIDTH)); -- Write address = 1
        i_rd_data <= std_logic_vector(to_unsigned(3, XLEN)); -- Write data = 3
        wait for CLK_PERIOD;
    
    
        -- Write value 2 to register 2
        i_wb <= '1';
        i_rd_addr <= std_logic_vector(to_unsigned(2, REG_WIDTH)); -- Write address = 2
        i_rd_data <= std_logic_vector(to_unsigned(4, XLEN)); -- Write data = 4
        wait for CLK_PERIOD;
    
        i_instr <= "0000000" & "00010" & "00001" & "000" & "00011" & "0110011"; -- Instruction ADD (reading from R1=1 and R2=2)
        i_pc_current <= "00000000000000000000000000000100"; --PC counter to 4 
        
        -- No data to read 
        i_wb <= '0';
        i_rd_addr <= (others => '0');
        i_rd_data <= (others => '0');
        
        wait for CLK_PERIOD;

        report "Result for instruction ADD : " severity note;

        assert o_pc_current = "00000000000000000000000000000100"
            report "pc_current incorrect" severity error;
    
        assert o_rs1_data = std_logic_vector(to_unsigned(3, XLEN))
            report "rs1 address incorrect" severity error;
    
        assert o_rs2_data = std_logic_vector(to_unsigned(4, XLEN))
            report "rs2 address incorrect" severity error;

        assert o_rs1_addr = "00001" 
            report "rs1 address incorrect" severity error;

        assert o_rs2_addr = "00010" 
            report "rs2 address incorrect" severity error;
                
        assert o_rd_addr = "00011" 
            report "rd address incorrect" severity error;
                
        assert o_arith = '0'
            report "arith flag incorrect" severity error;
                
        assert o_sign = '0'
            report "sign flag incorrect" severity error;
                
        assert o_opcode = ALUOP_ADD
            report "opcode incorrect" severity error;
                   
        assert o_jmp = '0'
            report "jump flag incorrect" severity error;
                
        assert o_jalr = '0'
            report "jalr flag incorrect" severity error;
                
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



        --Stalling

        i_stall <= '1';

        i_instr <= "0000000" & "00000" & "00000" & "000" & "00000" & "0000000"; -- Random instruction
        i_pc_current <= "00000000000000000000000000000111"; --PC counter to a diffrent value 
            
        -- No data to read 
        i_wb <= '0';
        i_rd_addr <= (others => '0');
        i_rd_data <= (others => '0');

        
        wait for CLK_PERIOD;

        report "Result for stalling : " severity note;

        assert o_pc_current = "00000000000000000000000000000100"
            report "pc_current incorrect" severity error;
    
        assert o_rs1_data = std_logic_vector(to_unsigned(3, XLEN))
            report "rs1 address incorrect" severity error;
    
        assert o_rs2_data = std_logic_vector(to_unsigned(4, XLEN))
            report "rs2 address incorrect" severity error;

        assert o_rs1_addr = "00001" 
            report "rs1 address incorrect" severity error;

        assert o_rs2_addr = "00010" 
            report "rs2 address incorrect" severity error;
                
        assert o_rd_addr = "00011" 
            report "rd address incorrect" severity error;
                
        assert o_arith = '0'
            report "arith flag incorrect" severity error;
                
        assert o_sign = '0'
            report "sign flag incorrect" severity error;
                
        assert o_opcode = ALUOP_ADD
            report "opcode incorrect" severity error;
                   
        assert o_jmp = '0'
            report "jump flag incorrect" severity error;
                
        assert o_jalr = '0'
            report "jalr flag incorrect" severity error;
                
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


        --Flushing

        i_flush <= '1';
        i_stall <= '0';

        i_instr <= "0000000" & "00000" & "00000" & "000" & "00000" & "0000000"; -- Random instruction
        i_pc_current <= "00000000000000000000000000000111"; --PC counter to a diffrent value 
            
        -- No data to read 
        i_wb <= '0';
        i_rd_addr <= (others => '0');
        i_rd_data <= (others => '0');

        
        wait for CLK_PERIOD;

        report "Result for flushing : " severity note;

        assert o_pc_current = "00000000000000000000000000000000"
            report "pc_current incorrect" severity error;
    
        assert o_rs1_data = std_logic_vector(to_unsigned(0, XLEN))
            report "rs1 address incorrect" severity error;
    
        assert o_rs2_data = std_logic_vector(to_unsigned(0, XLEN))
            report "rs2 address incorrect" severity error;

        assert o_rs1_addr = "00000" 
            report "rs1 address incorrect" severity error;

        assert o_rs2_addr = "00000" 
            report "rs2 address incorrect" severity error;
                
        assert o_rd_addr = "00000" 
            report "rd address incorrect" severity error;
                
        assert o_arith = '0'
            report "arith flag incorrect" severity error;
                
        assert o_sign = '0'
            report "sign flag incorrect" severity error;
                
        assert o_opcode = ALUOP_ADD
            report "opcode incorrect" severity error;
                   
        assert o_jmp = '0'
            report "jump flag incorrect" severity error;
                
        assert o_jalr = '0'
            report "jalr flag incorrect" severity error;
                
        assert o_brnch = '0'
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

    wait;
    end process stimulus_process;

    




    

end architecture tb;
