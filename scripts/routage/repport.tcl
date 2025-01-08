#DRC
set_verify_drc_mode -report $::env(PNR_REP_DIR)/riscv_core.drc.rpt
verify_drc

#STA
timeDesign -postRoute -outDir $::env(PNR_REP_DIR)/timing
report_timing > $::env(PNR_REP_DIR)/riscv_core.tim.rpt

