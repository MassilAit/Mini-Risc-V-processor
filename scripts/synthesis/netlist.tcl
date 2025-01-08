write_hdl > $::env(SYN_NET_DIR)/riscv_core.syn.v
write_sdf -nonegchecks -setuphold split -version 2.1 > $::env(SYN_NET_DIR)/riscv_core.syn.sdf
write_sdc > $::env(CONST_DIR)/riscv_core.syn.sdc
