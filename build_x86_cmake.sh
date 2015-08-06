#!/bin/bash
# Make sure you have NDK_ROOT defined in .bashrc or .bash_profile

#export CMAKE_BUILD_TYPE "Debug"
export CMAKE_BUILD_TYPE="Release"

#get cpu counts
case $(uname -s) in
  Darwin)
    CONFBUILD=i386-apple-darwin`uname -r`
    HOSTPLAT=darwin-x86
    CORE_COUNT=`sysctl -n hw.ncpu`
  ;;
  Linux)
    CONFBUILD=x86-unknown-linux
    HOSTPLAT=linux-`uname -m`
    CORE_COUNT=`grep processor /proc/cpuinfo | wc -l`
  ;;
CYGWIN*)
	CORE_COUNT=`grep processor /proc/cpuinfo | wc -l`
	;;
  *) echo $0: Unknown platform; exit
esac

if [ -z "${COLORSPACE_SRC}" ];then
export COLORSPACE_SRC=`pwd`
fi

while [ $# -ge 1 ]; do
	case $1 in
	-clean|-c|-C) #
		echo "\$1=-c,-C,-clean"
		clean_build=1
		shift
		;;
	-l|-L)
		echo "\$1=-l,-L"
		local_build=1
		;;
	--help|-h|-H)
		# The main case statement will give a usage message.
		echo "$0 -c|-clean -abi=[armeabi, armeabi-v7a, armv8-64,mips,mips64el, x86,x86_64]"
		exit 1
		break
		;;
	-*)
		echo "$0: unrecognized option $1" >&2
		exit 1
		;;
	*)
		break
		;;
	esac
done

if [ -z "$COLORSPACE_OUT" ]; then
	export COLORSPACE_DIR=`pwd`
	export COLORSPACE_OUT=${COLORSPACE_OUT:-$COLORSPACE_DIR/build}
fi

#check if it needs a clean build?
if [ -d "$COLORSPACE_OUT/$TARGET_ARCH" ]; then
#	if [ -n "$clean_build" ]; then
		rm -rf $COLORSPACE_OUT/$TARGET_ARCH/*
#	fi
else
	mkdir -p $COLORSPACE_OUT/$TARGET_ARCH
fi

#export COLORSPACE_LIB_NAME=ffte
#-DCOLORSPACE_LIB_NAME=${COLORSPACE_LIB_NAME}

pushd ${COLORSPACE_OUT}/$TARGET_ARCH

#-DCOLORSPACE_TRIGO_LUT=1  ==> lookup table does not make good precision
cmake -DCOLORSPACE_DIR:FILEPATH=${COLORSPACE_DIR} -DCOLORSPACE_OUT:FILEPATH=${COLORSPACE_OUT} \
	${COLORSPACE_DIR}

ret=$?
echo "ret=$ret"
if [ "$ret" != '0' ]; then
echo "$0 cmake error!!!!"
exit -1
fi

make -j${CORE_COUNT}

ret=$?
echo "ret=$ret"
if [ "$ret" != '0' ]; then
echo "$0 make error!!!!"
exit -1
fi

popd
pushd ${COLORSPACE_OUT}

mkdir -p libs/$TARGET_ARCH
rm -rf libs/$TARGET_ARCH/*

ln -s ${COLORSPACE_OUT}/$TARGET_ARCH/lib/libcolorspace.a libs/$TARGET_ARCH/

popd
exit 0
