# Fichier    : timing.sdc
# Description: Contraintes temporelles du core
# ------------------------------------------------
# Unités par défaut
set_time_unit -picoseconds
set_load_unit -femtofarads

# Point de fonctionnement (1.1V, OC ; 0.9V, 125C)
set_operating_conditions -max_library PVT_1P1V_0C -min_library PVT_0P9V_125C

# Horloge principale (50 MHz)
set clk "clk"
create_clock -period 20000 -name $clk [get_ports i_clk]

# Incertitudes sur l'horloge: setup = 100ps, hold = 30ps
set_db [get_clocks $clk] .clock_setup_uncertainty 100
set_db [get_clocks $clk] .clock_hold_uncertainty  30

# Reset
set_false_path -from [get_ports i_rstn]

# Entrées
set_input_delay 200 -clock [get_clocks $clk] [all_inputs]
set_db [all_inputs] .external_driver [vfind [vfind / -libcell BUFX20] -libpin Y]

# Sorties
set_output_delay 200 -clock [get_clocks $clk] [all_outputs]
set_db [all_outputs] .external_pin_cap 500
