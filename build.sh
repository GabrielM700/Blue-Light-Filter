#!/usr/bin/env bash
# Builds the tile APK, drops it into the module and zips a flashable module.
# Needs: JDK 17+, Android SDK (build-tools + a platform), zip.
set -euo pipefail
cd "$(dirname "$0")"

SDK="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-}}"
[ -d "$SDK" ] || { echo "Set ANDROID_HOME to your Android SDK path"; exit 1; }
BT="$(ls -d "$SDK"/build-tools/* | sort -V | tail -1)"
JAR="$(ls -d "$SDK"/platforms/android-*/android.jar | sort -V | tail -1)"
echo "build-tools: $BT"; echo "android.jar: $JAR"

VER="$(grep '^version=' module.prop | cut -d= -f2)"
VC="$(grep '^versionCode=' module.prop | cut -d= -f2)"
OUT_DIR="system/app/BlueFilterTile"
B="$PWD/build"
rm -rf "$B"; mkdir -p "$B/classes" "$B/dex" "$OUT_DIR" dist

"$BT/aapt2" compile --dir tile-app/res -o "$B/res.zip"
"$BT/aapt2" link -o "$B/base.apk" -I "$JAR" \
    --manifest tile-app/AndroidManifest.xml \
    --min-sdk-version 26 --target-sdk-version 34 \
    --version-code "$VC" --version-name "$VER" \
    "$B/res.zip"

javac --release 8 -Xlint:-options -classpath "$JAR" -d "$B/classes" \
    $(find tile-app/src -name '*.java')
"$BT/d8" --release --min-api 26 --lib "$JAR" --output "$B/dex" \
    $(find "$B/classes" -name '*.class')
(cd "$B/dex" && zip -q "$B/base.apk" classes.dex)

"$BT/zipalign" -f -p 4 "$B/base.apk" "$B/aligned.apk"
KS="$B/debug.keystore"
keytool -genkeypair -keystore "$KS" -storepass android -keypass android \
    -alias key -keyalg RSA -keysize 2048 -validity 10000 -dname "CN=BlueFilter" >/dev/null 2>&1
"$BT/apksigner" sign --ks "$KS" --ks-pass pass:android --key-pass pass:android \
    --out "$OUT_DIR/BlueFilterTile.apk" "$B/aligned.apk"

ZIP="dist/BlueLightFilter_v${VER//./_}.zip"
rm -f "$ZIP"
zip -qr "$ZIP" . -x 'tile-app/*' '.github/*' 'build/*' 'dist/*' '.git/*' 'build.sh' 'README.md'
echo "OK -> $ZIP"
