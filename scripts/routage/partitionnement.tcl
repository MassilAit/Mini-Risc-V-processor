#Floorplan

floorPlan -site CoreSite -r 0.9 0.6 1 1 1 1

#Alimentation
globalNetConnect VDD -type pgpin -pin VDD -inst * -override
globalNetConnect VSS -type pgpin -pin VSS -inst * -override
globalNetConnect VDD -type tiehi -inst * -override
globalNetConnect VSS -type tielo -inst * -override

addStripe -nets VDD -layer Metal1 -direction vertical -width 0.6 \
    -number_of_sets 1 -start_from left -start_offset -0.8

addStripe -nets VSS -layer Metal1 -direction vertical -width 0.6 \
    -number_of_sets 1 -start_from right -start_offset -0.8


sroute -nets { VDD VSS } -connect { corePin floatingStripe }
