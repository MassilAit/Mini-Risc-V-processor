setPinAssignMode -pinEditInBatch true

# Assign reset and clock pins to the top edge (edge 0)
editPin -pin [list i_rstn i_clk] -edge 0 -layer 4 -spreadType SIDE -offsetEnd 2 -offsetStart 2 -spreadDirection clockwise -pinWidth 0.08 -pinDepth 0.335 -fixOverlap 1

# Assign instruction memory enable to the right edge (edge 1)
editPin -pin [list o_imem_en] -edge 1 -layer 4 -spreadType SIDE -offsetEnd 2 -offsetStart 2 -spreadDirection clockwise -pinWidth 0.08 -pinDepth 0.335 -fixOverlap 1

# Assign instruction memory address (9 bits) to the right edge (edge 1)
set imem_addr_pins {}
for {set i 0} {$i <= 8} {incr i} {
    lappend imem_addr_pins "o_imem_addr[$i]"
}
editPin -pin $imem_addr_pins -edge 1 -layer 4 -spreadType SIDE -offsetEnd 2 -offsetStart 2 -spreadDirection clockwise -pinWidth 0.08 -pinDepth 0.335 -fixOverlap 1

# Assign data memory enable and write enable to the right edge (edge 1)
editPin -pin [list o_dmem_en o_dmem_we] -edge 1 -layer 4 -spreadType SIDE -offsetEnd 2 -offsetStart 2 -spreadDirection counterclockwise -pinWidth 0.08 -pinDepth 0.335 -fixOverlap 1

# Assign data memory address (9 bits) to the right edge (edge 2, more space for data-related signals)
set dmem_addr_pins {}
for {set i 0} {$i <= 8} {incr i} {
    lappend dmem_addr_pins "o_dmem_addr[$i]"
}
editPin -pin $dmem_addr_pins -edge 2 -layer 4 -spreadType SIDE -offsetEnd 2 -offsetStart 2 -spreadDirection counterclockwise -pinWidth 0.08 -pinDepth 0.335 -fixOverlap 1

# Assign instruction memory read data (32 bits) to the right edge (edge 2)
set imem_read_pins {}
for {set i 0} {$i <= 31} {incr i} {
    lappend imem_read_pins "i_imem_read[$i]"
}
editPin -pin $imem_read_pins -edge 2 -layer 4 -spreadType SIDE -offsetEnd 2 -offsetStart 2 -spreadDirection counterclockwise -pinWidth 0.08 -pinDepth 0.335 -fixOverlap 1

# Assign data memory read data (32 bits) to the right edge (edge 2)
set dmem_read_pins {}
for {set i 0} {$i <= 31} {incr i} {
    lappend dmem_read_pins "i_dmem_read[$i]"
}
editPin -pin $dmem_read_pins -edge 2 -layer 4 -spreadType SIDE -offsetEnd 2 -offsetStart 2 -spreadDirection counterclockwise -pinWidth 0.08 -pinDepth 0.335 -fixOverlap 1

# Assign data memory write data (32 bits) to the right edge (edge 2)
set dmem_write_pins {}
for {set i 0} {$i <= 31} {incr i} {
    lappend dmem_write_pins "o_dmem_write[$i]"
}
editPin -pin $dmem_write_pins -edge 2 -layer 4 -spreadType SIDE -offsetEnd 2 -offsetStart 2 -spreadDirection counterclockwise -pinWidth 0.08 -pinDepth 0.335 -fixOverlap 1

# Assign DFT pins (scan enable, test mode, TDI, TDO) to the left edge (edge 3)
editPin -pin [list i_scan_en i_test_mode i_tdi o_tdo] -edge 3 -layer 3 -spreadType SIDE -offsetEnd 2 -offsetStart 2 -spreadDirection clockwise -pinWidth 0.08 -pinDepth 0.335 -fixOverlap 1
