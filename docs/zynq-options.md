## _module\.args

Additional arguments passed to each module in addition to ones
like ` lib `, ` config `,
and ` pkgs `, ` modulesPath `\.

This option is also available to all submodules\. Submodules do not
inherit args from their parent module, nor do they provide args to
their parent module or sibling submodules\. The sole exception to
this is the argument ` name ` which is provided by
parent modules to a submodule and contains the attribute name
the submodule is bound to, or a unique generated name if it is
not bound to an attribute\.

Some arguments are already passed by default, of which the
following *cannot* be changed with this option:

 - ` lib `: The nixpkgs library\.

 - ` config `: The results of all options after merging the values from all modules together\.

 - ` options `: The options declared in all modules\.

 - ` specialArgs `: The ` specialArgs ` argument passed to ` evalModules `\.

 - All attributes of ` specialArgs `
   
   Whereas option values can generally depend on other option values
   thanks to laziness, this does not apply to ` imports `, which
   must be computed statically before anything else\.
   
   For this reason, callers of the module system can provide ` specialArgs `
   which are available during import resolution\.
   
   For NixOS, ` specialArgs ` includes
   ` modulesPath `, which allows you to import
   extra modules from the nixpkgs package tree without having to
   somehow make the module aware of the location of the
   ` nixpkgs ` or NixOS directories\.
   
   ```
   { modulesPath, ... }: {
     imports = [
       (modulesPath + "/profiles/minimal.nix")
     ];
   }
   ```

For NixOS, the default value for this option includes at least this argument:

 - ` pkgs `: The nixpkgs package set according to
   the ` nixpkgs.pkgs ` option\.



*Type:*
lazy attribute set of raw value

*Declared by:*
 - [\<nixpkgs/lib/modules\.nix>](https://github.com/NixOS/nixpkgs/blob//lib/modules.nix)



## boot-image\.enable



Whether to enable Enable Boot-Image build…



*Type:*
boolean



*Default:*
` false `



*Example:*
` true `

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/boot-image\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/boot-image.nix)



## boot-image\.package



Package containing the generated boot image\.



*Type:*
package

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/boot-image\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/boot-image.nix)



## boot-image\.bootBif



Boot BIF used to generate the boot image\.
By default it is generated from the specified partitions\.



*Type:*
string

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/boot-image\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/boot-image.nix)



## boot-image\.dualQspiMode



Specifies that the boot image targets a dual (either ‘parallel’ or ‘stacked’) QSPI flash\.



*Type:*
null or one of “parallel”, “stacked”



*Default:*
` null `

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/boot-image\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/boot-image.nix)



## boot-image\.extraArgs



Extra args for bootgen tool invocation\.



*Type:*
list of (optionally newline-terminated) single-line string



*Default:*
` [ ] `

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/boot-image\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/boot-image.nix)



## boot-image\.name



name



*Type:*
string matching the pattern \[a-zA-Z0-9_-]+



*Default:*
` "kria-k260-boot-image" `

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/boot-image\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/boot-image.nix)



## boot-image\.partitions



Defines partitions in the boot image\.
Partitions that are null are omitted\.



*Type:*
attribute set of (null or (submodule))



*Default:*
` { } `

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/boot-image\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/boot-image.nix)



## boot-image\.partitions\.\<name>\.file



The file containing the data of the partition\.



*Type:*
absolute path

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/boot-image\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/boot-image.nix)



## boot-image\.partitions\.\<name>\.options



Specifies the options of the partition\. Suc as \[bootloader, destination_cpu="a53-0", …]\.
Boolean are formatted into an empty string or a single keyword, depending on the value\.
Options that are null are omitted\.



*Type:*
null or (attribute set of (null or boolean or signed integer or (optionally newline-terminated) single-line string))



*Default:*
` { } `

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/boot-image\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/boot-image.nix)



## boot-image\.partitions\.\<name>\.order



Specifies the order of the partition in relation to other partitions in the final boot BIF\.
Lower numbers appear before higher numbers\.
The default partitions use order 100, 200, 300, etc ,to enable extra partitions to be inserted before, between and after\.



*Type:*
signed integer



