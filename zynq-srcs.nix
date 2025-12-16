final: prev: {
  zynq-srcs = {
    bootgen-src = prev.fetchFromGitHub {
      owner = "Xilinx";
      repo = "bootgen";
      rev = "xilinx_v2025.1";
      hash = "sha256-VMmqNaptD6pEJDVSmmOvHcEl+5WUfwZMwxDoaiDPdxg=";
    };

    embeddedsw-src = prev.fetchFromGitHub {
      owner = "Xilinx";
      repo = "embeddedsw";
      rev = "xilinx_v2025.1_update1";
      hash = "sha256-XAwhkox1PDyo/UmxP9kjgKsjuoeWgIVhg8X1qFk+Pdo=";
    };

    sdt-src = prev.fetchFromGitHub {
      owner = "Xilinx";
      repo = "system-device-tree-xlnx";
      rev = "xilinx_v2025.1";
      hash = "sha256-lVTjJtlwcOosRISMREh/Q1K3uvAJOhmjXaWlBdDPCqs=";
    };

    tfa-src = prev.fetchFromGitHub {
      owner = "Xilinx";
      repo = "arm-trusted-firmware";
      rev = "xilinx-v2025.1";
      hash = "sha256-HIqfsenTlAU+e3SmKfHZNLrPDcUZIWF222Ur0BYS7zc=";
    };

    dt-src = prev.fetchFromGitHub {
      owner = "Xilinx";
      repo = "device-tree-xlnx";
      rev = "xilinx_v2025.1";
      hash = "sha256-rj/POzuH1GX6R6K5ipnu/8Bad0Y6iYhnnW6AjkUaFpw=";
    };

    uboot-src = prev.fetchFromGitHub {
      owner = "Xilinx";
      repo = "u-boot-xlnx";
      rev = "xilinx-v2025.1";
      hash = "sha256-RTcd7MR37E4yVGWP3RMruyKBI4tz8ex7mY1f5F2xd00=";
    };

    lopper-src = prev.fetchFromGitHub {
      owner = "devicetree-org";
      repo = "lopper";
      rev = "v0.2025.x";
      hash = "sha256-bbCHaaPDH0fM2Md0/sRuKEkLWuvL+WEEVW5deAQoxcs=";
    };
  };
}
