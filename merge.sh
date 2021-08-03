#!/bin/bash

repo=${1:?"Repo name missing"}
tag=${2}
curDir=$( pwd )


if [ $repo = "manifest" ]; then
    cd .repo/manifests
else
    if [ $repo = "build" ]; then
        cd build/make
    else
        cd $repo
    fi
fi

git fetch https://android.googlesource.com/platform/${repo} android-11.0.0_r${tag}
if git merge FETCH_HEAD; then
    cd $curDir
else
    echo "Merge Conflict"
fi


