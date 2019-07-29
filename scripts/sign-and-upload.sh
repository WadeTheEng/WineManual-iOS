#!/bin/sh
if ![[ "$TRAVIS_BRANCH" == "staging" ] || [ "$TRAVIS_BRANCH" == "release" ]]; then
  echo "Testing on a branch other than staging. No deployment will be done."
  exit 0
fi

PROVISIONING_PROFILE="$HOME/Library/MobileDevice/Provisioning Profiles/$PROFILE_NAME.mobileprovision"
OUTPUTDIR="$PWD/build/AdHoc-iphoneos"

echo "********************"
echo "*     Signing      *"
echo "********************"
xcrun -log -sdk iphoneos PackageApplication "$OUTPUTDIR/$APP_NAME.app" -o "$OUTPUTDIR/$APP_NAME.ipa" -sign "$DEVELOPER_NAME" -embed "$PROVISIONING_PROFILE"

echo "Uploading to TestFlight"
RELEASE_NOTES="Build: $TRAVIS_BUILD_NUMBER\nUploaded: $RELEASE_DATE"
zip -r -9 "$OUTPUTDIR/$APP_NAME.app.dSYM.zip" "$OUTPUTDIR/$APP_NAME.app.dSYM"
curl http://testflightapp.com/api/builds.json \
  -F file="@$OUTPUTDIR/$APP_NAME.ipa" \
  -F dsym="@$OUTPUTDIR/$APP_NAME.app.dSYM.zip" \
  -F api_token="$TESTFLIGHT_API_TOKEN" \
  -F team_token="$TESTFLIGHT_TEAM_TOKEN" \
  -F notes="$RELEASE_NOTES" \
  -F notify=False -v

# Zip dSYM
zip -r -9 "$OUTPUTDIR/$APP_NAME.app.dSYM.zip" "$OUTPUTDIR/$APP_NAME.app.dSYM"

# Upload dSYM to BugSense
curl --form "file=@$OUTPUTDIR/$APP_NAME.app.dSYM.zip" --header "X-BugSense-Auth-Token: $BUGSENSE_ACCOUNT_API_KEY"  https://www.bugsense.com/api/v1/project/$BUGSENSE_PROJECT_API_KEY/dsym.json