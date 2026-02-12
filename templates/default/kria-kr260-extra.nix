{
  config,
  lib,
  pkgs,
  ...
}:
{
  name = "kria-kr260-custom";

  uboot.extraConfigs = [ "CONFIG_FOO=y" ];

  # ...
}