*Default:*
` 1000 `

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/boot-image\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/boot-image.nix)



## boot-image\.version



version



*Type:*
null or (optionally newline-terminated) single-line string



*Default:*
` null `

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/boot-image\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/boot-image.nix)



## boot-jtag\.enable



Whether to enable Enable script for booting via JTAG…



*Type:*
boolean



*Default:*
` false `



*Example:*
` true `

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/boot-jtag\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/boot-jtag.nix)



## boot-jtag\.package



Package containing the generated JTAG boot script\.



*Type:*
package

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/boot-jtag\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/boot-jtag.nix)



## boot-jtag\.bit



Specifies the bitstream file to download\.
Can be null to skip bitstream loading\.



*Type:*
null or absolute path



*Default:*
` null `

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/boot-jtag\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/boot-jtag.nix)



## boot-jtag\.dtb



Specifies the device-tree binary to download\.
Can be null to skip device-tree download\.



*Type:*
null or absolute path



*Default:*
` null `

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/boot-jtag\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/boot-jtag.nix)



## boot-jtag\.dtbAddr



Specifies the address at which the device-tree will be loaded\.



*Type:*
null or signed integer or (optionally newline-terminated) single-line string



*Default:*
` "0x00100000" `

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/boot-jtag\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/boot-jtag.nix)



## boot-jtag\.forceBootModeJtag



Switch ZynqMP boot mode to JTAG by software before downloading firmware\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/boot-jtag\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/boot-jtag.nix)



## boot-jtag\.fsbl



Specifies the first-stage bootloader (FSBL) firmware to download and run\.
Can be null to skip FSBL download and run\.



*Type:*
null or absolute path



*Default:*
` null `

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/boot-jtag\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/boot-jtag.nix)



## boot-jtag\.name



name



*Type:*
string matching the pattern \[a-zA-Z0-9_-]+



*Default:*
` "kria-k260-boot-jtag" `

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/boot-jtag\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/boot-jtag.nix)



## boot-jtag\.pmufw



Specifies the PMU firmware to download and run (ZynqMP only)\.
Can be null to skip PMU firmware download and run\.



*Type:*
null or absolute path



*Default:*
` null `

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/boot-jtag\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/boot-jtag.nix)



## boot-jtag\.tfa



Specifies the Trusted Firmware-A to download and run (ZynqMP only)\.
Can be null to skip Trusted Firmware-A download and run\.



*Type:*
null or absolute path



*Default:*
` null `

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/boot-jtag\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/boot-jtag.nix)



## boot-jtag\.uboot



Specifies the U-Boot firmware to download and run\.
Can be null to skip U-Boot download and run\.



*Type:*
null or absolute path



*Default:*
` null `

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/boot-jtag\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/boot-jtag.nix)



## boot-jtag\.version



version



*Type:*
null or (optionally newline-terminated) single-line string



*Default:*
` null `

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/boot-jtag\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/boot-jtag.nix)



## description



Description of the firmware



*Type:*
null or string



*Default:*
` null `



## flash-qspi\.enable



Whether to enable Enable script for QSPI flashing…



*Type:*
boolean



*Default:*
` false `



*Example:*
` true `

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/flash-qspi\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/flash-qspi.nix)



## flash-qspi\.package



Package containing the QSPI flash script\.



*Type:*
package

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/flash-qspi\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/flash-qspi.nix)



## flash-qspi\.bootImages



Specifies the boot-image(s) to be flashed\.
Can be either a single image or two images for a dual flash configurations\.



*Type:*
absolute path or list of absolute path

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/flash-qspi\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/flash-qspi.nix)



## flash-qspi\.flashPart



Flash part / configuration e\.g\. mt25qu512-qspi-x4-single, … to flash\.
Use program-flash\.sh -flash_part “\*” for a list of known flash parts\.



*Type:*
(optionally newline-terminated) single-line string

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/flash-qspi\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/flash-qspi.nix)



## flash-qspi\.initFsbl



Specifies the first-stage bootloader (FSBL) used for initializing the hardware
before flashing\. In most cases this can be the same as the FSBL in the boot image itself\.
Only for Zynq7 devices which cannnot be physically switched into JTAG boot mode
a modified FSBL is necessary\.
(https://adaptivesupport\.amd\.com/s/article/70548?language=en_US)



*Type:*
absolute path

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/flash-qspi\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/flash-qspi.nix)



