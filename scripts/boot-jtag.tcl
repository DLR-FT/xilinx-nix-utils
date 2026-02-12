proc boot_jtag { } {
    puts "Switching to bootmode JTAG ..."
    targets -set -filter {name =~ "PSU"}
    # update multiboot to ZERO
    mwr 0xffca0010 0x0
    # change boot mode to JTAG
    mwr 0xff5e0200 0x0100
    # reset
    rst -system
}

array set args [list -url "" -plat "" -force_bootmode_jtag false -bit "" -pmufw "" -fsbl "" -fsbl_target "" -tfa "" -dtb "" -dtb_addr "0x00100000" -uboot "" -target "" {*}$argv]

set url $args(-url)
set plat $args(-plat)
set force_bootmode_jtag $args(-force_bootmode_jtag)
set bit $args(-bit)
set pmufw $args(-pmufw)
set fsbl $args(-fsbl)
set fsbl_target $args(-fsbl_target)
set tfa $args(-tfa)
set dtb $args(-dtb)
set uboot $args(-uboot)
set dtb_addr $args(-dtb_addr)
set target $args(-target)

switch $plat {
    "zynq7" {
        if {$target eq ""} {
            set target "ARM Cortex-A9 MPCore #0"
        }

        set fsbl_target $target
    }
    "zynqmp" {
        if {$target eq ""} {
            set target "Cortex-A53 #0"
        }

        if {$fsbl_target eq ""} {
            set fsbl_target $target
        }
    }
    default {
        puts "Platform arg -plat not specified."
        exit 1
    }
}

puts $fsbl_target
puts $target

if {$url ne ""} {
    connect -url $url
} else {
    connect
}

after 500

switch $plat {
    "zynq7" {
        targets -set -filter {name =~ "APU"}
    }
    "zynqmp" {
        if {$force_bootmode_jtag} {
            boot_jtag
        }

        targets -set -filter {name =~ "PSU"}
    }
}

rst -system

# Download Bitstream
if {$bit ne ""} {
    puts "Downloading bitstream ..."
    fpga $bit
}

# Download & Run PMU firmware
if {$plat eq "zynqmp" && $pmufw ne ""} {
    # Select PMU
    mwr 0xffca0038 0x1FF
    targets -set -filter {name =~ "MicroBlaze PMU"}

    # Download pmufw
    puts "Downloading PMU ..."
    dow $pmufw

    puts "Running PMU ..."
    con
    after 500
}

# Select FSBL target
targets -set -filter {name =~ $fsbl_target}
rst -processor -clear-registers

# Download & Run FSBL
if {$fsbl ne ""} {
    puts "Downloading FSBL ..."
    dow $fsbl

    puts "Running FSBL ..."
    con
    after 3000
    stop
}

# Select boot target
if {$target ne $fsbl_target} {
    targets -set -filter {name =~ $target}
    rst -processor -clear-registers
}

# Download DTB
if {$dtb ne ""} {
    puts "Downloading dtb ..."
    dow -data $dtb $dtb_addr
}

# Download U-Boot
if {$uboot ne ""} {
    puts "Downloading U-Boot ..."
    dow $uboot
}

# Download TF-A
if {$plat eq "zynqmp" && $tfa ne ""} {
    puts "Downloading TF-A ..."
    dow $tfa
}

puts "Running ..."
con
