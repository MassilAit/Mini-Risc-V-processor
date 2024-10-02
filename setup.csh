#!/usr/bin/env tcsh
#-----------------------------------------------------------------------------
# Project  Tutoriels - Conception de circuits intégrés numériques
#-----------------------------------------------------------------------------
# File     setup.csh
# Authors  Mickael Fiorentino <mickael.fiorentino@polymtl.ca>
# Lab      GRM - Polytechnique Montréal
# Date     <2020-07-23>
# Date     <2024-04-03> modification par Rejean Lepage (tuto numerique)
#-----------------------------------------------------------------------------
# Brief    Script de configuration de l'environnement
#          - Environnement CMC
#          - Hiérarchie du projet
#          - kit GPDK45
#          - Outils Cadence & Mentor
#-----------------------------------------------------------------------------

#-----------------------------------------------------------------------------
# CONFIGURATION
#-----------------------------------------------------------------------------
# setenv CMC_CONFIG   "/CMC/scripts/cmc.2017.12.csh"
setenv CMC_CONFIG   "/CMC/scripts/cmc.2023.1.csh"

setenv PROJECT_HOME `pwd`

# setup.csh doit être lancé depuis la racine du projet
if ( ! -f ${PROJECT_HOME}/setup.csh ) then
    echo "ERROR: setup.csh doit être lancé depuis la racine du projet"
    exit 1
endif

# Vérification de l'environnment CMC
if ( ! -f ${CMC_CONFIG} ) then
    echo "ERROR: L'environnement n'est pas configuré pour les outils de CMC"
    exit 1
endif

source ${CMC_CONFIG}

#-----------------------------------------------------------------------------
# HIERARCHIE DU PROJET
#-----------------------------------------------------------------------------
setenv SRC_DIR          ${PROJECT_HOME}/sources
setenv CONST_DIR        ${PROJECT_HOME}/constraints
setenv SCRIPTS_DIR      ${PROJECT_HOME}/scripts
setenv SIM_DIR          ${PROJECT_HOME}/simulation
setenv IMP_DIR          ${PROJECT_HOME}/implementation
setenv SYN_DIR          ${IMP_DIR}/syn
setenv SYN_NET_DIR      ${SYN_DIR}/base_netlist
setenv SYN_REP_DIR      ${SYN_DIR}/base_reports
setenv SYN_LOG_DIR      ${SYN_DIR}/base_logs
setenv SYN_CG_NET_DIR   ${SYN_DIR}/cg_netlist
setenv SYN_CG_REP_DIR   ${SYN_DIR}/cg_reports
setenv SYN_CG_LOG_DIR   ${SYN_DIR}/cg_logs
setenv SYN_DFT_NET_DIR  ${SYN_DIR}/dft_netlist
setenv SYN_DFT_REP_DIR  ${SYN_DIR}/dft_reports
setenv SYN_DFT_LOG_DIR  ${SYN_DIR}/dft_logs
setenv ATPG_DIR         ${IMP_DIR}/atpg
setenv PNR_DIR          ${IMP_DIR}/pnr
setenv PNR_NET_DIR      ${PNR_DIR}/base_netlist
setenv PNR_REP_DIR      ${PNR_DIR}/base_reports
setenv PNR_LOG_DIR      ${PNR_DIR}/base_logs
setenv PNR_CG_NET_DIR   ${PNR_DIR}/cg_netlist
setenv PNR_CG_REP_DIR   ${PNR_DIR}/cg_reports
setenv PNR_CG_LOG_DIR   ${PNR_DIR}/cg_logs
setenv PNR_DFT_NET_DIR  ${PNR_DIR}/dft_netlist
setenv PNR_DFT_REP_DIR  ${PNR_DIR}/dft_reports
setenv PNR_DFT_LOG_DIR  ${PNR_DIR}/dft_logs

#-----------------------------------------------------------------------------
# CONFIGURATION DU KIT GPDK045
#-----------------------------------------------------------------------------
setenv KIT_HOME   ${CMC_HOME}/kits/GPDK45
setenv KIT_SCLIB  ${KIT_HOME}/gsclib045
setenv KIT_IOLIB  ${KIT_HOME}/giolib045
setenv KIT_GPDK   ${KIT_HOME}/gpdk045
setenv KIT_SIMLIB ${KIT_HOME}/simlib

