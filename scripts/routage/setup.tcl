#Initialisation des librairies
set init_oa_ref_lib [list gsclib045_tech gsclib045 gpdk045 giolib045]

#Initialisation de la netlist et du top-level
set init_verilog $::env(SYN_NET_DIR)/riscv_core.syn.v
set init_design_settop 1
set init_top_cell riscv_core

#Initialisation de l’alimentation
set init_pwr_net VDD
set init_gnd_net VSS

#MMMC
set init_mmmc_file $::env(CONST_DIR)/mmmc.tcl
init_design
