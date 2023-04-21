#!/usr/bin/env xsct

if { $argc != 7 } {
	set prog_name [file tail $argv0]
    puts "usage: $prog_name bit_file pmufw_file psu_file fsbl_file sys_dtb_file elf_file atf_file"
	exit 0
}

set bit_file [lindex $argv 0]
#set xsa_file [lindex $argv 1]
set pmufw_file [lindex $argv 1]
set psu_file [lindex $argv 2]
set fsbl_file [lindex $argv 3]
set sys_dtb_file [lindex $argv 4]
set elf_file [lindex $argv 5]
set atf_file [lindex $argv 6]

#set zynqmp_utils [lindex $argv 4]





#source $zynqmp_utils

connect -url tcp:127.0.0.1:3121

#set jtag_id [dict get [lindex [ jtag targets -filter {level == 0} -target-properties] 0] name]

#if { ($jtag_id == "JTAG-ONB4 2516330067ABA") || ($jtag_id == "JTAG-ONB4 2516330067ACA") } {
#	puts "Set bootmode to JTAG"
#	targets -set -nocase -filter {name =~ "*PSU*"}
#	stop
#	mwr 0xff5e0200 0x0100
#	rst -system
#}

# reset processor
targets -set -nocase -filter {name =~ "*PSU*"}
rst

# set bootmode to 'JTAG'
#puts "Set bootmode to JTAG"
#mwr 0xff5e0200 0x0100
#rst -system

# configure FPGA
targets -set -nocase -filter {name =~ "*PS TAP*"}
fpga $bit_file

# load PMU firmware
targets -set -nocase -filter {name =~ "*PSU*"}
mask_write 0xFFCA0038 0x1C0 0x1C0
targets -set -nocase -filter {name =~ "*MicroBlaze PMU*"}
dow $pmufw_file
con
after 500
targets -set -nocase -filter {name =~ "*PSU*"}
mask_write 0xFFCA0038 0x1C0 0x0

# initialize APU and PSU
targets -set -nocase -filter {name =~ "*APU*"}
mwr 0xffff0000 0x14000000
mask_write 0xFD1A0104 0x501 0x0
source $psu_file
psu_init

# load FSBL
targets -set -nocase -filter {name =~ "*A53 #0*"}
dow $fsbl_file
con
after 4000; stop

# load U-Boot
targets -set -nocase -filter {name =~ "*A53 #0*"}
dow -data $sys_dtb_file 0x100000
targets -set -nocase -filter {name =~ "*A53 #0*"}
dow $elf_file

# load ARM Trusted Firmware (ATF)
targets -set -nocase -filter {name =~ "*A53 #0*"}
dow $atf_file

con
