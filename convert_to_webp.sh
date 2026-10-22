export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

# --- Satu dialog: pilih kualiti + mode (Return = pilih default, Escape = batal) ---
CHOICE=$(osascript -e 'choose from list {"40% - Low (2 core)", "40% - Mid (4 core)", "40% - High (8 core)", "50% - Low (2 core)", "50% - Mid (4 core)", "50% - High (8 core)", "65% - Low (2 core)", "65% - Mid (4 core)", "65% - High (8 core)"} with prompt "Pilih kualiti & mode:" default items {"50% - High (8 core)"}')

# Kalau user tekan Escape/cancel, CHOICE = "false" -> keluar tanpa buat apa-apa
if [ "$CHOICE" = "false" ]; then
    exit 0
fi

case "$CHOICE" in
    "40% - Low (2 core)")   Q=40; NPROC=2 ;;
    "40% - Mid (4 core)")   Q=40; NPROC=4 ;;
    "40% - High (8 core)")  Q=40; NPROC=8 ;;
    "50% - Low (2 core)")   Q=50; NPROC=2 ;;
    "50% - Mid (4 core)")   Q=50; NPROC=4 ;;
    "50% - High (8 core)")  Q=50; NPROC=8 ;;
    "65% - Low (2 core)")   Q=65; NPROC=2 ;;
    "65% - Mid (4 core)")   Q=65; NPROC=4 ;;
    "65% - High (8 core)")  Q=65; NPROC=8 ;;
    *)                      Q=50; NPROC=8 ;;
esac

export WEBP_QUALITY=$Q
TOTAL=$#

# --- Parallel convert: NPROC fail serentak, 1 fail = 1 core (P-core sahaja, max 8) ---
printf '%s\0' "$@" | xargs -0 -n1 -P "$NPROC" zsh -c '
    f="$1"
    dir="${f%/*}"
    filename="${f##*/}"
    basename="${filename%.*}"
    ext="${filename##*.}"
    ext_lower=$(echo "$ext" | tr "[:upper:]" "[:lower:]")
    case "$ext_lower" in
        jpg|jpeg|png|tiff|bmp)
            cwebp -q "$WEBP_QUALITY" "$f" -o "$dir/$basename.webp"
            ;;
    esac
' _

osascript -e "display notification \"${TOTAL} fail ditukar ke WebP (kualiti ${Q}%)\" with title \"Convert to WebP\""
