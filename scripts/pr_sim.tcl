#Setup 
vmap -c
vmap gsclib045 /CMC/kits/GPDK45/simlib/gsclib045_slow
vlib pvr/work
vmap work pvr/work

#Net List
vlog -work work ../implementation/pnr/base_netlist/riscv_core.pnr.v

#Compilation
vcom -2008 -work work ../sources/dpm.vhd
vcom -2008 -work work ../sources/riscv_core_tb.vhd

#Simulation

vsim -t ps -sdfmax dut=../implementation/pnr/base_netlist/riscv_core.pnr.sdf -L gsclib045 work.riscv_core_tb
