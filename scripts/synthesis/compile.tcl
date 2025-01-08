# Package
read_hdl -vhdl riscv_pkg.vhd

#Modules
read_hdl -vhdl riscv_adder.vhd
read_hdl -vhdl riscv_rf.vhd
read_hdl -vhdl riscv_pc.vhd
read_hdl -vhdl riscv_alu.vhd

#Pipeline
read_hdl -vhdl riscv_instruction_fetch.vhd
read_hdl -vhdl decode.vhd
read_hdl -vhdl riscv_instruction_decode.vhd
read_hdl -vhdl riscv_execute.vhd
read_hdl -vhdl riscv_memory.vhd
read_hdl -vhdl riscv_write_back.vhd

#Core 
read_hdl -vhdl riscv_core.vhd

#Elaborate
elaborate riscv_core

#Checking
check_design -unresolved
