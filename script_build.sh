#!/bin/bash

# curl https://raw.githubusercontent.com/vjspranav/RomBuildScript/ryzen5/script_build.sh>script_build.sh
# Make necessary changes before executing script

# Check is Lock File exists, if not create it and set trap on exit
if { set -C; 2>/dev/null > /tmp/manlocktest.lock; }; then
 trap "rm -f /tmp/manlocktest.lock" EXIT
else
 uname2=$(ls -l /tmp/manlocktest.lock | awk '{print $3}');
 echo "${uname2} Building… exiting"
 exit
fi

# Export some variables
user=vjspranav
device_codename=z2_plus
build_type=userdebug
use_ccache=yes
make_clean=no

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
lunch "$lunch_command"_"$device_codename"-"$build_type"
make bacon -j12

