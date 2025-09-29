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
      rev = "xilinx_v2025.1";
      hash = "sha256-PK8u/9zP5mVAmq4CQDRrA0dH0F7rYwJY465+7FzSHjA=";
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
      # hash = "sha256-dJR4onMlmqNiwmiN72v6gX9muw8QYC0ig4luE6HEv9U=";
    };

    uboot-src = prev.fetchFromGitHub {
      owner = "Xilinx";
      repo = "u-boot-xlnx";
      rev = "xilinx-v2025.1";
      # hash = "sha256-qeyvbpDvgg3Uu9Rr7yQIzIMhbLxGIuSAc/T95GPMDL8=";
    };

    lopper-src = prev.fetchFromGitHub {
      owner = "devicetree-org";
      repo = "lopper";
      rev = "v0.2025.x";
      hash = "sha256-bbCHaaPDH0fM2Md0/sRuKEkLWuvL+WEEVW5deAQoxcs=";
    };
  };
}
