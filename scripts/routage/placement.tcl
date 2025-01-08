#Verification contraintes temporelle
timeDesign -prePlace -outDir $::env(PNR_REP_DIR)/timing

#Option de placement
setDesignMode -process 45 -flowEffort standard
setPlaceMode -timingDriven true  \
                        -place_global_cong_effort auto \
                        -place_global_reorder_scan true



#Sans balayage
setPlaceMode -place_global_reorder_scan false
deleteAllScanCells


#Lancement du placement
place_opt_design
