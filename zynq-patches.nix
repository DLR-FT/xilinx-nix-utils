final: prev: {
  zynq-srcs = prev.zynq-srcs // {
    # https://github.com/Xilinx/bootgen/pull/42
    bootgen-src = prev.applyPatches {
      name = "bootgen-src-patched";
      src = prev.zynq-srcs.bootgen-src;

      patches = [ ./patches/bootgen-pr42.patch ];
    };

    # https://github.com/Xilinx/embeddedsw/issues/373
    embeddedsw-src = prev.applyPatches {
      name = "embeddedsw-src-patched";
      src = prev.zynq-srcs.embeddedsw-src;

      postPatch = ''
        find . -type f -print0 | xargs -0 sed -i "s/cmake_minimum_required(VERSION 3\.3)/cmake_minimum_required(VERSION 3.15)/"
      '';
    };
  };
}
