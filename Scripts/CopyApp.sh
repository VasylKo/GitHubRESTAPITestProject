#!/bin/sh

#  CopyApp.sh
#  Closet
#
#  Created by Alexandr Goncharov on 24/04/15.
#  Copyright (c) 2015 Gwynniebee. All rights reserved.



if [ ${PLATFORM_NAME} = "iphonesimulator" ]; then

echo "Copying simulator app"
TARGET_FILE_NAME="${SRCROOT}/${PRODUCT_NAME}.simulator.app"
rm -rf $TARGET_FILE_NAME
cp -R "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app" $TARGET_FILE_NAME

echo "Zipping simulator app"
cd ${SRCROOT}
APP_ZIP_NAME="`basename ${TARGET_FILE_NAME}`.zip"
-rm "${APP_ZIP_NAME}"
zip -r "${APP_ZIP_NAME}"  "`basename ${TARGET_FILE_NAME}`"

fi