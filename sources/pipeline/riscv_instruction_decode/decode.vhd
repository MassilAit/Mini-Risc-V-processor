library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.riscv_pkg.all;

entity decode is
    port (
      i_instr     : in  std_logic_vector(XLEN-1 downto 0); --instruction to decode

      -- Registers
      o_rs1_addr  : out std_logic_vector(REG_WIDTH-1 downto 0); --register 1 adress
      o_rs2_addr  : out std_logic_vector(REG_WIDTH-1 downto 0); --register 2 adress
      o_rd_addr   : out std_logic_vector(REG_WIDTH-1 downto 0); -- Destination register

      -- ALU 
      o_arith     : out  std_logic;                                -- Arith/Logic
      o_sign      : out  std_logic;                                -- Signed/Unsigned
      o_opcode    : out  std_logic_vector(ALUOP_WIDTH-1 downto 0); -- ALU opcodes
      o_shamt     : out  std_logic_vector(SHAMT_WIDTH-1 downto 0); -- Shift Amount

      -- Immediate value
      o_imm       : out  std_logic_vector(XLEN-1 downto 0); -- Immediate value
      
      -- Flags
      o_jmp       : out std_logic;   --jmp instr
      o_brnch     : out std_logic;   --branch instr
      o_src_imm   : out std_logic;   --immediate value
      o_wb        : out std_logic;   --write register back
      o_we        : out std_logic;   --write memory
      o_re        : out std_logic);  --read memory
end entity decode;


architecture beh of decode is

