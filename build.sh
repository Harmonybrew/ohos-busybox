#!/bin/sh
set -e

# 当前工作目录。拼接绝对路径的时候需要用到这个值。
WORKDIR=$(pwd)

# 如果存在旧的目录和文件，就清理掉
rm -rf *.tar.gz \
    ohos-sdk \
    daily_build.log \
    manifest_tag.xml \
    busybox-1.37.0.tar.bz2 \
    busybox-1.37.0 \
    busybox-1.37.0-ohos-arm64

# 准备 ohos-sdk
curl -fL -o ohos-sdk-full_6.1-Release.tar.gz https://cidownload.openharmony.cn/version/Master_Version/OpenHarmony_6.1.0.31/20260311_020435/version-Master_Version-OpenHarmony_6.1.0.31-20260311_020435-ohos-sdk-full_6.1-Release.tar.gz
tar -zxf ohos-sdk-full_6.1-Release.tar.gz
rm -rf ohos-sdk-full_6.1-Release.tar.gz ohos-sdk/windows ohos-sdk/ohos
cd ohos-sdk/linux
unzip -q native-*.zip
unzip -q toolchains-*.zip
rm -rf *.zip
cd ../..

# 准备源码
# 这个官方链接非常不稳定：https://busybox.net/downloads/busybox-1.37.0.tar.bz2
# 这里换成 Debian 仓库里面的源码链接
curl -fL -o busybox-1.37.0.tar.bz2 http://deb.debian.org/debian/pool/main/b/busybox/busybox_1.37.0.orig.tar.bz2
tar -jxf busybox-1.37.0.tar.bz2
cd busybox-1.37.0

# 打一个鸿蒙适配的小补丁
patch -p1 < ../0001-adapt-to-ohos.patch

# 生成默认配置
make defconfig

# 一些难以适配的功能直接禁用掉
sed -i 's/CONFIG_SHA1_HWACCEL=y/# CONFIG_SHA1_HWACCEL is not set/' .config
sed -i 's/CONFIG_FEATURE_UTMP=y/# CONFIG_FEATURE_UTMP is not set/' .config
sed -i 's/CONFIG_FEATURE_SU_CHECKS_SHELLS=y/# CONFIG_FEATURE_SU_CHECKS_SHELLS is not set/' .config
sed -i 's/CONFIG_HOSTID=y/# CONFIG_HOSTID is not set/' .config
sed -i 's/CONFIG_HUSH=y/# CONFIG_HUSH is not set/' .config

# 编译 busybox
LLVM_BIN=$WORKDIR/ohos-sdk/linux/native/llvm/bin
make -j$(nproc) \
    CONFIG_PREFIX=$WORKDIR/busybox-1.37.0-ohos-arm64 \
    CC=$LLVM_BIN/aarch64-unknown-linux-ohos-clang \
    LD=$LLVM_BIN/ld.lld \
    AR=$LLVM_BIN/llvm-ar \
    STRIP=$LLVM_BIN/llvm-strip \
    HOSTCC=gcc \
    HOSTLD=ld
cd ..

# 手动进行“安装”
mkdir -p busybox-1.37.0-ohos-arm64/bin
cp busybox-1.37.0/busybox busybox-1.37.0-ohos-arm64/bin/

# 进行代码签名
cd $WORKDIR/busybox-1.37.0-ohos-arm64
find . -type f \( -perm -0111 -o -name "*.so*" \) | while read FILE; do
    if file -b "$FILE" | grep -iqE "elf|sharedlib|ELF|shared object"; then
        echo "Signing binary file $FILE"
        ORIG_PERM=$(stat -c %a "$FILE")
        $WORKDIR/ohos-sdk/linux/toolchains/lib/binary-sign-tool sign -inFile "$FILE" -outFile "$FILE" -selfSign 1
        chmod "$ORIG_PERM" "$FILE"
    fi
done
cd $WORKDIR

# 履行开源义务，将 license 随制品一起发布
cp busybox-1.37.0/LICENSE busybox-1.37.0-ohos-arm64/
cp busybox-1.37.0/AUTHORS busybox-1.37.0-ohos-arm64/

# 打包最终产物
tar -zcf busybox-1.37.0-ohos-arm64.tar.gz busybox-1.37.0-ohos-arm64
