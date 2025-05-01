final: prev: {
  zynq-srcs = {
    embeddedsw-src = prev.fetchFromGitHub {
      owner = "Xilinx";
      repo = "embeddedsw";
      rev = "xilinx_v2024.2";
      hash = "sha256-j2wY1XQ4TFGZpDcORXDwDpXSUEnAnl8TcBeA2y9bln4=";
    };

    sdt-src = prev.fetchFromGitHub {
      owner = "Xilinx";
      repo = "system-device-tree-xlnx";
      rev = "xilinx_v2024.2";
      hash = "sha256-tc6YU+yXZ8LZ2Sizo7jzNsyGpj6eLTefYQl0AfMJ68Q=";
    };

    tfa-src = prev.fetchFromGitHub {
      owner = "Xilinx";
      repo = "arm-trusted-firmware";
      rev = "xilinx-v2024.2";
      hash = "sha256-bq9Da3Zc+soEudJxXRejehordtttXJ3vayYZb5IfJFI=";
    };

    uboot-src = prev.fetchFromGitHub {
      owner = "Xilinx";
      repo = "u-boot-xlnx";
      rev = "xilinx-v2024.2";
      hash = "sha256-qeyvbpDvgg3Uu9Rr7yQIzIMhbLxGIuSAc/T95GPMDL8=";
    };

    lopper-src = prev.fetchFromGitHub {
      owner = "devicetree-org";
      repo = "lopper";
      rev = "v0.2024.x";
      hash = "sha256-saK6Mt3sCf6xJVDnjqVrasswVocSwvfVdTMw0fx7bdA=";
    };
  };
}
