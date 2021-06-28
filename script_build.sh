#!/bin/bash
user=vjspranav
OUT_PATH="out/target/product/$device_codename"

# Colors makes things beautiful
export TERM=xterm

    red=$(tput setaf 1)             #  red
    grn=$(tput setaf 2)             #  green
    blu=$(tput setaf 4)             #  blue
    cya=$(tput setaf 6)             #  cyan
    txtrst=$(tput sgr0)             #  Reset

#Start Counting build time after build started we don't want wait time included
START=$(date +%s)

# Ccache
if [ "$with_ccache" = "yes" ];
then
echo -e ${blu}"CCACHE is enabled for this build"${txtrst}
export CCACHE_EXEC=$(which ccache)
export USE_CCACHE=1
export CCACHE_DIR=/home/$user/ccache
ccache -M 75G
fi
if [ "$with_ccache" = "clean" ];
then
export CCACHE_EXEC=$(which ccache)
export CCACHE_DIR=/home/$user/ccache
ccache -C
export USE_CCACHE=1
ccache -M 75G
wait
echo -e ${grn}"CCACHE Cleared"${txtrst};
fi

#clean rom zip in any case
rm -rf ${OUT_PATH}/*.zip

# Clean build
if [ "$make_clean" = "yes" ];
then
make clean && make clobber
wait
echo -e ${cya}"OUT dir from your repo deleted"${txtrst};
fi

if [ "$make_clean" = "installclean" ];
then
make installclean
rm -rf ${OUT_PATH}/${ROM_ZIP}
wait
echo -e ${cya}"Images deleted from OUT dir"${txtrst};
fi

if [ "$make_clean" = "deviceclean" ];
then
make deviceclean
rm -rf ${OUT_PATH}/${ROM_ZIP}
wait
echo -e ${cya}"Device dir deleted from OUT dir"${txtrst};
fi

# Build
source build/envsetup.sh
lunch ${lunch}_${device_codename}-${build_variabt}
${make_command} -j16

END=$(date +%s)
TIME=$(echo $((${END}-${START})) | awk '{print int($1/60)" Minutes and "int($1%60)" Seconds"}')
