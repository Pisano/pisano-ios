#!/bin/bash
#
# MT-38 release: build xcframework from feedback-ios and stage pisano-ios
# Usage: ./scripts/release-mt38.sh 1.0.21
#
set -e

VERSION="${1:-1.0.21}"
FEEDBACK_IOS="${FEEDBACK_IOS:-$HOME/Documents/pisano-projects/feedback-ios}"
PISANO_IOS="${PISANO_IOS:-$HOME/Documents/pisano-projects/pisano-ios}"
SCHEME="Feedback"
FRAMEWORK="PisanoFeedback"

echo "=== Build $FRAMEWORK.xcframework from feedback-ios (MT-38) ==="
cd "$FEEDBACK_IOS"
git checkout MT-38
git pull origin MT-38 2>/dev/null || true

rm -rf ./build ./xcframework
mkdir -p ./xcframework

xcodebuild archive -project Feedback.xcodeproj -scheme "$SCHEME" \
  -archivePath "./build/${FRAMEWORK}-iphonesimulator.xcarchive" \
  -sdk iphonesimulator -configuration Release SKIP_INSTALL=NO

xcodebuild archive -project Feedback.xcodeproj -scheme "$SCHEME" \
  -archivePath "./build/${FRAMEWORK}-iphoneos.xcarchive" \
  -sdk iphoneos -configuration Release SKIP_INSTALL=NO

xcodebuild -create-xcframework \
  -framework "./build/${FRAMEWORK}-iphonesimulator.xcarchive/Products/Library/Frameworks/${FRAMEWORK}.framework" \
  -framework "./build/${FRAMEWORK}-iphoneos.xcarchive/Products/Library/Frameworks/${FRAMEWORK}.framework" \
  -output "./xcframework/${FRAMEWORK}.xcframework"

echo "=== Copy to pisano-ios (MT-38 branch) ==="
cd "$PISANO_IOS"
git checkout MT-38

rm -rf "${FRAMEWORK}.xcframework"
cp -r "$FEEDBACK_IOS/xcframework/${FRAMEWORK}.xcframework" ./

# Bump podspec version
sed -i '' "s/s.version             = \".*\"/s.version             = \"${VERSION}\"/" Pisano.podspec

git add "${FRAMEWORK}.xcframework" Pisano.podspec "RELEASE_NOTES_${VERSION}.md"
git status -sb

echo ""
echo "=== Next steps ==="
echo "1. Review diff: git diff --cached --stat"
echo "2. Commit: git commit -m \"Release ${VERSION} — MT-38 disable_zoom + MT-41\""
echo "3. Tag: git tag ${VERSION}"
echo "4. Push: git push origin MT-38 --tags"
echo "5. PR MT-38 → master, merge, then: pod trunk push Pisano.podspec"
echo "6. feedback-ios: ./scripts/tag-source-release.sh ${VERSION}"