## flash-qspi\.name



name



*Type:*
string matching the pattern \[a-zA-Z0-9_-]+



*Default:*
` "kria-k260-flash-qspi" `

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/flash-qspi\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/flash-qspi.nix)



## flash-qspi\.offset



Offset at which the image is flashed\.



*Type:*
null or signed integer or (optionally newline-terminated) single-line string



*Default:*
` null `

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/flash-qspi\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/flash-qspi.nix)



## flash-qspi\.version



version



*Type:*
null or (optionally newline-terminated) single-line string



*Default:*
` null `

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/flash-qspi\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/flash-qspi.nix)



## fsbl\.enable



Whether to enable Enable BL2 FSBL build…



*Type:*
boolean



*Default:*
` false `



*Example:*
` true `

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/fsbl\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/fsbl.nix)



## fsbl\.package



Package containing the build FSBL firmware



*Type:*
package

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/fsbl\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/fsbl.nix)



## fsbl\.extraPatches



Specifies extra patches to apply to the source directory before the build\.



*Type:*
list of absolute path



*Default:*
` [ ] `

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/fsbl\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/fsbl.nix)



## fsbl\.name



name



*Type:*
string matching the pattern \[a-zA-Z0-9_-]+



*Default:*
` "kria-k260-fsbl" `

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/fsbl\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/fsbl.nix)



## fsbl\.procId



Specifies the Zynq processor (ps7_cortexa9_0, psu_cortexa53_0, …) for which the FSBL is build\.



*Type:*
one of “ps7_cortexa9_0”, “psu_cortexa53_0”

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/fsbl\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/fsbl.nix)



## fsbl\.src



Specifies the FSBL source repo (e\.g\. github:xilinx/embeddedsw)\.



*Type:*
absolute path



*Default:*
` <derivation embeddedsw-src-patched> `

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/fsbl\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/fsbl.nix)



## fsbl\.stdenv



Specifies the stdenv toolchain used to build the fsbl\.



*Type:*
package

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/fsbl\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/fsbl.nix)



## fsbl\.systemDeviceTree



Specifies the System-Device-Tree which is used to generate the BSP for the FSBL\.



*Type:*
absolute path

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/fsbl\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/fsbl.nix)



## fsbl\.version



version



*Type:*
null or (optionally newline-terminated) single-line string



*Default:*
` null `

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/fsbl\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/fsbl.nix)



## fwPackages



Set of all firmware packages



*Type:*
list of package



*Default:*
` [ ] `



## hwplat\.enable



Whether to enable Enable hardware platform build…



*Type:*
boolean



*Default:*
` false `



*Example:*
` true `

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/hwplat\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/hwplat.nix)



## hwplat\.package



Package containing the build Hardware-Platform and Bitstream\.



*Type:*
package

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/hwplat\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/hwplat.nix)



## hwplat\.extraPatches



Specifies extra patches to apply to the source directory before the build\.



*Type:*
list of absolute path



*Default:*
` [ ] `

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/hwplat\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/hwplat.nix)



## hwplat\.name



name



*Type:*
string matching the pattern \[a-zA-Z0-9_-]+



*Default:*
` "kria-k260-hwplat" `

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/hwplat\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/hwplat.nix)



## hwplat\.originDir



Specifies the origin directory in the source directory, that contains the source files for the exported Vivado project\.



*Type:*
null or (optionally newline-terminated) single-line string



*Default:*
` "./." `

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/hwplat\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/hwplat.nix)



## hwplat\.sourceTcl



Specifies a tcl file in the source directory that will be sourced to restore the exported Vivado project\.
Set to null to skip project restore from tcl\.



*Type:*
null or (optionally newline-terminated) single-line string



*Default:*
` "./vivado.tcl" `

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/hwplat\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/hwplat.nix)



## hwplat\.src



Specifies the source directory from which the hardware platform is build\.



*Type:*
absolute path

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/hwplat\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/hwplat.nix)



## hwplat\.version



version



