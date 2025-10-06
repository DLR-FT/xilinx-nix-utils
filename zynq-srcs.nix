final: prev: {
  zynq-srcs = final.zynq-srcs-versions.default;

  zynq-srcs-versions = {
    default = final.zynq-srcs-versions."2025.1";

    "2025.1" = {
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

    "2024.2" = {
      bootgen-src = prev.fetchFromGitHub {
        owner = "Xilinx";
        repo = "bootgen";
        rev = "xilinx_v2024.2";
        hash = "sha256-t165nTG4IkI3WrcS3ZryINmAOVzfctxg5zY3oqmNtLw=";
      };

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

      dt-src = prev.fetchFromGitHub {
        owner = "Xilinx";
        repo = "device-tree-xlnx";
        rev = "xilinx_v2024.2";
        hash = "sha256-dJR4onMlmqNiwmiN72v6gX9muw8QYC0ig4luE6HEv9U=";
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
  };
}
