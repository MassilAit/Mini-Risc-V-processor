#Definition des cellules
set_ccopt_property buffer_cells [list CLKBUFX20 CLKBUFX16 CLKBUFX12 CLKBUFX8 CLKBUFX6 CLKBUFX4 CLKBUFX3 CLKBUFX2]
set_ccopt_property inverter_cells [list CLKINVX20 CLKINVX6 CLKINVX8 CLKINVX16 CLKINVX12 CLKINVX4 CLKINVX3 CLKINVX2 CLKINVX1]
set_ccopt_property use_inverters true
set_ccopt_property clock_gating_cells TLATNTSCA*

#Synthese de L'arbre
ccopt_design

#Optimisation
optDesign -postCTS

#Rapport
timeDesign -postCTS -outDir $::env(PNR_REP_DIR)/timing
timeDesign -hold -postCTS -outDir $::env(PNR_REP_DIR)/timing