begin
    
    decoding: process(i_instr)
    variable opcode : std_logic_vector(6 downto 0);
    variable funct3 : std_logic_vector(2 downto 0);
    variable funct7 : std_logic_vector(6 downto 0);

    begin
        opcode := i_instr(6 downto 0);
        funct3 := i_instr(14 downto 12);
        funct7 := i_instr(31 downto 25);

        -- Default values : 

        o_rs1_addr <= (others => '0'); 
        o_rs2_addr <= (others => '0');
        o_rd_addr <= (others => '0'); 
        o_arith <= '0';
        o_sign <= '0';
        o_opcode  <= ALUOP_ADD;
        o_shamt <= (others => '0');
        o_imm <= (others => '0');
        o_jmp <= '0';
        o_brnch <= '0';
        o_src_imm <= '0'; 
        o_wb <= '0';      
        o_we <= '0';
        o_re <= '0'; 

        case( opcode ) is
        
            when "0110011" =>  -- R-Type
                o_rs1_addr <= i_instr(19 downto 15); -- using rs1
                o_rs2_addr <= i_instr(24 downto 20); -- using rs2

                o_rd_addr <= i_instr(11 downto 7); --output register

                o_imm <= (others => '0'); -- No immediate value

                if funct3="000" and funct7="0000000" then --ADD
                    -- ALU  used : rs1 + rs2
                    o_arith <= '0';  -- addition
                    o_sign <= '0';   -- Programmer
                    o_opcode  <= ALUOP_ADD;
                    o_shamt <= (others => '0');

                    -- Flags
                    o_wb <= '1';   -- Write to register   

                
                elsif funct3="000" and funct7="0100000" then --SUB
                    -- ALU  used : rs1 - rs2
                    o_arith <= '1';  -- substraction
                    o_sign <= '0';   -- Programmer
                    o_opcode  <= ALUOP_ADD;
                    o_shamt <= (others => '0');

                    -- Flags
                    o_wb <= '1';   -- Write to register   


                elsif funct3="001" and funct7="0000000" then --SLL
                    -- ALU  used : rs1 << rs2
                    o_arith <= '0';  
                    o_sign <= '0';   
                    o_opcode  <= ALUOP_SL;
                    o_shamt <= (others => '0');

                    -- Flags
                    o_wb <= '1';   -- Write to register 

                elsif funct3="010" and funct7="0000000" then --SLT
                    -- ALU  used : rs1 < rs2 (signed)
                    o_arith <= '0';  
                    o_sign <= '1';   
                    o_opcode  <= ALUOP_SLT;
                    o_shamt <= (others => '0');

                    -- Flags
                    o_wb <= '1';   -- Write to register 

                elsif funct3="011" and funct7="0000000" then --SLTU
                    -- ALU  used : rs1 < rs2 (unsigned)
                    o_arith <= '0';  
                    o_sign <= '0';   
                    o_opcode  <= ALUOP_SLT;
                    o_shamt <= (others => '0');

                    -- Flags
                    o_wb <= '1';   -- Write to register 

                elsif funct3="100" and funct7="0000000" then --XOR
                    -- ALU  used : rs1 xor rs2 
                    o_arith <= '0';  
                    o_sign <= '0';   
                    o_opcode  <= ALUOP_XOR;
                    o_shamt <= (others => '0');

                    -- Flags
                    o_wb <= '1';   -- Write to register 

                elsif funct3="101" and funct7="0000000" then --SRL
                    -- ALU  used : rs1 >> rs2 (logical)
                    o_arith <= '0';  
                    o_sign <= '0';   
                    o_opcode  <= ALUOP_SR;
                    o_shamt <= (others => '0');

                    -- Flags
                    o_wb <= '1';   -- Write to register 

                elsif funct3="101" and funct7="0100000" then --SRA
                    -- ALU  used : rs1 >> rs2 (arithmetic)
                    o_arith <= '1';  
                    o_sign <= '0';   
                    o_opcode  <= ALUOP_SR;
                    o_shamt <= (others => '0');

                    -- Flags
                    o_wb <= '1';   -- Write to register 

                elsif funct3="110" and funct7="0000000" then --OR
                    -- ALU  used : rs1 or rs2 
                    o_arith <= '0';  
                    o_sign <= '0';   
                    o_opcode  <= ALUOP_OR;
                    o_shamt <= (others => '0');

                    -- Flags
                    o_wb <= '1';   -- Write to register 

                elsif funct3="111" and funct7="0000000" then --AND
                    -- ALU  used : rs1 or rs2 
                    o_arith <= '0';  
                    o_sign <= '0';   
                    o_opcode  <= ALUOP_AND;
                    o_shamt <= (others => '0');

                    -- Flags
                    o_wb <= '1';   -- Write to register 
                
                end if ;


            when "0110111" =>  -- U-Type

                -- Only instruction is LUI : 

                o_rs1_addr <= (others => '0'); --no rs1
                o_rs2_addr <= (others => '0'); --no rs2

                o_rd_addr <= i_instr(11 downto 7); --output register
                
                -- ALU : immediate+0
                o_arith <= '0';
                o_sign <= '0';
                o_opcode  <= ALUOP_ADD;
                o_shamt <= (others => '0');

                o_imm <= i_instr(31 downto 12) & x"000"; -- U-IMM

                -- Flags
                o_jmp <= '0';
                o_brnch <= '0';
                o_src_imm <= '1'; --Using the immediate in the ALU
                o_wb <= '1';      --We write the result back
                o_we <= '0';
                o_re <= '0';    


            when "1101111" =>  -- J-Type

                -- Only instruction is  JAL: 

                o_rs1_addr <= (others => '0'); --no rs1
                o_rs2_addr <= (others => '0'); --no rs2

                o_rd_addr <= i_instr(11 downto 7); --output register

                -- ALU  not used (default values)
                o_arith <= '0';
                o_sign <= '0';
                o_opcode  <= ALUOP_ADD;
                o_shamt <= (others => '0');

                o_imm <= std_logic_vector(signed(i_instr(31) & i_instr(19 downto 12) & i_instr(20) & i_instr(30 downto 21) & '0')); -- J-IMM

                -- Flags
                o_jmp <= '1';
                o_brnch <= '0';
                o_src_imm <= '0'; --We don't use the ALU
                o_wb <= '1';      --We write the result back
                o_we <= '0';
                o_re <= '0';   

            when "1100111" | "0000011" | "0010011"=>  -- I-Type

            when "1100011" =>  -- B-Type
                
                o_rs1_addr <= i_instr(19 downto 15); -- using rs1
                o_rs2_addr <= i_instr(24 downto 20); -- using rs2

                o_rd_addr <= (others => '0'); -- no output register

                o_imm <= std_logic_vector(signed(i_instr(31) & i_instr(7) & i_instr(30 downto 25) & i_instr(11 downto 8) & '0'));   -- B-IMM

                if funct3="000" then  -- BEQ instruction 
                    
                    -- ALU  used : rs1-rs2
                    o_arith <= '1';  -- substraction
                    o_sign <= '0';
                    o_opcode  <= ALUOP_ADD;
                    o_shamt <= (others => '0');

                    -- Flags
                    o_jmp <= '0';
                    o_brnch <= '1'; --branch
                    o_src_imm <= '0'; 
                    o_wb <= '0';      
                    o_we <= '0';
                    o_re <= '0';
                end if;
 

            when "0100011" => -- S-Type
                o_rs1_addr <= i_instr(19 downto 15); -- using rs1
                o_rs2_addr <= i_instr(24 downto 20); -- using rs2

                o_rd_addr <= (others => '0'); -- no output register

                o_imm <= std_logic_vector(signed(i_instr(31) & i_instr(30 downto 25) & i_instr(11 downto 7))); -- S-IMM

                if funct3="010" then  -- SW instruction 
                    
                    -- ALU  used : rs1 + IMM
                    o_arith <= '0';  -- addition
                    o_sign <= '1';   -- offset is signed
                    o_opcode  <= ALUOP_ADD;
                    o_shamt <= (others => '0');

                    -- Flags
                    o_jmp <= '0';
                    o_brnch <= '0'; 
                    o_src_imm <= '1'; 
                    o_wb <= '0';      
                    o_we <= '1';  -- Write to memory
                    o_re <= '0';
                end if;
                
            when others =>    -- Op code not recognize
                -- Defaults are already set; no further action required
                null;
        end case ;
        
        
    end process decoding;



end architecture beh;