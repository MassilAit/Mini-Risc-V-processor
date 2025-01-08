#### SETUP ######
vlib beh/work
vmap -c
vmap work beh/work


###### COMPILATION #########

# Package
vcom -2008 -work work ../sources/riscv_pkg.vhd

#Modules
vcom -2008 -work work ../sources/riscv_adder.vhd
vcom -2008 -work work ../sources/riscv_rf.vhd
vcom -2008 -work work ../sources/riscv_pc.vhd
vcom -2008 -work work ../sources/riscv_alu.vhd

#Pipeline
vcom -2008 -work work ../sources/riscv_instruction_fetch.vhd
vcom -2008 -work work ../sources/decode.vhd
vcom -2008 -work work ../sources/riscv_instruction_decode.vhd
vcom -2008 -work work ../sources/riscv_execute.vhd
vcom -2008 -work work ../sources/riscv_memory.vhd
vcom -2008 -work work ../sources/riscv_write_back.vhd

#Core 
vcom -2008 -work work ../sources/riscv_core.vhd

#Memory 
vcom -2008 -work work ../sources/dpm.vhd

#Testbench
vcom -2008 -work work ../sources/riscv_core_tb.vhd



###### RUNNING #######
vsim -t ps work.riscv_core_tb
