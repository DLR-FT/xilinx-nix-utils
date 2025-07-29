array set optional [list -url "localhost:3121" -target "*" -device "*" -flash_part "" -addr_range "use_file" -bin_offset '0' -erase '1' -blank_check '0' -program '1' -verify '1' -zynq_fsbl "" -file "" -sec_file "" {*}$argv]

set url $optional(-url)
set target $optional(-target)
set device $optional(-device)
set flash_part $optional(-flash_part)

set addr_range $optional(-addr_range)
set bin_offset $optional(-bin_offset)
set erase $optional(-erase)
set black_check $optional(-blank_check)
set program $optional(-program)
set verify $optional(-verify)
set zynq_fsbl $optional(-zynq_fsbl)
set file $optional(-file)
set sec_file $optional(-sec_file)

open_hw_manager

connect_hw_server -url ${url}

set hw_targets [get_hw_targets $target]
if {[llength $hw_targets] > 1} {
    puts "Multiple hw targets found:"
    puts $hw_targets
    puts "Use -target to specify one."
    disconnect_hw_server
    close_hw_manager
    exit
}

current_hw_target $hw_targets
open_hw_target

set hw_devices [get_hw_devices -filter {PROGRAM.IS_SUPPORTED} $device]
if {[llength $hw_devices] > 1} {
    puts "Multiple hw devices found:"
    puts $hw_devices
    puts "Use -device to specify one."
    close_hw_target
    disconnect_hw_server
    close_hw_manager
    exit
}

current_hw_device $hw_devices

set mem_parts [get_cfgmem_parts -of_object [current_hw_device] $flash_part]
if {[llength $mem_parts] > 1} {
    puts "Multiple mem parts found:"
    puts $mem_parts
    puts "Use -flash to specify one."
    close_hw_target
    disconnect_hw_server
    close_hw_manager
    exit
}

set cfgmem [create_hw_cfgmem -hw_device [current_hw_device] -mem_dev $mem_parts]

set_property PROGRAM.ADDRESS_RANGE $addr_range $cfgmem
set_property PROGRAM.BIN_OFFSET [format "%d" $bin_offset] $cfgmem
set_property PROGRAM.ERASE $erase $cfgmem
set_property PROGRAM.BLANK_CHECK $black_check $cfgmem
set_property PROGRAM.CFG_PROGRAM $program $cfgmem
set_property PROGRAM.VERIFY $verify $cfgmem

puts "CFGMEM_PART: [get_property CFGMEM_PART $cfgmem]"
puts "PROGRAM.ADDRESS_RANGE: [get_property PROGRAM.ADDRESS_RANGE $cfgmem]"
puts "PROGRAM.BIN_OFFSET: [get_property PROGRAM.BIN_OFFSET $cfgmem]"
puts "PROGRAM.ERASE: [get_property PROGRAM.ERASE $cfgmem]"
puts "PROGRAM.BLANK_CHECK: [get_property PROGRAM.BLANK_CHECK $cfgmem]"
puts "PROGRAM.CFG_PROGRAM: [get_property PROGRAM.CFG_PROGRAM $cfgmem]"
puts "PROGRAM.VERIFY: [get_property PROGRAM.VERIFY $cfgmem]"

if { $sec_file eq "" } {
    set_property PROGRAM.FILES $file $cfgmem
} else {
    set_property PROGRAM.FILES [list $file $sec_file] $cfgmem
}

set_property PROGRAM.ZYNQ_FSBL $zynq_fsbl $cfgmem

program_hw_cfgmem -hw_cfgmem $cfgmem

close_hw_target
disconnect_hw_server
close_hw_manager
