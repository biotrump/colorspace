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

if [ -z "${FFTE_SRC}" ];then
export FFTE_SRC=`pwd`
fi

if [ -z "${NDK_ROOT_FORTRAN}"  ]; then
	export NDK_ROOT=${HOME}/NDK/android-ndk-r10e
	#export NDK_ROOT=${HOME}/NDK/android-ndk-r9
else
	export NDK_ROOT=${NDK_ROOT_FORTRAN}
fi
export ANDROID_NDK=${NDK_ROOT}

while [ $# -ge 1 ]; do
	case $1 in
	-ABI|-abi)
		#echo "\$1=-abi"
		shift
		APP_ABI=$1
		shift
		;;

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
echo APP_ABI=$APP_ABI
export APP_ABI

if [[ ${NDK_ROOT} =~ .*"-r9".* ]]
then
#ANDROID_APIVER=android-8
#ANDROID_APIVER=android-9
#android 4.0.1 ICS and above
ANDROID_APIVER=android-14
#TOOL_VER="4.6"
#gfortran is in r9d V4.8.0
TOOL_VER="4.8.0"
else
#r10d : android 4.0.1 ICS and above
if [ "$APP_ABI" = "arm64-v8a" -o \
	"$APP_ABI" = "x86_64" -o \
	"$APP_ABI" = "mips64" ]; then
	ANDROID_APIVER=android-21
else
	ANDROID_APIVER=android-14
fi
TOOL_VER="4.9"
fi
#echo ANDROID_APIVER=$ANDROID_APIVER
#read
#default is arm
#export PATH="$NDK_ROOT/toolchains/${TARGPLAT}-${TOOL_VER}/prebuilt/${HOSTPLAT}/bin/:\
#$NDK_ROOT/toolchains/${TARGPLAT}-${TOOL_VER}/prebuilt/${HOSTPLAT}/${TARGPLAT}/bin/:$PATH"
case $APP_ABI in
  armeabi)
    TARGPLAT=arm-linux-androideabi
    TOOLCHAINS=arm-linux-androideabi
    ARCH=arm

	COLORSPACE_LIB_NAME=colorspace
	#enable VFP only
  ;;
  armeabi-v7a)
    TARGPLAT=arm-linux-androideabi
    TOOLCHAINS=arm-linux-androideabi
    ARCH=arm
	#enable NEON
	COLORSPACE_LIB_NAME=colorspace
  ;;
  arm64-v8a)
    TARGPLAT=aarch64-linux-android
    TOOLCHAINS=aarch64-linux-android
    ARCH=arm64

	COLORSPACE_LIB_NAME=colorspace
  ;;
  x86)#atom-32
    TARGPLAT=i686-linux-android
    TOOLCHAINS=x86
    ARCH=x86
	#specify assembler for x86 SSE3, but ffte's sse.s needs 64bit x86.
	#intel atom z2xxx and the old atoms are 32bit
	#http://forum.cvapp.org/viewtopic.php?f=13&t=423&sid=4c47343b1de899f9e1b0d157d04d0af1
	export  CCAS="${TARGPLAT}-as"
	export  CCASFLAGS="--32 -march=i686+sse3"

	echo "$APP_ABI is not supported in ffte yet!!!"
  ;;
  x86_64)
    TARGPLAT=x86_64-linux-android
    TOOLCHAINS=x86_64
    ARCH=x86_64
    #specify assembler for x86 SSE3, but ffte's sse.s needs 64bit x86.
	#atom-64 or x86-64 devices only.
	#http://forum.cvapp.org/viewtopic.php?f=13&t=423&sid=4c47343b1de899f9e1b0d157d04d0af1
	export  CCAS="${TARGPLAT}-as"
#	export  CCASFLAGS="--64 -march=i686+sse3"
	export  CCASFLAGS="--64"

  ;;
  mips)
	## probably wrong
	TARGPLAT=mipsel-linux-android
	TOOLCHAINS=mipsel-linux-android
	ARCH=mips
	echo "$APP_ABI is not supported in ffte yet!!!"
  ;;
  mips64)
	## probably wrong
	TARGPLAT=mips64el-linux-android
	TOOLCHAINS=mips64el-linux-android
	ARCH=mips64
	echo "$APP_ABI is not supported in FFTE yet!!!"
  ;;
  *) echo $0: Unknown target; exit
