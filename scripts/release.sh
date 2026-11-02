#!/bin/bash
#
# Build PisanoFeedback.xcframework from feedback-ios and stage it in pisano-ios.
# Usage: ./scripts/release.sh 1.1.0
#
# From 2.0.0 the xcframework supports iOS 15.0 and later (the podspec's
# s.platform and Package.swift's platforms say the same), which Xcode 16 and
# later build. To use a specific Xcode, point DEVELOPER_DIR at it:
#   DEVELOPER_DIR=/path/to/Xcode.app/Contents/Developer ./scripts/release.sh 2.0.0
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

# Names apps depend on: `import PisanoFeedback`, `pod 'Pisano'`, SPM product
# PisanoFeedback. The Xcode target is still called "Feedback", so stop here if
# the build no longer produces exactly these names.
fail() { echo "error: $*" >&2; exit 1; }
for SLICE in ios-arm64 ios-arm64_x86_64-simulator; do
  FW="./xcframework/${FRAMEWORK}.xcframework/${SLICE}/${FRAMEWORK}.framework"
  [ -d "$FW/Modules/${FRAMEWORK}.swiftmodule" ] || fail "$SLICE: no ${FRAMEWORK}.swiftmodule"
  ls "$FW/Modules/${FRAMEWORK}.swiftmodule/"*.swiftinterface >/dev/null 2>&1 \
    || fail "$SLICE: no .swiftinterface (BUILD_LIBRARY_FOR_DISTRIBUTION)"
  grep -q "framework module ${FRAMEWORK} " "$FW/Modules/module.modulemap" \
    || fail "$SLICE: module map does not define ${FRAMEWORK}"
  [ "$(/usr/libexec/PlistBuddy -c "Print :MinimumOSVersion" "$FW/Info.plist")" = "15.0" ] \
    || fail "$SLICE: MinimumOSVersion is not 15.0"
done
grep -q 's.name                = "Pisano"' "$PISANO_IOS/Pisano.podspec" || fail "podspec name is not Pisano"
grep -q "s.vendored_frameworks = '${FRAMEWORK}.xcframework'" "$PISANO_IOS/Pisano.podspec" \
  || fail "podspec does not vendor ${FRAMEWORK}.xcframework"
[ "$(grep -c "\"${FRAMEWORK}\"" "$PISANO_IOS/Package.swift")" -ge 3 ] \
  || fail "Package.swift package / product / target are not all ${FRAMEWORK}"
echo "Names OK: module ${FRAMEWORK}, pod Pisano, SPM ${FRAMEWORK}"

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
