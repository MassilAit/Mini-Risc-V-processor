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
  signal pc_delay: std_logic_vector(XLEN-1 downto 0); -- delayed PC to match instruction
  signal next_instruction : std_logic_vector(XLEN-1 downto 0);
  signal pc_current : std_logic_vector(XLEN-1 downto 0);
  signal flush_latched : std_logic := '0'; -- Latched flush signal


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


    -- Latching the flush signal for 1 cycle
    process(i_clk, i_rstn)
    begin
        if i_rstn = '0' then
            flush_latched <= '0';
        elsif rising_edge(i_clk) then
            if i_flush = '1' then
                flush_latched <= '1'; -- Latch the flush signal
            elsif flush_latched = '1' then
                flush_latched <= '0'; -- Release the latch after 1 cycle
            end if;
        end if;
    end process;

    -- Register for the pc_counter
    delayed_pc: process(i_clk, i_rstn)
    begin
      if i_rstn = '0' then
        pc_delay<=pc_out;
        
      elsif rising_edge(i_clk) then
        if i_stall = '1' then
          pc_delay <=pc_delay;

        else 
          pc_delay <= pc_out;

        end if;
        
      end if;
    end process delayed_pc;


    -- Mux for the o_imen_addr in stall mode
    process(pc_out, pc_delay, i_stall)
    begin
      if i_stall = '1' then
        o_imem_addr <=pc_delay;

      else 
        o_imem_addr <= pc_out;

      end if;
      
    end process ;


    --IF/ID register
    process(i_clk, i_rstn)
        begin
          if i_rstn = '0' then
            next_instruction <= x"00000013";
            pc_current <= pc_delay;

          elsif rising_edge(i_clk) then
            if (flush_latched or i_flush) = '1' then
              
                next_instruction <= x"00000013"; -- RISC-V NOP instruction
                pc_current <= pc_current;
            
              elsif i_stall = '1' then
              -- Stall: Hold the current state
              next_instruction <= next_instruction;
              pc_current <= pc_current;
            
              else
              -- Normal operation: Update IF/ID register with fetched instruction
              next_instruction <= i_imem_read;
              pc_current <= pc_delay;
            end if;

    

          end if;
    end process;



                
    o_pc_current <= pc_current;
    o_instr <= next_instruction;





    
    
end architecture beh;