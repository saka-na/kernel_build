export TELEGRAM_TOKEN
export TELEGRAM_CHAT
sudo apt update
sudo apt install -y liblz4-dev openjdk-8-jdk android-tools-adb bc bison build-essential curl flex g++-multilib gcc-multilib gnupg gperf imagemagick lib32ncurses5-dev lib32readline-dev lib32z1-dev libesd0-dev liblz4-tool libncurses5-dev libsdl1.2-dev libssl-dev libwxgtk3.0-dev libxml2 libxml2-utils lzop pngcrush rsync schedtool squashfs-tools xsltproc yasm zip zlib1g-dev ccache

# Main Environment
# Export
export ARCH=arm
export SUBARCH=arm
export PATH=/usr/lib/ccache:$PATH
export CROSS_COMPILE
export KBUILD_BUILD_USER=wulan17
export KBUILD_BUILD_HOST=Github
branch=pie
device=cactus
kernel_repo=https://github.com/wulan17/android_kernel_xiaomi_cactus.git
tc_repo=https://github.com/wulan17/prebuilts_gcc_linux-x86_arm-linux-androideabi-4.9.git
tc_name=arm-linux-androideabi
tc_v=4.9
export zip_name="kernel-"$($device)"-"$(env TZ='Asia/Jakarta' date +%Y%m%d)""
KERNEL_DIR=$(pwd)
KERN_IMG=$KERNEL_DIR/kernel/out/arch/arm/boot/zImage-dtb
ZIP_DIR=$KERNEL_DIR/AnyKernel
CONFIG_DIR=$KERNEL_DIR/kernel/arch/arm/configs
CONFIG=$device_defconfig
CORES=$(grep -c ^processor /proc/cpuinfo)
THREAD="-j$CORES"
CROSS_COMPILE+="ccache "
CROSS_COMPILE+="$KERNEL_DIR/$tc_name-$tc_v/bin/$tc_name-"
chmod a+x $KERNEL_DIR/telegram
SYNC_START=$(date +"%s")
$KERNEL_DIR/telegram -M "Sync Started"
cd $KERNEL_DIR && git clone -b $branch $kernel_repo --depth 1 kernel
cd $KERNEL_DIR && git clone $tc_repo $tc_name-$tc_v
chmod a+x $KERNEL_DIR/$tc_name-$tc_v/bin/*
chmod a+x $KERNEL_DIR/$tc_name-$tc_v/libexec/gcc/$tc_name/*/*
chmod a+x $KERNEL_DIR/$tc_name-$tc_v/libexec/gcc/$tc_name/*/plugin/*
SYNC_END=$(date +"%s")
SYNC_DIFF=$((SYNC_END - SYNC_START))
$KERNEL_DIR/telegram -M "Sync completed successfully in $((SYNC_DIFF / 60)) minute(s) and $((SYNC_DIFF % 60)) seconds"

BUILD_START=$(date +"%s")
cd $KERNEL_DIR/kernel
$KERNEL_DIR/telegram -M "Build Start
Dev : ""$KBUILD_BUILD_USER""
Product : Kernel
Device : #""$device""
Branch : ""$branch""
Host : ""$KBUILD_BUILD_HOST""
Compiler : 
""$(gcc --version)""
Compiler : 
""$(${CROSS_COMPILE}gcc --version | head -n 1)""
Date : ""$(env TZ=Asia/Jakarta date)"""
make  O=out $CONFIG $THREAD
make -j4 O=out

cp $KERN_IMG $ZIP_DIR
cd $ZIP_DIR
mv zImage-dtb zImage
BUILD_END=$(date +"%s")
BUILD_DIFF=$((BUILD_END - BUILD_START))
zip -r $zip_name.zip ./*

curl -v -F "chat_id=$TELEGRAM_CHAT" -F document=@$ZIP_DIR/$zip_name.zip -F "parse_mode=html" -F caption="Build completed successfully in $((BUILD_DIFF / 60)) minute(s) and $((BUILD_DIFF % 60)) seconds
Dev : ""$KBUILD_BUILD_USER""
Product : Kernel
Device : #""$device""
Branch : ""$branch""
Host : ""$KBUILD_BUILD_HOST""
Compiler : ""$(gcc --version)""
Compiler : ""$(${CROSS_COMPILE}gcc --version | head -n 1)""
Date : ""$(env TZ=Asia/Jakarta date)""" https://api.telegram.org/bot$TELEGRAM_TOKEN/sendDocument