esac

echo "Using: $NDK_ROOT/toolchains/${TOOLCHAINS}-${TOOL_VER}/prebuilt/${HOSTPLAT}/bin"
export PATH="${NDK_ROOT}/toolchains/${TOOLCHAINS}-${TOOL_VER}/prebuilt/${HOSTPLAT}/bin/:$PATH"

export SYS_ROOT="${NDK_ROOT}/platforms/${ANDROID_APIVER}/arch-${ARCH}/"
export CC="${TARGPLAT}-gcc --sysroot=$SYS_ROOT"
export LD="${TARGPLAT}-ld"
export AR="${TARGPLAT}-ar"
export RANLIB="${TARGPLAT}-ranlib"
export STRIP="${TARGPLAT}-strip"
#export CFLAGS="-Os -fPIE"
export CFLAGS="-Os -fPIE --sysroot=$SYS_ROOT"
export CXXFLAGS="-fPIE --sysroot=$SYS_ROOT"
export FORTRAN="${TARGPLAT}-gfortran --sysroot=$SYS_ROOT"

#!!! quite importnat for cmake to define the NDK's fortran compiler.!!!
#Don't let cmake decide it.
export FC=${FORTRAN}
export AM_ANDROID_EXTRA="-llog -fPIE -pie"

if [ -z "$COLORSPACE_OUT" ]; then
	export COLORSPACE_DIR=`pwd`
	export COLORSPACE_OUT=${COLORSPACE_OUT:-$COLORSPACE_DIR/build}
	export local_build=1
fi