*Type:*
null or (optionally newline-terminated) single-line string



*Default:*
` null `

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/hwplat\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/hwplat.nix)



## linux-dt\.enable



Whether to enable Enable Linux Device-Tree build…



*Type:*
boolean



*Default:*
` true `



*Example:*
` true `

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/linux-dt\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/linux-dt.nix)



## linux-dt\.package



Package containing the build Linux Device-Tree



*Type:*
package

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/linux-dt\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/linux-dt.nix)



## linux-dt\.extraDtsi



Specifies extra device-tree includes for the Linux DTB\.



*Type:*
list of absolute path



*Default:*
` [ ] `

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/linux-dt\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/linux-dt.nix)



## linux-dt\.extraLops



Specifies extra lops (overrides, modifications, etc) to apply,
when generating the Linux-Device-Tree from the System-Device-Tree (see github:devicetree-org/lopper)\.



*Type:*
list of (optionally newline-terminated) single-line string



*Default:*
` [ ] `

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/linux-dt\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/linux-dt.nix)



## linux-dt\.extraPatches



Specifies extra patches to apply to the source directory before the build\.



*Type:*
list of absolute path



*Default:*
` [ ] `

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/linux-dt\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/linux-dt.nix)



## linux-dt\.name



name



*Type:*
string matching the pattern \[a-zA-Z0-9_-]+



*Default:*
` "kria-k260-linux-dt" `

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/linux-dt\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/linux-dt.nix)



## linux-dt\.procId



Specifies the Zynq processor (ps7_cortexa9_0, psu_cortexa53_0, …) for which the Linux-Device-Tree is build\.



*Type:*
one of “ps7_cortexa9_0”, “ps7_cortexa9_1”, “psu_cortexa53_0”, “psu_cortexa53_1”, “psu_cortexa53_2”, “psu_cortexa53_3”



*Default:*
` "psu_cortexa53_0" `

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/linux-dt\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/linux-dt.nix)



## linux-dt\.src



Specifies the Lopper source repo (e\.g\. github:devicetree-org/lopper)\.



*Type:*
absolute path



*Default:*
` <derivation source> `

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/linux-dt\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/linux-dt.nix)



## linux-dt\.systemDeviceTree



Specifies the System-Device-Tree that is used to generate the Linux-Device-Tree\.



*Type:*
absolute path

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/linux-dt\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/linux-dt.nix)



## linux-dt\.version



version



*Type:*
null or (optionally newline-terminated) single-line string



*Default:*
` null `

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/linux-dt\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/linux-dt.nix)



## name



Name of the firmware\.



*Type:*
string matching the pattern \[a-zA-Z0-9_-]+



## optee-os\.enable



Whether to enable Enable BL32 OPTEE-OS build…



*Type:*
boolean



*Default:*
` false `



*Example:*
` true `

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/optee-os\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/optee-os.nix)



## optee-os\.package



Package containing the build OPTEE-OS firmware\.



*Type:*
package

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/optee-os\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/optee-os.nix)



## optee-os\.extraMakeFlags



Specifies extra Make flags for the build\.



*Type:*
list of (optionally newline-terminated) single-line string



*Default:*
` [ ] `

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/optee-os\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/optee-os.nix)



## optee-os\.extraPatches



Specifies extra patches to apply to the source directory before the build\.



*Type:*
list of absolute path



*Default:*
` [ ] `

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/optee-os\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/optee-os.nix)



## optee-os\.name



name



*Type:*
string matching the pattern \[a-zA-Z0-9_-]+



*Default:*
` "kria-k260-optee-os" `

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/optee-os\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/optee-os.nix)



## optee-os\.plat



Specfies OPTEE-OS build platform (zynq7k-zc702, zynqmp-zcu102, …)\.



*Type:*
(optionally newline-terminated) single-line string

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/optee-os\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/optee-os.nix)



## optee-os\.src



Specifies the OPTEE-OS source repo (e\.g\. github:xilinx/optee_os)\.



*Type:*
absolute path



*Default:*
` <derivation source> `

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/optee-os\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/optee-os.nix)



## optee-os\.stdenv



Specifies the stdenv toolchain used to build the OPTEE-OS firmware\.



