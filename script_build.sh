#!/bin/bash
user=vjspranav
OUT_PATH="out/target/product/$device_codename"
ROM_ZIP=StagOS*.zip
tg_username=@vjspranav

# Colors makes things beautiful
export TERM=xterm

    red=$(tput setaf 1)             #  red
    grn=$(tput setaf 2)             #  green
    blu=$(tput setaf 4)             #  blue
    cya=$(tput setaf 6)             #  cyan
    txtrst=$(tput sgr0)             #  Reset

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

# Build
source build/envsetup.sh
lunch ${lunch}_${device_codename}-${build_variant}

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

${make_command} -j16

if [ `ls $OUT_PATH/$ROM_ZIP 2>/dev/null | wc -l` != "0" ]; then
cp ${OUT_PATH}/${ROM_ZIP} /home/$user/downloads/jenkins/
echo https://$user.ryzenbox.me/jenkins/$(basename $(ls $OUT_PATH/$ROM_ZIP))> download_link
else
exit 1
fi
