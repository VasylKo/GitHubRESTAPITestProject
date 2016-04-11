#!/bin/sh

echo "Get version ..."

MAJOR_VERSION="${MAJOR_VERSION}.${MINOR_VERSION}.${FIX_VERSION}"

if [ -z "${MAJOR_VERSION}" ]; then
MAJOR_VERSION="1.1.1"
fi

if [ -z "${PROJECT_DIR}" ]; then
	PROJECT_DIR=`pwd`
fi

if [ -z "${PREFIX}" ]; then
	PREFIX=""
fi

BUILD_HASH=$BUILD_NUMBER

if [ -z "$1" ]; then
	if [ "${BUILD_NUMBER}" == "${BUILD_HASH}" ]; then
		echo "${MAJOR_VERSION}.${BUILD_NUMBER}"
	else
		echo "${MAJOR_VERSION}.${BUILD_NUMBER}.${BUILD_HASH}"
	fi
else
	echo "#define ${PREFIX}BUILD_NUMBER ${BUILD_NUMBER}" > $1
	echo "#define ${PREFIX}BUILD_HASH ${BUILD_HASH}" >> $1
    echo "#define ${PREFIX}MAJOR_VERSION ${MAJOR_VERSION}" >> $1
    echo "#define ${PREFIX}MINOR_VERSION ${MAJOR_VERSION}-${BUILD_NUMBER}" >> $1
    echo "#define ${PREFIX}VERSION() @\"${MAJOR_VERSION}-${BUILD_NUMBER}\"" >> $1
    echo "Version: ${MAJOR_VERSION}-${BUILD_NUMBER}.${BUILD_HASH}"
	find "${PROJECT_DIR}" -iname "*.plist" -maxdepth 1 -exec touch {} \;	
fi