# Synthese generique
set_db syn_generic_effort high
syn_generic riscv_core
write_hdl > $::env(SYN_NET_DIR)/riscv_core.syn_gen.v

#Cellules standards
set_db syn_map_effort high
syn_map riscv_core
write_hdl > $::env(SYN_NET_DIR)/riscv_core.syn_map.v

#Optimisation du systeme
set_db syn_opt_effort high
syn_opt riscv_core
write_hdl > $::env(SYN_NET_DIR)/riscv_core.syn_opt.v
