#!/bin/bash

echo "=================================================="
echo "   FOSS iOS Physical Extraction Tool (Linux)      "
echo "=================================================="

echo "[*] Checking device status..."
INFO=$(irecovery -q)

# Verify the device is in an exploited/pwned DFU state
if ! echo "$INFO" | grep -q "PWND:"; then
    echo "[-] Error: Your device isn't pwned. Use usbliter8 to pwn first."
    exit 1
fi

# Extract and format the device model identifier
RAW_MODEL=$(echo "$INFO" | grep -i "^MODEL:" | awk '{print $2}')
DEVICE_MODEL=${RAW_MODEL%ap}

# Verify device compatibility against supported chips
case "$DEVICE_MODEL" in
    d321|ipad11b|d331|j210|d331p|j217|d421|n104|d431|n841|d79)
        echo "[+] Found supported device: $DEVICE_MODEL"
        ;;
    *)
        echo "[-] Error: Invalid or unsupported device model ($RAW_MODEL)."
        exit 1
        ;;
esac

# Extract Unique Device Identifiers for Forensic Naming
ECID=$(echo "$INFO" | grep -i "^ECID:" | awk '{print $2}')
SERIAL=$(echo "$INFO" | grep -i "^SRNM:" | awk '{print $2}')
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Fallback defaults if identifiers are missing
[ -z "$ECID" ] && ECID="UNKNOWN_ECID"
[ -z "$SERIAL" ] && SERIAL="UNKNOWN_SERIAL"

# Cellebrite-style Forensic Naming Convention
OUTPUT_FILE="Physical_Extraction_${DEVICE_MODEL}_${SERIAL}_${ECID}_${TIMESTAMP}.img"
LOG_FILE="Extraction_Report_${DEVICE_MODEL}_${SERIAL}_${TIMESTAMP}.log"

# Save hardware metadata to a forensic log file
echo "$INFO" > "$LOG_FILE"
echo "[+] Forensic log initialized: $LOG_FILE"

# --- FIX: Define correct path inside Resources/boot/ ---
BOOT_FILE="Resources/boot/iBEC.${DEVICE_MODEL}.RELEASE.patched"

# Verify the boot patch file actually exists before running the loader
if [ ! -f "$BOOT_FILE" ]; then
    echo "[-] Error: Target boot file not found at $BOOT_FILE"
    echo "    Please verify your files are located in the Resources/boot/ directory."
    exit 1
fi

echo "[*] Sending boot image from: $BOOT_FILE..."
Resources/usbliter8_boot "$BOOT_FILE"

echo "[*] Waiting for ramdisk environment to initialize..."
sleep 5

# 2. Set up local network forwarding port
PORT=2222

echo "[*] Starting USB multiplexer (iproxy) on port $PORT..."
iproxy $PORT 22 > /dev/null 2>&1 &
IPROXY_PID=$!

# Ensure the background proxy process is killed when the script finishes or exits
cleanup() {
    echo -e "\n[*] Cleaning up background processes..."
    kill $IPROXY_PID 2>/dev/null
    exit
}
trap cleanup EXIT INT TERM

# 3. Test SSH communication with the active Ramdisk
echo "[*] Verifying SSH connection to device..."
ssh -p $PORT -o ConnectTimeout=5 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@localhost "echo 'Connected'" > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "[-] Error: Cannot establish connection to the device's SSH ramdisk."
    echo "    Verify that the boot payload includes an active SSH configuration."
    exit 1
fi

# 4. Stream the raw storage blocks to the host machine
echo "[+] Connection verified."
echo "[*] Beginning full NAND extraction from /dev/rdisk0..."
echo "[*] Storing image to: $OUTPUT_FILE"
echo "[*] Keep USB connection stable. Processing..."

ssh -p $PORT -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@localhost "dd if=/dev/rdisk0 bs=1m" > "$OUTPUT_FILE"

if [ $? -eq 0 ] && [ -s "$OUTPUT_FILE" ]; then
    echo "[+] Success! Physical extraction complete."
    echo "[+] Image saved to: $(pwd)/$OUTPUT_FILE"
else
    echo "[-] Error: The data extraction process was interrupted or resulted in an empty file."
fi
