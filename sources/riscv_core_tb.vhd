-------------------------------------------------------------------------------
-- Project    : ELE8304 : Circuits intégrés à très grande échelle
-- Polytechnique Montreal
-------------------------------------------------------------------------------
-- File       : riscv_core_tb.vhd
-- Author     : Theo Dupuis
-- Created    : 2022-11-22
-------------------------------------------------------------------------------
-- Description : TestBench for riscv_core
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Commentaire : 
--						Le mémoire simulee MEM0 n'est adressable que par mot de 32b, 
--						le compteur de programme (adresse de l'instruction suivante) 
--						doit donc etre divise par 4 (ou srl 2) avant d'etre connecte
--						a la memoire.
--						Bien que le bus d'adressage presente une largeur de 16b,
--						seul les 9 bits de poids faible de l'adresse sont conserve 
--						en accord avec la documentation.
-------------------------------------------------------------------------------
library ieee; 
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

library std;
use     std.textio.all;                                                      
use     std.env.all;

library work;
use     work.all;

entity riscv_core_tb is 
end riscv_core_tb;

architecture tb of riscv_core_tb is
  
signal	clk		: std_logic := '0';
signal	rstn		: std_logic := '0';

signal imem_en : std_logic;
signal imem_addr : std_logic_vector(DEPTH-1 downto 0);
signal imem_read : std_logic_vector(31 downto 0);

signal dmem_en : std_logic;
signal dmem_we : std_logic;
signal dmem_addr : std_logic_vector(DEPTH-1 downto 0);
signal dmem_read : std_logic_vector(31 downto 0);
signal dmem_write : std_logic_vector(31 downto 0);

signal imem_addr_div4 : std_logic_vector(DEPTH-1 downto 0);
signal dmem_addr_div4 : std_logic_vector(DEPTH-1 downto 0);

constant PERIOD   : time := 100 ns;

begin

MEM0 : entity work.dpm 
  generic map (
    WIDTH => 32,
    DEPTH => 9,
    RESET => 16#00000000#,
    INIT  => "riscv_basic.mem")
  port map (
    -- Port A
    i_a_clk   => clk,          -- Clock
    i_a_rstn  => rstn,         -- Reset Address
    i_a_en    => imem_en,            -- Port enable
    i_a_we    => '0',            -- Write enable
    i_a_addr  => imem_addr_div4(8 downto 0),     	 -- Address port			
    i_a_write => X"00000000",      	 -- Data write port
    o_a_read  => imem_read,-- Data read port
    -- Port B
    i_b_clk   => clk,          -- Clock
    i_b_rstn  => rstn,           -- Reset Address
    i_b_en    => dmem_en,            -- Port enable
    i_b_we    => dmem_we,                -- Write enable
    i_b_addr  => dmem_addr_div4(8 downto 0),      -- Address port  --Mettre adresse initiale a 1000 kb
    i_b_write => dmem_write,     -- Data write port
    o_b_read  => dmem_read    	 -- Data read port
);


imem_addr_div4 <= imem_addr srl 2;     --the memory is only word adressable and not byte so divide the instruction adress by 4
dmem_addr_div4 <= dmem_addr srl 2;     

DUT : entity work.riscv_core 
port map(
	i_rstn => rstn,
	i_clk  => clk,
	o_imem_en => imem_en,
	o_imem_addr => imem_addr,
	i_imem_read => imem_read,
	o_dmem_en   => dmem_en,
	o_dmem_we   => dmem_we,
	o_dmem_addr => dmem_addr,
	i_dmem_read => dmem_read,
	o_dmem_write=> dmem_write,
-- DFT
	i_scan_en => '0',
	i_test_mode => '0',
	i_tdi => '0',
	o_tdo => open
);
	
clk <= not clk after PERIOD/2 ;
rstn <= '1' after 2*PERIOD;
  
end architecture tb;
