#Adding fillers
addFiller -cell FILL32 FILL16 FILL8 FILL4 FILL2 FILL1 -prefix FILLER

#Configuration temporelle/electrique
setNanoRouteMode -quiet -routeWithTimingDriven true
setNanoRouteMode -routeWithSIDriven true

#Routage
routeDesign -globalDetail


#Optimisation
setExtractRCMode -engine postRoute
extractRC

setAnalysisMode -analysisType onChipVariation
setAnalysisMode -cppr both

optDesign -postRoute -setup -hold -outDir $::env(PNR_DIR)/opt
