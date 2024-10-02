#!/usr/bin/tclsh
#-----------------------------------------------------------------------------
# Project  ELE8304 : Circuits intégrés à très grande échelle
#-----------------------------------------------------------------------------
# File     hex.tcl
# Author   Mickael Fiorentino  <mickael.fiorentino@polymtl.ca>
# Lab      GRM - Polytechnique Montreal
# Date     <2019-08-15 Thu>
#-----------------------------------------------------------------------------
# Brief    Conversion d'un fichier .hex au format verilog vers un format
#          compatible vhdl
#-----------------------------------------------------------------------------
package require Tcl 8.5

# Get arguments
if { $argc != 2 } {
    error "Wrong number of arguments ($argc) - should be: hex.tcl verilog_hex_file vhdl_hex_file"
}
set ver_hex_file [lindex $argv 0]
set vhd_hex_file [lindex $argv 1]

# Open destination hex file
set vhd_chan [open ${vhd_hex_file} w]

# Read input hex data
if { ![file exist ${ver_hex_file}] } {
    error "file ${ver_hex_file} does not exists"
}
set ver_chan [open ${ver_hex_file} r]
set ver_data [read ${ver_chan}]
close ${ver_chan}

# Parse hex
foreach line [split $ver_data \n] {

    # Address
    if { [string range $line 0 0] == "@" } {
        set addr "0x[string range $line 1 end]"
        set effaddr [format %08X [expr $addr >> 2]]
        puts ${vhd_chan} "@$effaddr"

    # Data
    } else {
        set data  [split [string trim $line] " "]
        for { set i 1 } { $i <= [expr [llength $data] / 4] } { incr i } {
            set w [lrange $data [expr 4*($i-1)] [expr 4*$i-1]]
            set word [format "%s%s%s%s" [lindex $w 3] [lindex $w 2] [lindex $w 1] [lindex $w 0]]
            puts ${vhd_chan} $word
        }
    }
}
close ${vhd_chan}
