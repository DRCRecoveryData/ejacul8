# iOS Physical Forensic Extraction Utility

A Free and Open Source Software (FOSS) automation script designed to perform a raw bit-stream physical extraction of the NAND storage chip from supported iOS devices. It leverages custom SSH ramdisk environments over USB multiplexing to pull low-level diagnostic images, saving them using professional forensic naming conventions similar to industry-standard suites like Cellebrite.

---

## Features

* **Automated Device Preflight:** Checks for `PWND` DFU state and verifies hardware model compatibility automatically.
* **Forensic Structural Naming:** Generates structured target files utilizing unique physical hardware metadata:
    `Physical_Extraction_[Device_Model]_[Serial_Number]_[ECID]_[Timestamp].img`
* **Automatic Metadata Logging:** Captures and outputs a corresponding `.log` file containing full hardware registry data for chain-of-custody tracking.
* **Robust Network Port Forwarding:** Deploys internal background handlers via `iproxy` to stream binary block-level partitions seamlessly over SSH using `dd`.

---

## Prerequisites & Directory Structure

Ensure your host Linux machine has the required system packages installed:

```bash
sudo apt update
sudo apt install libimobiledevice-utils irecovery openssh-client

```

### Required File Tree Layout

The main script relies on specific pre-compiled boot and environment utilities. Organize your folder structure as follows before running the extraction:

```text
├── dump_nand.sh             <-- The main extraction script
└── Resources/
    ├── usbliter8_boot       <-- Hardware boot loader utility binary
    └── boot/
        ├── iBEC.d321.RELEASE.patched
        ├── iBEC.d331.RELEASE.patched
        └── [Other supported patched boot stages...]

```

---

## Usage Instructions

### 1. Prepare Target Device

Place the target iOS device into a **pwned DFU mode** utilizing your choice of hardware security implementation framework (such as `usbliter8` or a compatible `checkm8` utility tool).

### 2. Set Script Execution Permissions

Grant execute privileges to the automation shell script:

```bash
chmod +x dump_nand.sh

```

### 3. Execute Extraction Run

Run the script from your terminal environment. Ensure your current terminal directory points to the parent folder containing the `Resources/` asset pathway:

```bash
./dump_nand.sh

```

---

## Output Architecture

Upon a successful capture pass, two files will initialize inside your working path:

1. **`.img` Asset File:** The complete, uncompressed raw block image binary data dumped directly from `/dev/rdisk0`.
2. **`.log` Asset File:** Contains full extraction environmental logs, internal timestamps, and physical hardware indicators parsed during initialization.

> [!WARNING]
> **Storage Requirement Warning:** The generated image file format is a bit-stream reflection copy of the underlying flash controller. A 64GB storage device target will output a file size of exactly 64GB, regardless of active data volumes. Ensure your workstation partition has adequate free capacity before initiating.

---

## License & Ethos

Built completely using open standards. Support open-source digital forensic framework engineering (FOSS).

```
 
