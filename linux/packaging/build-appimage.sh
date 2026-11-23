#!/usr/bin/env bash
# Builds EasyCalc-<version>-x86_64.AppImage from build/linux/x64/release/bundle (run `flutter build linux --release` first).
# Needs `appimagetool` on PATH. GTK3 stays on the host; the Flutter bundle carries everything else.
set -euo pipefail
cd "$(dirname "$0")/../.."

rm -rf AppDir && mkdir -p AppDir/usr/bin AppDir/usr/share/applications AppDir/usr/share/icons/hicolor/scalable/apps
# Flutter finds data/ and lib/ next to the executable, so keep the bundle intact.
cp -r build/linux/x64/release/bundle/. AppDir/usr/bin/
cp linux/packaging/*.desktop AppDir/ && cp linux/packaging/*.desktop AppDir/usr/share/applications/
cp linux/packaging/*.svg AppDir/ && cp linux/packaging/*.svg AppDir/usr/share/icons/hicolor/scalable/apps/

cat > AppDir/AppRun <<'EOF'
#!/bin/sh
HERE="$(dirname "$(readlink -f "$0")")"
exec "$HERE/usr/bin/easycalc" "$@"
EOF
chmod +x AppDir/AppRun

VERSION="$(sed -nE 's/^version: *([^+]*).*/\1/p' pubspec.yaml)"
# Update info: AppImageUpdate-style tools fetch the .zsync from the latest release and download only the changed blocks.
ARCH=x86_64 appimagetool --no-appstream \
  -u "gh-releases-zsync|evandro777|EasyCalc|latest|EasyCalc-*x86_64.AppImage.zsync" \
  AppDir "EasyCalc-$VERSION-x86_64.AppImage"