# Front-End
setenv FE_DIR      ${KIT_SCLIB}/gsclib045
setenv FE_VER_LIB  ${FE_DIR}/verilog
setenv FE_VHD_LIB  ${FE_DIR}/vhdl
setenv FE_TIM_LIB  ${FE_DIR}/timing

# Back-End
setenv BE_DIR       ${KIT_SCLIB}/gsclib045
setenv BE_LEF_LIB   ${BE_DIR}/lef
setenv BE_CDB_LIB   ${BE_DIR}/celtic
setenv BE_OA_LIB    ${BE_DIR}/oa22/gsclib045
setenv BE_QRC_LIB   ${BE_DIR}/qrc/qx
setenv BE_GDS_LIB   ${BE_DIR}/gds
setenv BE_SPICE_LIB ${BE_DIR}/spectre/gsclib045

# I/O
setenv IO_DIR      ${KIT_IOLIB}/giolib045
setenv IO_VHDL_LIB ${IO_DIR}/vhdl
setenv IO_VER_LIB  ${IO_DIR}/vlog
setenv IO_LEF_LIB  ${IO_DIR}/lef
setenv IO_OA_LIB   ${IO_DIR}/oa22/giolib045

#-----------------------------------------------------------------------------
# CONFIGURATION DES OUTILS
#-----------------------------------------------------------------------------

# MODELSIM
# source ${CMC_HOME}/scripts/mentor.modelsim.10.7c.csh
source ${CMC_HOME}/scripts/siemens.questasim.2022.1_2.csh

alias vsim "vsim -64"
#alias vsim_help "${MGC_HTML_BROWSER} ${CMC_MNT_MSIM_HOME}/docs/index.html"

# CADENCE
source ${CMC_HOME}/scripts/cadence.2014.12.csh
if ( ! -e /export/tmp/$user ) then
     mkdir -p /export/tmp/$user
endif
setenv DRCTEMPDIR /export/tmp/$user

# GENUS
# source ${CMC_HOME}/scripts/cadence.genus18.10.000.csh
source ${CMC_HOME}/scripts/cadence.genus21.10.000.csh
alias genus "genus -overwrite"
alias genus_help "${CMC_CDS_GENUS_HOME}/bin/cdnshelp"

# MODUS
source ${CMC_HOME}/scripts/cadence.modus19.12.000.csh
alias modus "modus -overwrite"
alias modus_help "${CMC_CDS_MODUS_HOME}/bin/cdnshelp"

# XCELIUM
# source ${CMC_HOME}/scripts/cadence.xceliummain19.03.011.csh
source ${CMC_HOME}/scripts/cadence.xceliummain21.09.003.csh
alias xcelium_help "${CMC_CDS_XCELIUM_HOME}/bin/cdnshelp"

# INNOVUS
source ${CMC_HOME}/scripts/cadence.innovus21.17.000.csh

alias innovus "innovus -overwrite -no_logv"
alias innovus_help "${CMC_CDS_INNOVUS_HOME}/bin/cdnshelp"

# VOLTUS & TEMPUS
# source ${CMC_HOME}/scripts/cadence.ssv16.16.000.csh
source ${CMC_HOME}/scripts/cadence.ssv22.12.000.csh

alias voltus "voltus -overwrite -no_logv"
alias tempus "tempus -overwrite -no_logv"
alias voltus_help "${CMC_CDS_SSV_HOME}/bin/cdnshelp"
alias tempus_help "${CMC_CDS_SSV_HOME}/bin/cdnshelp"

# QUANTUS QRC
source ${CMC_HOME}/scripts/cadence.ext19.13.000.csh

# CONFORMAL
# source ${CMC_HOME}/scripts/cadence.conformal18.10.100.csh
source ${CMC_HOME}/scripts/cadence.confrml23.10.200.csh

# PVS
# source ${CMC_HOME}/scripts/cadence.pvs16.15.000.csh
source ${CMC_HOME}/scripts/cadence.pvs21.12.000.csh
