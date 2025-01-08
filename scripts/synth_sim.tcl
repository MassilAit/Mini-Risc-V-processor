#Setup 
vmap -c
vmap gsclib045 /CMC/kits/GPDK45/simlib/gsclib045_slow
vlib syn/work
vmap work syn/work

#Net List
vlog -work work ../implementation/syn/base_netlist/riscv_core.syn.v

#Compilation
vcom -2008 -work work ../sources/dpm.vhd
vcom -2008 -work work ../sources/riscv_core_tb.vhd

#Simulation

vsim -t ps -sdfmax dut=../implementation/syn/base_netlist/riscv_core.syn.sdf -L gsclib045 work.riscv_core_tb



