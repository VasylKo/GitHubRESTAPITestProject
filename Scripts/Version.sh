#!/bin/sh

echo "Get version ..."

MAJOR_VERSION="${MINOR_VERSION}.${TEST_VARIABLE}"

if [ -z "${PROJECT_DIR}" ]; then
	PROJECT_DIR=`pwd`
fi

if [ -z "${PREFIX}" ]; then
	PREFIX=""
fi

SVN_DIR="${PROJECT_DIR}/.svn"
GIT_DIR="${PROJECT_DIR}/.git"

if [ -d "${GIT_DIR}" ]; then
	if [ -z "${GIT_BRANCH}" ]; then
		GIT_BRANCH=`git rev-parse --abbrev-ref HEAD`
	fi
	
	BUILD_NUMBER=`xcrun git rev-list ${GIT_BRANCH} | wc -l | tr -d ' '`
	BUILD_HASH=`xcrun git rev-parse --short --verify ${GIT_BRANCH} | tr -d ' '`
elif [ -d "${SVN_DIR}" ]; then
	BUILD_NUMBER=`xcrun svnversion -nc "${PROJECT_DIR}" | sed -e 's/^[^:]*://;s/[A-Za-z]//' | tr -d ' '`
	BUILD_HASH="${BUILD_NUMBER}"
else
    if [ -z "${BUILD_NUMBER}" ]; then
        BUILD_NUMBER="1"
    fi
    if [ -z "${BUILD_VCS_NUMBER}" ]; then
        BUILD_HASH="1"
    else
        BUILD_HASH="${BUILD_VCS_NUMBER}"
    fi
fi

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
    echo "#define ${PREFIX}MINOR_VERSION ${MAJOR_VERSION}.${BUILD_NUMBER}" >> $1
    echo "#define ${PREFIX}VERSION() @\"${MAJOR_VERSION}.${BUILD_NUMBER}\"" >> $1
    echo "Version: ${MAJOR_VERSION}.${BUILD_NUMBER}.${BUILD_HASH}"
	find "${PROJECT_DIR}" -iname "*.plist" -maxdepth 1 -exec touch {} \;	
fi