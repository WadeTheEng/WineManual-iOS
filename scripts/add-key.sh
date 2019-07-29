#!/bin/sh
security create-keychain -p travis ios-build.keychain
security import ./scripts/certs/apple.cer -k ~/Library/Keychains/ios-build.keychain -T /usr/bin/codesign
security import ./scripts/certs/dist.cer -k ~/Library/Keychains/ios-build.keychain -T /usr/bin/codesign
security import ./scripts/certs/dist.p12 -k ~/Library/Keychains/ios-build.keychain -P $KEY_PASSWORD -T /usr/bin/codesign
mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles
cp ./scripts/profiles/$PROFILE_NAME.mobileprovision ~/Library/MobileDevice/Provisioning\ Profiles/

echo "Unlock keychain"
security unlock-keychain -p secret ios-build.keychain

echo "Increase keychain unlock timeout"
security set-keychain-settings -lut 7200 ios-build.keychain

echo "Add keychain to keychain-list"
security list-keychains -s ios-build.keychain
