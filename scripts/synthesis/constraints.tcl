read_sdc $::env(CONST_DIR)/timing.sdc
report_timing -lint > $::env(SYN_REP_DIR)/riscv_core.timing_lint.rpt
report_clocks > $::env(SYN_REP_DIR)/riscv_core.clk.rpt
report_clocks -generated > $::env(SYN_REP_DIR)/riscv_core.clk.rpt
