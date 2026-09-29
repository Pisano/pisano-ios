#!/bin/bash
#
# Build PisanoFeedback.xcframework from feedback-ios and stage it in pisano-ios.
# Usage: ./scripts/release.sh 1.1.0
#
# The xcframework must support iOS 12.0, which needs Xcode 16.x (newer Xcode
# versions build for iOS 15.0 and later only). Point DEVELOPER_DIR at it:
#   DEVELOPER_DIR=/path/to/Xcode_16.4.app/Contents/Developer ./scripts/release.sh 1.1.0
#
set -e

VERSION="${1:?usage: $0 <version>}"
SOURCE_REF="${SOURCE_REF:-master}"
FEEDBACK_IOS="${FEEDBACK_IOS:-$HOME/Documents/pisano-projects/feedback-ios}"
PISANO_IOS="${PISANO_IOS:-$(cd "$(dirname "$0")/.." && pwd)}"
SCHEME="Feedback"
FRAMEWORK="PisanoFeedback"

echo "=== Build $FRAMEWORK.xcframework from feedback-ios ($SOURCE_REF) ==="
xcodebuild -version
cd "$FEEDBACK_IOS"
git fetch origin
git checkout "$SOURCE_REF"
git pull --ff-only origin "$SOURCE_REF" 2>/dev/null || true

rm -rf ./build ./xcframework
mkdir -p ./xcframework

for SDK in iphonesimulator iphoneos; do
  xcodebuild archive -project Feedback.xcodeproj -scheme "$SCHEME" \
    -archivePath "./build/${FRAMEWORK}-${SDK}.xcarchive" \
    -sdk "$SDK" -configuration Release \
    SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES
done

xcodebuild -create-xcframework \
  -framework "./build/${FRAMEWORK}-iphonesimulator.xcarchive/Products/Library/Frameworks/${FRAMEWORK}.framework" \
  -framework "./build/${FRAMEWORK}-iphoneos.xcarchive/Products/Library/Frameworks/${FRAMEWORK}.framework" \
  -output "./xcframework/${FRAMEWORK}.xcframework"

/usr/libexec/PlistBuddy -c "Print :MinimumOSVersion" \
  "./xcframework/${FRAMEWORK}.xcframework/ios-arm64/${FRAMEWORK}.framework/Info.plist"

echo "=== Copy to pisano-ios ==="
cd "$PISANO_IOS"
git checkout -b "release/${VERSION}"

rm -rf "${FRAMEWORK}.xcframework"
cp -R "$FEEDBACK_IOS/xcframework/${FRAMEWORK}.xcframework" ./

# Bump podspec version
sed -i '' "s/s.version             = \".*\"/s.version             = \"${VERSION}\"/" Pisano.podspec

git add "${FRAMEWORK}.xcframework" Pisano.podspec
[ -f "RELEASE_NOTES_${VERSION}.md" ] && git add "RELEASE_NOTES_${VERSION}.md"
git status -sb

echo ""
echo "=== Next steps ==="
echo "1. Review: git diff --cached --stat (add RELEASE_NOTES_${VERSION}.md if missing)"
echo "2. Commit and open a PR release/${VERSION} → master, then merge"
echo "3. Tag the merge commit and publish: gh release create ${VERSION} --target <merge commit>"
echo "4. pod trunk push Pisano.podspec --allow-warnings (with DEVELOPER_DIR set as above)"
echo "5. feedback-ios: tag the source commit ${VERSION} and publish its release"
