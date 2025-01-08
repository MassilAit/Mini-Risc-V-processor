set_db information_level 9
set_db hdl_vhdl_read_version 2008
set_db init_hdl_search_path $::env(SRC_DIR)
set_db init_lib_search_path [list $::env(FE_TIM_LIB) $::env(BE_QRC_LIB) $::env(BE_LEF_LIB)]
read_libs -max_libs slow_vdd1v0_basicCells.lib -min_libs fast_vdd1v0_basicCells.lib
read_physical -lef gsclib045_tech.lef
read_qrc gpdk045.tch
set_db interconnect_mode ple