#check if it needs a clean build?
if [ -d "$COLORSPACE_OUT/$APP_ABI" ]; then
	if [ $clean_build == 1 ]; then
		rm -rf $COLORSPACE_OUT/$APP_ABI/*
	fi
else
	mkdir -p $COLORSPACE_OUT/$APP_ABI
fi

pushd ${COLORSPACE_OUT}/$APP_ABI

#-DFFTE_TRIGO_LUT=1 : enabling cosine, sine operation by lookup table in f90.f90
#but it does not make good precision!!!
case $APP_ABI in
	armeabi)
	cmake -DCMAKE_TOOLCHAIN_FILE=${COLORSPACE_DIR}/android.toolchain.cmake \
	-DANDROID_NATIVE_API_LEVEL=${ANDROID_APIVER} -DAPP_ABI=${APP_ABI} \
	-DANDROID_NDK=${ANDROID_NDK} -DANDROID_TOOLCHAIN_NAME=${TOOLCHAINS}-${TOOL_VER} \
	-DCMAKE_BUILD_TYPE=Release -DANDROID_ABI=$APP_ABI \
	-DCOLORSPACE_DIR:FILEPATH=${COLORSPACE_DIR} -DCOLORSPACE_LIB_NAME=${COLORSPACE_LIB_NAME} \
	-DCOLORSPACE_OUT:FILEPATH=${COLORSPACE_OUT} \
	-DBUILD_GENERIC:BOOL=${BUILD_GENERIC} -DBUILD_VEC:BOOL=${BUILD_VEC} \
	-DBUILD_NEON:BOOL=${BUILD_NEON} -DBUILD_CUDA:BOOL=${BUILD_CUDA} \
	${COLORSPACE_DIR}
	;;
	armeabi-v7a)
	cmake -DCMAKE_TOOLCHAIN_FILE=${COLORSPACE_DIR}/android.toolchain.cmake \
	-DANDROID_NATIVE_API_LEVEL=${ANDROID_APIVER} -DAPP_ABI=${APP_ABI} \
	-DANDROID_NDK=${ANDROID_NDK} -DANDROID_TOOLCHAIN_NAME=${TOOLCHAINS}-${TOOL_VER} \
	-DCMAKE_BUILD_TYPE=Release -DANDROID_ABI="armeabi-v7a with NEON" \
	-DCOLORSPACE_DIR:FILEPATH=${COLORSPACE_DIR} -DCOLORSPACE_LIB_NAME=${COLORSPACE_LIB_NAME} \
	-DCOLORSPACE_OUT:FILEPATH=${COLORSPACE_OUT} \
	${COLORSPACE_DIR}
	;;
	arm64-v8a)
	cmake -DCMAKE_TOOLCHAIN_FILE=${COLORSPACE_DIR}/android.toolchain.cmake \
	-DANDROID_NATIVE_API_LEVEL=${ANDROID_APIVER} \
	-DANDROID_NDK=${ANDROID_NDK} -DANDROID_TOOLCHAIN_NAME=${TOOLCHAINS}-${TOOL_VER} \
	-DCMAKE_BUILD_TYPE=Release -DANDROID_ABI=$APP_ABI \
	-DCOLORSPACE_DIR:FILEPATH=${COLORSPACE_DIR} -DCOLORSPACE_LIB_NAME=${COLORSPACE_LIB_NAME} \
	-DCOLORSPACE_OUT:FILEPATH=${COLORSPACE_OUT} \
	${COLORSPACE_DIR}
	;;
  x86)
	cmake -DCMAKE_TOOLCHAIN_FILE=${COLORSPACE_DIR}/android.toolchain.cmake \
	-DANDROID_NATIVE_API_LEVEL=${ANDROID_APIVER} \
	-DANDROID_NDK=${NDK_ROOT} -DANDROID_TOOLCHAIN_NAME=${TOOLCHAINS}-${TOOL_VER} \
	-DCMAKE_BUILD_TYPE=Release -DANDROID_ABI=$APP_ABI \
	-DCOLORSPACE_DIR:FILEPATH=${COLORSPACE_DIR} -DCOLORSPACE_LIB_NAME=${COLORSPACE_LIB_NAME} \
	-DCOLORSPACE_OUT:FILEPATH=${COLORSPACE_OUT} \
	${COLORSPACE_DIR}
  ;;
  x86_64)
	cmake -DCMAKE_TOOLCHAIN_FILE=${COLORSPACE_DIR}/android.toolchain.cmake \
	-DANDROID_NATIVE_API_LEVEL=${ANDROID_APIVER} \
	-DANDROID_NDK=${NDK_ROOT} -DANDROID_TOOLCHAIN_NAME=${TOOLCHAINS}-${TOOL_VER} \
	-DCMAKE_BUILD_TYPE=Release -DANDROID_ABI=$APP_ABI \
	-DCOLORSPACE_DIR:FILEPATH=${COLORSPACE_DIR} -DCOLORSPACE_LIB_NAME=${COLORSPACE_LIB_NAME} \
	-DCOLORSPACE_OUT:FILEPATH=${COLORSPACE_OUT} \
	${COLORSPACE_DIR}
  ;;
  mips)
	cmake -DCMAKE_TOOLCHAIN_FILE=${COLORSPACE_DIR}/android.toolchain.cmake \
	-DANDROID_NATIVE_API_LEVEL=${ANDROID_APIVER} \
	-DANDROID_NDK=${NDK_ROOT} -DANDROID_TOOLCHAIN_NAME=${TOOLCHAINS}-${TOOL_VER} \
	-DCMAKE_BUILD_TYPE=Release -DANDROID_ABI=$APP_ABI \
	-DCOLORSPACE_DIR:FILEPATH=${COLORSPACE_DIR} -DCOLORSPACE_LIB_NAME=${COLORSPACE_LIB_NAME} \
	-DCOLORSPACE_OUT:FILEPATH=${COLORSPACE_OUT} \
	${COLORSPACE_DIR}
  ;;
  mips64)
	cmake -DCMAKE_TOOLCHAIN_FILE=${COLORSPACE_DIR}/android.toolchain.cmake \
	-DANDROID_NATIVE_API_LEVEL=${ANDROID_APIVER} \
	-DANDROID_NDK=${NDK_ROOT} -DANDROID_TOOLCHAIN_NAME=${TOOLCHAINS}-${TOOL_VER} \
	-DCMAKE_BUILD_TYPE=Release -DANDROID_ABI=$APP_ABI \
	-DCOLORSPACE_DIR:FILEPATH=${COLORSPACE_DIR} -DCOLORSPACE_LIB_NAME=${COLORSPACE_LIB_NAME} \
	-DCOLORSPACE_OUT:FILEPATH=${COLORSPACE_OUT} \
	${COLORSPACE_DIR}
  ;;
  *) echo $0: Unknown target; exit
esac

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

mkdir -p libs/$APP_ABI
rm -rf libs/$APP_ABI/*

ln -s ${COLORSPACE_OUT}/$APP_ABI/lib/libcolorspace.a libs/$APP_ABI/

popd
exit 0
