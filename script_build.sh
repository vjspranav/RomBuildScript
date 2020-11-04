#!/bin/bash

# curl https://raw.githubusercontent.com/vjspranav/RomBuildScript/ryzen5/script_build.sh>script_build.sh
# Make necessary changes before executing script

# Export some variables
user=
lunch=
device_codename=z2_plus
build_type=userdebug
tg_username=
OUT_PATH="out/target/product/$device_codename"
START=$(date +%s)

function finish {
rm -rf /tmp/manlocktest.lock;
read -r -d '' msg <<EOT
<b>Build Stopped</b>
<b>Device:-</b> ${device_codename}
<b>Started by:-</b> ${tg_username}
EOT
telegram-send --format html "$msg" --config /ryzen.conf
}

# Check is Lock File exists, if not create it and set trap on exit
if { set -C; 2>/dev/null > /tmp/manlocktest.lock; }; then
 trap finish EXIT SIGINT
else
 uname2=$(ls -l /tmp/manlocktest.lock | awk '{print $3}');
 echo "${uname2} Building… exiting"
 exit
fi

# Send message to TG
read -r -d '' msg <<EOT
<b>Build Started</b>
<b>Device:-</b> ${device_codename}
<b>Started by:-</b> ${tg_username}
EOT

telegram-send --format html "$msg" --config /ryzen.conf

# Colors makes things beautiful
export TERM=xterm

    red=$(tput setaf 1)             #  red
    grn=$(tput setaf 2)             #  green
    blu=$(tput setaf 4)             #  blue
    cya=$(tput setaf 6)             #  cyan
    txtrst=$(tput sgr0)             #  Reset

# Ccache
if [ "$use_ccache" = "yes" ];
then
echo -e ${blu}"CCACHE is enabled for this build"${txtrst}
export CCACHE_EXEC=$(which ccache)
export USE_CCACHE=1
export CCACHE_DIR=/home/$user/ccache
ccache -M 75G
fi

if [ "$use_ccache" = "clean" ];
then
export CCACHE_EXEC=$(which ccache)
export CCACHE_DIR=/home/$user/ccache
ccache -C
export USE_CCACHE=1
ccache -M 75G
wait
echo -e ${grn}"CCACHE Cleared"${txtrst};
fi

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

rm -rf ${OUT_PATH}/${ROM_ZIP} #clean rom zip in any case

# Time to build
source build/envsetup.sh
lunch "$lunch"_"$device_codename"-"$build_type"
make stag -j24

END=$(date +%s)
TIME=$(echo $((${END}-${START})) | awk '{print int($1/60)" Minutes and "int($1%60)" Seconds"}')

# Send message to TG
read -r -d '' suc <<EOT
<b>Build Finished</b>
<b>Time:-</b> ${TIME}
<b>Device:-</b> ${device_codename}
<b>Started by:-</b> ${tg_username}
EOT

telegram-send --format html "$suc" --config /ryzen.conf
