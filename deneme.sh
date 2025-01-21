#!/bin/sh

set -e

rm -rf /tmp/luna-install
mkfifo /tmp/luna-install
echo "[ ] Installing..."
luna-send-pub -w 15000 -i 'luna://com.webos.appInstallService/dev/install' '{"id":"com.ares.defaultName","ipkUrl":"/tmp/hbchannel.ipk","subscribe":true}' >/tmp/luna-install &
LUNA_PID=$!

if ! result="$(fgrep -m 1 -e 'installed' -e 'failed' /tmp/luna-install)"; then
    rm /tmp/luna-install
    echo "[!] Install timed out"
    exit 1
fi

kill -TERM "$LUNA_PID" 2>/dev/null || true
rm /tmp/luna-install

case "$result" in
    *installed*) ;;
    *)
        echo "[!] Install failed - $result"
        exit 1
    ;;
esac

echo
echo "[*]"
echo "[*] Youtube!"
echo "[*]"
echo
)
