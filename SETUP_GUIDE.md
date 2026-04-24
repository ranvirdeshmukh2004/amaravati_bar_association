# Amaravati Bar Association — v2.0.0 Deployment & Upgrade Guide

> **Goal**: Install the new version (v2.0.0) on the client's Windows machine **without disturbing** their existing **Member** and **Subscription** data entries.

---

## Table of Contents

1. [Understanding Data Storage](#1-understanding-data-storage)
2. [Pre-Deployment Checklist](#2-pre-deployment-checklist)
3. [Step 1 — Take a Full Backup on the Client Machine](#step-1--take-a-full-backup-on-the-client-machine)
4. [Step 2 — Build the New Release on Your Dev Machine](#step-2--build-the-new-release-on-your-dev-machine)
5. [Step 3 — Prepare the Deployment Package](#step-3--prepare-the-deployment-package)
6. [Step 4 — Transfer to the Client Machine](#step-4--transfer-to-the-client-machine)
7. [Step 5 — Replace the Application Files](#step-5--replace-the-application-files)
8. [Step 6 — First Launch & Migration Verification](#step-6--first-launch--migration-verification)
9. [Step 7 — Post-Deployment Validation Checklist](#step-7--post-deployment-validation-checklist)
10. [Rollback Procedure (If Something Goes Wrong)](#rollback-procedure-if-something-goes-wrong)
11. [Troubleshooting](#troubleshooting)

---

## 1. Understanding Data Storage

Before you begin, it's critical to understand **where the application stores data**. This is why the upgrade is safe:

| Data Item | Storage Location | Affected by EXE Replacement? |
|---|---|---|
| **SQLite Database** (Members, Subscriptions, Donations, etc.) | `C:\.aba_data\aba_donation.sqlite` *(hidden folder at drive root)* | ❌ **NO** — Completely separate from app files |
| **Admin Password** | Windows Credential Manager (via `flutter_secure_storage`) | ❌ **NO** — Stored in OS, not in app folder |
| **Application EXE + DLLs** | Wherever client installed the app (e.g., `C:\ABA_App\`) | ✅ **YES** — These are what we replace |

> **IMPORTANT:** The database lives in a **hidden directory** at the root of the drive where the app is installed (e.g., `C:\.aba_data\`). It is **completely independent** of the application executable files. Replacing the EXE and DLLs will **NOT touch the database**.

> **NOTE:** The app has a built-in **migration system** (currently at Schema Version 15). When the new version launches and connects to the existing database, it will automatically upgrade the schema (add any new columns/tables) without deleting any data.

---

## 2. Pre-Deployment Checklist

Before heading to the client machine, confirm:

- [ ] You have built and **tested** the new release on your dev machine
- [ ] You have a **USB drive or network share** ready for transferring files
- [ ] You know the **install location** on the client machine (ask the client, or check the desktop shortcut → Right-click → Properties → "Start in")
- [ ] You have the **client's admin password** (or they will be present to log in)
- [ ] You have **at least 500 MB** free on the USB drive

---

## Step 1 — Take a Full Backup on the Client Machine

> **⚠️ NEVER skip this step.** Always take a backup before replacing application files.

### Option A: Database File Backup (Recommended — Fastest)

1. **Close the application** completely on the client machine (check System Tray too).
2. Open **File Explorer**.
3. Navigate to the **drive root** where the app is installed (usually `C:\`).
4. Show hidden files: **View → Show → Hidden items** (check the box).
5. You should see a folder named **`.aba_data`**.
6. Open it. You'll find a file: **`aba_donation.sqlite`**
7. **Copy this file** to a safe location:
   ```
   Copy → Paste to:  D:\ABA_Backups\backup_YYYY-MM-DD\aba_donation.sqlite
   ```
   *(Replace YYYY-MM-DD with today's date)*

### Option B: In-App JSON Backup (More Thorough)

1. Launch the **current version** of the application.
2. Log in using the admin password.
3. Go to **Settings** (bottom-left sidebar).
4. Click **Full Backup (JSON)**.
5. Save the JSON file to a secure location (USB drive or Desktop).
6. **Close the application** completely.

### Option C: In-App SQLite Backup (Via Developer Mode)

1. Launch the app and go to the **Login Screen**.
2. **Long-press the lock icon** and enter developer PIN: `dev123`.
3. In the **Developer Dashboard**, click **Create Backup**.
4. Save the backup to a safe location.
5. **Close the application** completely.

> **💡 TIP:** For maximum safety, do **both** Option A and Option B — a raw file copy plus a JSON export. Belt and suspenders.

---

## Step 2 — Build the New Release on Your Dev Machine

On your **development machine** (where the source code is):

### 2.1 — Ensure Clean Build

Open a terminal in the project root (`e:\GitHub\amaravati_bar_association`):

```powershell
# Clean previous build artifacts
flutter clean

# Fetch all dependencies
flutter pub get

# Run code generation (Drift database classes)
dart run build_runner build --delete-conflicting-outputs
```

### 2.2 — Build the Windows Release

```powershell
flutter build windows --release
```

### 2.3 — Verify Build Output

The compiled application will be located at:

```
build\windows\x64\runner\Release\
```

This folder should contain:
```
├── amaravati_bar_association.exe      ← Main executable
├── flutter_windows.dll                ← Flutter engine
├── flutter_secure_storage_windows_plugin.dll
├── sqlite3.dll                        ← SQLite library
├── window_manager_plugin.dll
├── camera_windows_plugin.dll
├── url_launcher_windows_plugin.dll
├── file_selector_windows_plugin.dll
├── data/                              ← Flutter assets bundle
│   ├── flutter_assets/
│   └── ...
└── (other plugin DLLs)
```

### 2.4 — Quick Sanity Test

Double-click `amaravati_bar_association.exe` in the Release folder to confirm it launches correctly. You should see the login screen. Close it after verifying.

---

## Step 3 — Prepare the Deployment Package

### 3.1 — Copy the Entire Release Folder

```powershell
# Create a deployment package
Copy-Item -Path "build\windows\x64\runner\Release\*" -Destination "D:\ABA_Deploy_v2.0.0\" -Recurse
```

Or simply copy the **entire contents** of `build\windows\x64\runner\Release\` to a folder on your USB drive:

```
USB Drive (E:\)
 └── ABA_Deploy_v2.0.0\
     ├── amaravati_bar_association.exe
     ├── flutter_windows.dll
     ├── sqlite3.dll
     ├── data\
     └── ... (all other files and folders)
```

### 3.2 — Include Backup of Old Version (Safety Net)

Also prepare an empty folder on the USB for backing up the client's current installation:

```
USB Drive (E:\)
 ├── ABA_Deploy_v2.0.0\          ← New version files
 └── ABA_Old_Version_Backup\     ← Will copy client's current files here
```

---

## Step 4 — Transfer to the Client Machine

1. Plug the USB drive into the **client's computer**.
2. Identify the **current installation folder**:
   - Right-click the **desktop shortcut** → **Properties**
   - Check the **"Target"** or **"Start in"** field
   - Typical location: `C:\ABA_App\` or `C:\Users\<User>\Desktop\ABA\` or similar

---

## Step 5 — Replace the Application Files

> **⚠️ WARNING:** The application **MUST be completely closed** before replacing files. Check the system tray and Task Manager to be sure.

### 5.1 — Kill the Application

```powershell
# Force-close if still running
taskkill /IM amaravati_bar_association.exe /F
```

Or use **Task Manager** → Find `amaravati_bar_association` → End Task.

### 5.2 — Backup the Current Installation

Copy the **client's current app folder** to the USB as a safety net:

```powershell
# Example: If client's app is in C:\ABA_App\
Copy-Item -Path "C:\ABA_App\*" -Destination "E:\ABA_Old_Version_Backup\" -Recurse
```

### 5.3 — Replace with New Version

Delete the old files and copy the new ones:

```powershell
# Clear old application files (NOT the database!)
Remove-Item -Path "C:\ABA_App\*" -Recurse -Force

# Copy new version files
Copy-Item -Path "E:\ABA_Deploy_v2.0.0\*" -Destination "C:\ABA_App\" -Recurse
```

> **🛑 CAUTION:** **DO NOT** touch the `.aba_data` folder at the drive root (e.g., `C:\.aba_data\`). That's the database. You are ONLY replacing files in the **application installation folder**.

### 5.4 — Verify Desktop Shortcut

If a desktop shortcut exists, right-click → Properties and confirm the **Target** still points to the correct EXE path:

```
Target: "C:\ABA_App\amaravati_bar_association.exe"
```

If the shortcut is broken, create a new one:
1. Right-click Desktop → **New → Shortcut**
2. Browse to `C:\ABA_App\amaravati_bar_association.exe`
3. Name it: **Amaravati Bar Association**

---

## Step 6 — First Launch & Migration Verification

### 6.1 — Launch the New Version

Double-click the shortcut or the new EXE.

**What happens behind the scenes on first launch:**

```
App starts → Opens existing aba_donation.sqlite →
Detects schema version (e.g., v12) →
Runs migration to v15 →
  • Adds uuid, isSynced, lastUpdatedAt, deleted columns to members
  • Adds uuid, isSynced, lastUpdatedAt, deleted columns to subscriptions
  • Adds uuid, isSynced, lastUpdatedAt, deleted columns to past_outstanding_dues
  • Adds uuid, isSynced, lastUpdatedAt, deleted columns to donations
  • Adds uuid, isSynced, deleted columns to subscription_config
  • Backfills UUIDs for all existing records
→ Ready!
```

> **NOTE:** The migration is **additive only** — it only ADDS new columns. It never deletes or modifies existing data. All member names, registration numbers, subscription amounts, receipt numbers, etc. remain exactly as they were.

### 6.2 — Log In

- Use the **same admin password** as before. The password is stored in Windows Credential Manager, not in the app files, so it persists across updates.
- If the client forgot the password, use **Developer Login** (long-press lock icon → PIN: `dev123`) and reset it from the Developer Dashboard.

---

## Step 7 — Post-Deployment Validation Checklist

After logging in, verify the following with the client:

| # | Check | How to Verify | Expected |
|---|---|---|---|
| 1 | **Members are intact** | Go to **Members Registry** → Scroll through list | All existing members visible |
| 2 | **Member count matches** | Check **Dashboard** → Total Members KPI | Same number as before |
| 3 | **Subscriptions are intact** | Go to **Subscriptions** tab → Browse records | All payment records visible |
| 4 | **Total collection matches** | Check **Dashboard** → Total Subscriptions KPI | Same amount as before |
| 5 | **Search works** | Search for a specific member by name | Member found with all details |
| 6 | **Receipts work** | Generate a test receipt for any existing transaction | PDF generates correctly |
| 7 | **Member status correct** | Spot-check a few members' Active/Suspended status | Status unchanged |
| 8 | **Past Outstanding Dues** | Check Arrears screen if previously used | Dues records preserved |
| 9 | **Donation Records** | Check donation records if previously used | Donations preserved |
| 10 | **New features work** | Try adding a test member or subscription | New entry created successfully |

> **💡 TIP:** Ask the client to name 2-3 specific members they remember and verify those records are exactly as they were. This builds confidence.

---

## Rollback Procedure (If Something Goes Wrong)

If the new version has issues, you can **instantly rollback**:

### Quick Rollback (< 2 minutes)

1. **Close** the new version of the app.
2. Delete the new application files:
   ```powershell
   Remove-Item -Path "C:\ABA_App\*" -Recurse -Force
   ```
3. Copy back the old version from your backup:
   ```powershell
   Copy-Item -Path "E:\ABA_Old_Version_Backup\*" -Destination "C:\ABA_App\" -Recurse
   ```
4. Launch the old version. Everything will work as before.

### Database Rollback (Only if database was somehow corrupted)

1. Close the application.
2. Navigate to `C:\.aba_data\` (show hidden files).
3. Rename the current database:
   ```
   aba_donation.sqlite  →  aba_donation_corrupted.sqlite
   ```
4. Copy your backup database file:
   ```powershell
   Copy-Item "E:\ABA_Backups\backup_YYYY-MM-DD\aba_donation.sqlite" "C:\.aba_data\aba_donation.sqlite"
   ```
5. Launch the application. The old data will be restored.

---

## Troubleshooting

### ❌ "App won't launch / crashes on startup"

- **Cause**: Missing DLL files or incomplete copy.
- **Fix**: Ensure ALL files from the Release folder were copied, including the `data\` subfolder and all `.dll` files.

### ❌ "App launches but shows 'Set Password' screen (first-run setup)"

- **Cause**: The `flutter_secure_storage` data was cleared, or the app is running from a different Windows user account.
- **Fix**: This does NOT affect the database. Set a new password and log in. All members and subscriptions will still be there.

### ❌ "App launches but database is empty"

- **Cause**: The app might be installed on a different drive than before, so it's looking for `.aba_data` on the wrong drive root.
- **Fix**:
  1. Find the old `.aba_data` folder on the original drive.
  2. Copy `aba_donation.sqlite` to the new drive's `.aba_data` folder.
  3. Or restore from the backup you took in Step 1.

### ❌ "DLL errors or Visual C++ errors"

- **Cause**: Missing Visual C++ Redistributable on client machine.
- **Fix**: Download and install the [Microsoft Visual C++ Redistributable (x64)](https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist) — choose the latest x64 version.

### ❌ "Permission denied when accessing C:\.aba_data"

- **Cause**: The app is running without sufficient permissions.
- **Fix**: Right-click the EXE → **Run as administrator** for the first launch, or ensure the user account has write access to the drive root.

---

## Quick Reference Card

```
╔══════════════════════════════════════════════════════════════════╗
║              DEPLOYMENT QUICK REFERENCE — v2.0.0               ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  DATABASE LOCATION:  {DriveRoot}\.aba_data\aba_donation.sqlite   ║
║  APP PASSWORD:       Windows Credential Manager (persists)       ║
║  SCHEMA VERSION:     15 (auto-migrates from any prior)           ║
║  BUILD COMMAND:      flutter build windows --release             ║
║  BUILD OUTPUT:       build\windows\x64\runner\Release\           ║
║                                                                  ║
║  ⚠️  NEVER DELETE:   .aba_data folder                            ║
║  ✅  SAFE TO REPLACE: Everything in the app install folder       ║
║                                                                  ║
╠══════════════════════════════════════════════════════════════════╣
║  ROLLBACK: Copy old EXE+DLLs back. DB is untouched.             ║
╚══════════════════════════════════════════════════════════════════╝
```

---

## Summary of What's Safe

| Action | Members Safe? | Subscriptions Safe? | Password Safe? |
|---|:---:|:---:|:---:|
| Replace EXE + DLLs | ✅ Yes | ✅ Yes | ✅ Yes |
| Delete app install folder | ✅ Yes | ✅ Yes | ✅ Yes |
| Reinstall from scratch | ✅ Yes | ✅ Yes | ✅ Yes |
| Format the drive | ❌ **NO** | ❌ **NO** | ❌ **NO** |
| Delete `.aba_data` folder | ❌ **NO** | ❌ **NO** | ✅ Yes |

---

*Last updated: 21 April 2026 — Version 2.0.0*
*Prepared by: GajSysAI Labs — @works.ranvirdeshmukh.com*
