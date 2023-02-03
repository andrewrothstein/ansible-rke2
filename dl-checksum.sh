#!/usr/bin/env sh
set -e
DIR=~/Downloads
MIRROR=https://github.com/rancher/rke2/releases/download

ripchecksum()
{
    local ver=$1
    local os=$2
    local arch=$3
    local dotexe=${4:-}
    local checksums="$(lchecksums $ver $arch)"
    local platform="${os}-${arch}"
    local f="rke2.${platform}${dotexe}"

    # https://github.com/rancher/rke2/releases/download/v1.23.16%2Brke2r1/rke2-windows-amd64.exe
    # https://github.com/rancher/rke2/releases/download/v1.23.16%2Brke2r1/rke2.linux-s390x

    printf "    # %s\n" $(genurl $ver $f)
    printf "    %s: sha256:%s\n" $platform $(egrep -e "${f}\$" $checksums | awk '{print $1}')
}

genurl() {
    local ver=$1
    local f=$2
    printf "${MIRROR}/%s/${f}" $(printf $ver | jq -sRr @uri)
}

checksumurl() {
    local ver=$1
    local arch=$2

    # https://github.com/rancher/rke2/releases/download/v1.23.16%2Brke2r1/sha256sum-amd64.txt
    echo $(genurl $ver sha256sum-${arch}.txt)
}

lchecksums() {
    local ver=$1
    local arch=$2

    local url="$(checksumurl $ver $arch)"
    local checksums="${DIR}/rke2-checksums-${ver}-${arch}.txt"
    if [ ! -e $checksums ]
    then
        curl -sSLf -o "$checksums" "$url"
    fi
    echo $checksums
}

dl_ver () {
    local ver=$1
    printf "  '%s':\n" $ver
    ripchecksum $ver linux amd64
    ripchecksum $ver windows amd64 .exe
    ripchecksum $ver linux s390x
}

dl_ver ${1:-v1.26.1+rke2r1}
