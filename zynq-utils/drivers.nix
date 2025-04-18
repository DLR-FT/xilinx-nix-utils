# #!/bin/sh

# SW_DIR="./sw"
# SDT_DIR="$SW_DIR/sdt"
# OUT_DIR=$SW_DIR
# PROCESSOR="psu_cortexa53_0"
# NAME="drivers"

# BASE_DIR=$(realpath $(pwd))
# SW_DIR="$(realpath $BASE_DIR/$SW_DIR)"
# SDT_DIR="$(realpath $BASE_DIR/$SDT_DIR)"
# OUT_DIR="$(realpath $BASE_DIR/$OUT_DIR)"

# export LOPPER_DTC_FLAGS="-@";
# export ESW_REPO="$SW_DIR/embeddedsw"

# DRIVERS_BSP_DIR="$OUT_DIR/$PROCESSOR/${NAME}_bsp"
# mkdir -p $DRIVERS_BSP_DIR
# pushd $DRIVERS_BSP_DIR
# python $ESW_REPO/scripts/pyesw/create_bsp.py -t empty_application -s $SDT_DIR/system-top.dts -p $PROCESSOR
# popd







# unset LOPPER_DTC_FLAGS
# unset ESW_REPO


#!/bin/sh

# PROCESSOR="psu_cortexa53_0"
# NAME="drivers"

# SW_DIR="./sw"
# DRIVERS_BSP_DIR="$SW_DIR/$PROCESSOR/${NAME}_bsp"


# BASE_DIR=$(realpath $(pwd))

# SW_DIR="$(realpath $BASE_DIR/$SW_DIR)"
# DRIVERS_BSP_DIR="$(realpath $BASE_DIR/$DRIVERS_BSP_DIR)"


# export LOPPER_DTC_FLAGS="-@";
# export ESW_REPO="$SW_DIR/embeddedsw"

# python $ESW_REPO/scripts/pyesw/build_bsp.py -d "$DRIVERS_BSP_DIR"
