{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.boot-image = {
    name = lib.mkOption {
      type = with lib.types; singleLineStr;
      description = "name";
      default = config.name + "-boot-image";
    };

    version = lib.mkOption {
      type = with lib.types; nullOr singleLineStr;
      description = "version";
      default = null;
    };

    bootBif = lib.mkOption {
      type = with lib.types; str;
      description = "Zynq Boot-Image.";
      default =
        let
          toSnake = lib.strings.stringAsChars (ch: if ch == "-" then "_" else ch);
        in
        {
          zynq7 = ''
            ${toSnake config.name}:
            {
              [bootloader] ${config.fsbl.package.elf}
              ${config.hwplat.package.bit}
              ${config.uboot.package.elf}
              [load = 0x00100000] ${config.linux-dt.package.dtb}
            }
          '';

          zynqmp = ''
            ${toSnake config.name}:
            {
              [bootloader, destination_cpu = a53-0] ${config.fsbl.package.elf}
              [pmufw_image] ${config.pmufw.package.elf}
              [destination_device = pl] ${config.hwplat.package.bit}
              [destination_cpu = a53-0, exception_level = el-3, trustzone] ${config.tfa.package.elf}
              [destination_cpu = a53-0, exception_level = el-2] ${config.uboot.package.elf}
              [destination_cpu = a53-0, load = 0x00100000] ${config.linux-dt.package.dtb}
            }
          '';
        }
        .${config.plat};
    };

    dualQspiMode = lib.mkOption {
      type = with lib.types; nullOr singleLineStr;
      description = "Generate boot-image for dual-qspi flash. Either \"parallel\" or \"stacked <size>\". See Xilinx bootgen.";
      default = null;
    };

    extraArgs = lib.mkOption {
      type = with lib.types; nullOr (listOf singleLineStr);
      description = "Extra args for bootgen.";
      default = [ ];
    };

    package = lib.mkOption {
      type = with lib.types; package;
      description = "Package containing the Hardware-Platform and Bitstream.";
    };
  };

  config = {
    fwPackages = [ config.boot-image.package ];

    boot-image = {
      package = lib.mkDefault (
        pkgs.zynq-pkgs.boot-image {
          name = config.boot-image.name;
          version = config.boot-image.version;

          arch =
            {
              zynq7 = "zynq";
              zynqmp = "zynqmp";
            }
            .${config.plat};

          bootBif = config.boot-image.bootBif;
          dualQspiMode = config.boot-image.dualQspiMode;
          extraArgs = config.boot-image.extraArgs;
        }
      );
    };
  };
}
