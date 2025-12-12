final: prev: {
  zynq-srcs = {
    bootgen-src = prev.fetchFromGitHub {
      owner = "Xilinx";
      repo = "bootgen";
      rev = "xilinx_v2025.2";
      hash = "sha256-F1daWkZwcvejmtjF5xjGvE9Y9FrYVsGNreRWVdacjIk=";
    };

    embeddedsw-src = prev.fetchFromGitHub {
      owner = "Xilinx";
      repo = "embeddedsw";
      rev = "xilinx_v2025.2";
      hash = "sha256-kYHIt+zmn+supLPZxOblVbaU969FjNPEa/qGcv5pDLY=";
    };

    sdt-src = prev.fetchFromGitHub {
      owner = "Xilinx";
      repo = "system-device-tree-xlnx";
      rev = "xilinx_v2025.2";
      hash = "sha256-BoXGTFW1MmS78xfZ0bBTG5ImjcYKhtvigaMnAZW/Wg0=";
    };

    tfa-src = prev.fetchFromGitHub {
      owner = "Xilinx";
      repo = "arm-trusted-firmware";
      rev = "xilinx-v2025.2";
      hash = "sha256-HIqfsenTlAU+e3SmKfHZNLrPDcUZIWF222Ur0BYS7zc=";
    };

    dt-src = prev.fetchFromGitHub {
      owner = "Xilinx";
      repo = "device-tree-xlnx";
      rev = "xilinx_v2025.2";
      hash = "sha256-rj/POzuH1GX6R6K5ipnu/8Bad0Y6iYhnnW6AjkUaFpw=";
    };

    uboot-src = prev.fetchFromGitHub {
      owner = "Xilinx";
      repo = "u-boot-xlnx";
      rev = "xilinx-v2025.2";
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
