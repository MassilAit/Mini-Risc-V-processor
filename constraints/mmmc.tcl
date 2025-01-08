# Fichier     : mmmc.tcl
# Description : Multi-Mode Multi-Corner
# --------------------------------------
set DESIGN riscv_core

# constraint mode
create_constraint_mode -name const -sdc_files $::env(CONST_DIR)/${DESIGN}.syn.sdc

# rc corner
create_rc_corner -name rc -qx_tech_file $::env(BE_QRC_LIB)/gpdk045.tch

# Libraries
set fast_lib $::env(FE_TIM_LIB)/fast_vdd1v0_basicCells.lib
set slow_lib $::env(FE_TIM_LIB)/slow_vdd1v0_basicCells.lib

# operating conditions
create_op_cond -name fast_opcond -P 1.0 -V 1.0 -T 0 -library_file $fast_lib
create_op_cond -name slow_opcond -P 1.0 -V 0.9 -T 125.0 -library_file $slow_lib

# library sets
create_library_set -name fast_libset -timing $fast_lib -si $::env(BE_CDB_LIB)/fast.cdb
create_library_set -name slow_libset -timing $slow_lib -si $::env(BE_CDB_LIB)/slow.cdb

# delay corner
create_delay_corner -name fast_corner -library_set fast_libset -rc_corner rc
create_delay_corner -name slow_corner -library_set slow_libset -rc_corner rc

# analysis view
create_analysis_view -name fast_av -constraint_mode const -delay_corner fast_corner
create_analysis_view -name slow_av -constraint_mode const -delay_corner slow_corner
set_analysis_view -setup slow_av -hold fast_av
