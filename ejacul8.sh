#!/bin/bash
echo "free software should be free."
echo "Checking device"
INFO=$(irecovery -q)

if ! echo "$INFO" | grep -q "PWND:"; then
    echo "your device isnt pwned. use usbliter8 to pwn."
    exit 1
fi

RAW_MODEL=$(echo "$INFO" | grep -i "^MODEL:" | awk '{print $2}')
DEVICE_MODEL=${RAW_MODEL%ap}


case "$DEVICE_MODEL" in
    d321|ipad11b|d331|j210|d331p|j217|d421|n104|d431|n841|d79)
        echo "found supported device: $DEVICE_MODEL"
        ;;
    *)
        echo "error: invalid or unsupported device model ($RAW_MODEL)."
        exit 1
        ;;
esac

BOOT_FILE="iBEC.${DEVICE_MODEL}.RELEASE.patched"
echo "Sending boot image: $BOOT_FILE..."
Resources/usbliter8_boot "$BOOT_FILE"

sleep 2

echo "okay it booted, setting variables to obliterate"
irecovery -c "setenv oblit-inprogress 5"
irecovery -c saveenv
irecovery -c go
irecovery -c reset

echo "should be all done. worked? give me a star"
echo "fuck paid bypasses. support foss."
