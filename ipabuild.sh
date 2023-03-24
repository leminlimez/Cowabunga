#!/bin/bash

set -e

cd "$(dirname "$0")"

WORKING_LOCATION="$(pwd)"
APPLICATION_NAME=Cowabunga

if [ ! -d "build" ]; then
    mkdir build
fi

cd build

xcodebuild -project "$WORKING_LOCATION/$APPLICATION_NAME.xcodeproj" \
    -scheme "$APPLICATION_NAME" \
    -configuration Release \
    -derivedDataPath "$WORKING_LOCATION/build/DerivedDataApp" \
    -destination 'generic/platform=iOS' \
    clean build \
    CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGN_ENTITLEMENTS="" CODE_SIGNING_ALLOWED="NO"

DD_APP_PATH="$WORKING_LOCATION/build/DerivedDataApp/Build/Products/Release-iphoneos/$APPLICATION_NAME.app"
TARGET_APP="$WORKING_LOCATION/build/$APPLICATION_NAME.app"
cp -r "$DD_APP_PATH" "$TARGET_APP"

codesign --remove "$TARGET_APP"
if [ -e "$TARGET_APP/_CodeSignature" ]; then
    rm -rf "$TARGET_APP/_CodeSignature"
fi
if [ -e "$TARGET_APP/embedded.mobileprovision" ]; then
    rm -rf "$TARGET_APP/embedded.mobileprovision"
fi

# Add entitlements
echo "Adding entitlements"
chmod a+x $WORKING_LOCATION/bin/ldid
$WORKING_LOCATION/bin/ldid -S"$WORKING_LOCATION/entitlements.plist" "$TARGET_APP/$APPLICATION_NAME"

mkdir Payload
cp -r Cowabunga.app Payload/Cowabunga.app
strip Payload/Cowabunga.app/Cowabunga
zip -vr Cowabunga.ipa Payload
rm -rf Cowabunga.app
rm -rf Payload