*Type:*
package



*Default:*
` <derivation stdenv-linux> `

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/optee-os\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/optee-os.nix)



## optee-os\.version



version



*Type:*
null or (optionally newline-terminated) single-line string



*Default:*
` null `

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/optee-os\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/optee-os.nix)



## plat



Zynq Platform variant, either Zynq 7000 or ZynqMP Ultrascale\.



*Type:*
one of “zynq7”, “zynqmp”



## pmufw\.enable



Whether to enable Enable PMU firmware build…



*Type:*
boolean



*Default:*
` false `



*Example:*
` true `

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/pmufw\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/pmufw.nix)



## pmufw\.package



Package containing the build PMU firmware\.



*Type:*
package

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/pmufw\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/pmufw.nix)



## pmufw\.extraPatches



Specifies extra patches to apply to the source directory before the build\.



*Type:*
list of absolute path



*Default:*
` [ ] `

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/pmufw\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/pmufw.nix)



## pmufw\.name



name



*Type:*
string matching the pattern \[a-zA-Z0-9_-]+



*Default:*
` "kria-k260-pmufw" `

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/pmufw\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/pmufw.nix)



## pmufw\.procId



Specifies the Zynq processor (psu_pmu_0, …) for which the PMU firmware is build\.



*Type:*
value “psu_pmu_0” (singular enum)

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/pmufw\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/pmufw.nix)



## pmufw\.src



Specifies the PMU source repo (e\.g\. github:xilinx/embdeddedsw)\.



*Type:*
absolute path



*Default:*
` <derivation embeddedsw-src-patched> `

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/pmufw\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/pmufw.nix)



## pmufw\.stdenv



Specifies the stdenv toolchain used to build the PMU firmware\.



*Type:*
package

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/pmufw\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/pmufw.nix)



## pmufw\.systemDeviceTree



System-Device-Tree sources\.



*Type:*
absolute path

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/pmufw\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/pmufw.nix)



## pmufw\.version



version



*Type:*
null or (optionally newline-terminated) single-line string



*Default:*
` null `

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/pmufw\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/pmufw.nix)



## sdt\.enable



Whether to enable Enable System-Device-Tree build…



*Type:*
boolean



*Default:*
` false `



*Example:*
` true `

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/sdt\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/sdt.nix)



## sdt\.package



Package containing the System-Device-Tree



*Type:*
package

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/sdt\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/sdt.nix)



## sdt\.boardDts



Specifies extra, board specific device-tree include file, from the SDT repo (see github:Xilinx/system-device-tree-xlnx)\.



*Type:*
null or (optionally newline-terminated) single-line string



*Default:*
` null `

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/sdt\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/sdt.nix)



## sdt\.extraDtsi



Specifies extra, user defined device-tree include file (see github:Xilinx/system-device-tree-xlnx)\.



*Type:*
null or (optionally newline-terminated) single-line string



*Default:*
` null `

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/sdt\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/sdt.nix)



## sdt\.extraPatches



Specifies extra patches to apply to the source directory before the build\.



*Type:*
list of absolute path



*Default:*
` [ ] `

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/sdt\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/sdt.nix)



## sdt\.hwDef



Specifies the hardware definition file (\*\.xsa) from which the System-Device-Tree is generated\.



*Type:*
absolute path

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/sdt\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/sdt.nix)



## sdt\.name



name



*Type:*
string matching the pattern \[a-zA-Z0-9_-]+



*Default:*
` "kria-k260-sdt" `

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/sdt\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/sdt.nix)



## sdt\.src



Specifies the SDT source repo\. (e\.g\. github:xilinx/system-device-tree-xlnx)



*Type:*
absolute path



*Default:*
` <derivation source> `

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/sdt\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/sdt.nix)



## sdt\.version



version



*Type:*
null or (optionally newline-terminated) single-line string



*Default:*
` null `

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/sdt\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/sdt.nix)



## tfa\.enable



Whether to enable Enable BL31 Trusted Firmware-A build…



*Type:*
boolean



*Default:*
` false `



*Example:*
` true `

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/tfa\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/tfa.nix)



## tfa\.package



Package containing the build TF-A firmware\.



