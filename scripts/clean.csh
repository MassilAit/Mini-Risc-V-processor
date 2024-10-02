#!/usr/bin/env tcsh
#-----------------------------------------------------------------------------
# Project  ELE8304 : Circuits intégrés à très grande échelle
#-----------------------------------------------------------------------------
# File     clean.csh
# Authors  Mickael Fiorentino <mickael.fiorentino@polymtl.ca>
# Lab      GRM - Polytechnique Montréal
# Date     <2019-10-01 Tue>
#-----------------------------------------------------------------------------
# Brief    Nettoie le dossier de travail
#-----------------------------------------------------------------------------
if ( ! $?PROJECT_HOME ) then
    echo "ERREUR: Configurer l'environnement (source setup.csh) avant d'utiliser ce script"
    exit 1
endif

set nonomatch

# Simulation
rm -f  ${SIM_DIR}/transcript
rm -f  ${SIM_DIR}/modelsim.ini
rm -rf ${SIM_DIR}/{beh,syn,pnr}/work

# Implementation
rm -f  ${IMP_DIR}/*.cmd
rm -f  ${IMP_DIR}/*.log
rm -f  ${IMP_DIR}/*.cmdlog
rm -f  ${IMP_DIR}/*.rpt
rm -f  ${IMP_DIR}/.rs_*
rm -f  ${IMP_DIR}/.timing_file*
rm -f  ${IMP_DIR}/.powerAnalysis*
rm -f  ${IMP_DIR}/design.*
rm -f  ${IMP_DIR}/RCDB*
rm -f  ${PNR_DIR}/oaScan*
rm -f  ${PNR_REP_DIR}/*.old
rm -f  ${IMP_DIR}/rc_model.bin
rm -rf ${IMP_DIR}/fv
rm -rf ${IMP_DIR}/.cadence
rm -rf ${PNR_DIR}/opt
rm -rf ${PNR_DIR}/power
rm -rf ${PNR_REP_DIR}/power
