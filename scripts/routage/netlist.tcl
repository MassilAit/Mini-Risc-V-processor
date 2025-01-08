saveNetlist $::env(PNR_NET_DIR)/riscv_core.pnr.v
write_sdf -version 2.1 -target_application verilog -interconn noport $::env(PNR_NET_DIR)/riscv_core.pnr.sdf