*Type:*
package

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/tfa\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/tfa.nix)



## tfa\.extraMakeFlags



Specifies extra Make flags for the build\.



*Type:*
list of (optionally newline-terminated) single-line string



*Default:*
` [ ] `

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/tfa\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/tfa.nix)



## tfa\.extraPatches



Specifies extra patches to apply to the source directory before the build\.



*Type:*
list of absolute path



*Default:*
` [ ] `

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/tfa\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/tfa.nix)



## tfa\.name



name



*Type:*
string matching the pattern \[a-zA-Z0-9_-]+



*Default:*
` "kria-k260-tfa" `

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/tfa\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/tfa.nix)



## tfa\.plat



Specifies the TF-A build platform (zynqmp, …)\.



*Type:*
(optionally newline-terminated) single-line string

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/tfa\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/tfa.nix)



## tfa\.src



Specified the Trusted-Firmware-A source repo (e\.g\. github:xilinx/arm-trusted-firmware)\.



*Type:*
absolute path



*Default:*
` <derivation source> `

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/tfa\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/tfa.nix)



## tfa\.stdenv



Specifies the stdenv toolchain used to build the TF-A firmware\.



*Type:*
package

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/tfa\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/tfa.nix)



## tfa\.version



version



*Type:*
null or (optionally newline-terminated) single-line string



*Default:*
` null `

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/tfa\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/tfa.nix)



## uboot\.enable



Whether to enable Enable BL33 U-Boot build…



*Type:*
boolean



*Default:*
` false `



*Example:*
` true `

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/uboot\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/uboot.nix)



## uboot\.package



Package containing the build U-Boot firmware\.



*Type:*
package

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/uboot\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/uboot.nix)



## uboot\.bl31



Specifies the BL31 binary (\*\.elf) for the U-Boot build\. Can be null to ignore BL31\.



*Type:*
null or absolute path



*Default:*
` null `

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/uboot\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/uboot.nix)



## uboot\.defconfig

Specifies the U-Boot defconfig for the build\.



*Type:*
(optionally newline-terminated) single-line string

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/uboot\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/uboot.nix)



## uboot\.deviceTree



Specifies either an U-Boot interal device-tree name or an external device-tree blob to be included in the U-Boot build\.



*Type:*
null or absolute path or (optionally newline-terminated) single-line string



*Default:*
` null `

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/uboot\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/uboot.nix)



## uboot\.extraConfigs



Specifies extra config options to append to the U-Boot defconfig\.



*Type:*
list of (optionally newline-terminated) single-line string



*Default:*
` [ ] `

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/uboot\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/uboot.nix)



## uboot\.extraMakeFlags



Specifies extra Make flags for the build\.



*Type:*
list of (optionally newline-terminated) single-line string



*Default:*
` [ ] `

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/uboot\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/uboot.nix)



## uboot\.extraPatches



Specifies extra patches to apply to the source directory before the build\.



*Type:*
list of absolute path



*Default:*
` [ ] `

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/uboot\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/uboot.nix)



## uboot\.name



name



*Type:*
string matching the pattern \[a-zA-Z0-9_-]+



*Default:*
` "kria-k260-uboot" `

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/uboot\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/uboot.nix)



## uboot\.src



Specifies the U-Boot source repo (e\.g\. github:xilinx/u-boot-xlnx)\.



*Type:*
absolute path



*Default:*
` <derivation source> `

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/uboot\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/uboot.nix)



## uboot\.stdenv



Specifies the stdenv toolchain used to build the U-Boot firmware\.



*Type:*
package

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/uboot\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/uboot.nix)



## uboot\.tee



Specifies the TEE / BL32 binary (\*\.elf) for the U-Boot build\. Can be null to ignore BL32\.



*Type:*
null or absolute path



*Default:*
` null `

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/uboot\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/uboot.nix)



## uboot\.version



version



*Type:*
null or (optionally newline-terminated) single-line string



*Default:*
` null `

*Declared by:*
 - [/nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/uboot\.nix](file:///nix/store/9r4f1rs1acv16m0cis2gqv9sq9hzi1fh-source/zynq-modules/modules/uboot.nix)


