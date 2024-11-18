library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.riscv_pkg.all;


entity riscv_instruction_fetch is
    port (
      i_clk       : in  std_logic;
      i_rstn      : in  std_logic;

      --From EX
      i_stall     : in  std_logic;
      i_flush     : in  std_logic;
      i_transfert : in  std_logic;
      i_target    : in  std_logic_vector(XLEN-1 downto 0);
    
      --Instruction memory signals
      i_imem_read : in  std_logic_vector(XLEN-1 downto 0);
      o_imem_addr : out std_logic_vector(XLEN-1 downto 0);

      --To decode
      o_pc_current   : out std_logic_vector(XLEN-1 downto 0);
      o_instr        : out std_logic_vector(XLEN-1 downto 0));
end entity riscv_instruction_fetch;


architecture beh of riscv_instruction_fetch is
    
  -- Component Declaration
  component riscv_pc
    generic (RESET_VECTOR : natural := 16#00000000#);
    port (
      i_clk       : in  std_logic;
      i_rstn      : in  std_logic;
      i_stall     : in  std_logic;
      i_transfert : in  std_logic;
      i_target    : in  std_logic_vector(XLEN-1 downto 0);
      o_pc        : out std_logic_vector(XLEN-1 downto 0)
    );
  end component;

  -- Internal Signals
  signal pc_out : std_logic_vector(XLEN-1 downto 0); -- Output from PC
  signal next_instruction : std_logic_vector(XLEN-1 downto 0);


begin
  -- Instantiate PC
  pc_instance : riscv_pc
    generic map (
      RESET_VECTOR => 16#00000000#
    )
    port map (
      i_clk       => i_clk,
      i_rstn      => i_rstn,
      i_stall     => i_stall,
      i_transfert => i_transfert,
      i_target    => i_target,
      o_pc        => pc_out
    );

    process(i_clk, i_rstn)
        begin
          if i_rstn = '0' then
            next_instruction <= x"00000013";
            o_pc_current <= pc_out;

          elsif rising_edge(i_clk) then
            if i_flush = '1' then
              
                next_instruction <= x"00000013"; -- RISC-V NOP instruction
            
              elsif i_stall = '1' then
              -- Stall: Hold the current state
              next_instruction <= next_instruction;
            
              else
              -- Normal operation: Update IF/ID register with fetched instruction
              next_instruction <= i_imem_read;
            end if;

            o_pc_current <= pc_out;

          end if;
    end process;


    o_imem_addr <= pc_out;
    o_instr <= next_instruction;



    
    
end architecture beh;