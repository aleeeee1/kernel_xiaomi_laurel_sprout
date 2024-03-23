#!/bin/bash

# Colors
green='\033[01;32m'
red='\033[01;31m'
blink_red='\033[05;31m'
cyan='\033[0;36m'
yellow='\033[0;33m'
blue='\033[0;34m'
default='\033[0m'

# Define variables
CLANG_DIR="$HOME/toolchains/neutron-clang"
KERNEL_DIR=$PWD
Anykernel_DIR=$KERNEL_DIR/AnyKernel3/
DATE=$(date +"[%d%m%Y]")
TIME=$(date +"%H.%M.%S")
KERNEL_NAME="Unity"
FINAL_ZIP="$KERNEL_NAME"-"$DATE"

BUILD_START=$(date +"%s")

# Export variables
export TARGET_KERNEL_CLANG_COMPILE=true
export PATH="$CLANG_DIR/bin:${PATH}"

export ARCH=arm64
export LLVM=1
export LLVM_IAS=1

echo -e "***********************************************"
echo  "          Compiling Unity Kernel              "
echo -e "***********************************************"

# Finally build it
mkdir -p out
make O=out vendor/laurel_sprout-perf_defconfig
make -j$(nproc --all) O=out LD=ld.lld CC=clang CROSS_COMPILE=aarch64-linux-gnu- CROSS_COMPILE_ARM32=arm-linux-gnueabi- Image.gz-dtb dtbo.img

echo -e "$yellow***********************************************"
echo  "                Zipping Kernel                     "
echo -e "***********************************************"

# Create the flashable zip
cp out/arch/arm64/boot/Image.gz-dtb $Anykernel_DIR
cp out/arch/arm64/boot/dtbo.img $Anykernel_DIR
cd $Anykernel_DIR
zip -r9 $FINAL_ZIP.zip * -x .git README.md *placeholder

echo -e "$cyan***********************************************"
echo  "                 Cleaning up                    "
echo -e "***********************************************$default"

# Cleanup again
cd ../
rm -rf $Anykernel_DIR/Image.gz-dtb
rm -rf $Anykernel_DIR/dtbo.img
# rm -rf out

# Build complete
BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))
echo -e "$green Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.$default"
