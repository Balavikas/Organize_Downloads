# Downloads Organizer for macOS

Automatically sorts new files in your **Downloads** folder by file type:

- **Documents** → `~/Documents`
- **Pictures** → `~/Pictures`
- Everything else stays in Downloads

It runs in the background using macOS's built-in `launchd`. It starts the moment a file lands in Downloads, keeps working after restarts, and doesn't need a Terminal window open.

---

## Files

| File | Purpose |
|---|---|
| `organize_downloads.sh` | The script that checks extensions and moves files |
| `install.sh` | One-time installer that sets up the background job |
| `README.md` | This file |

---

## Supported File Types

**Documents:** `pdf` `txt` `rtf` `doc` `docx` `odt` `pages` `md` `csv` `xls` `xlsx` `numbers` `ppt` `pptx` `key` `epub`

**Pictures:** `jpg` `jpeg` `png` `gif` `heic` `heif` `webp` `bmp` `tif` `tiff` `svg`

Extensions are case-insensitive, so `PHOTO.JPG` and `photo.jpg` are both handled.

---

## Installation

1. Put `organize_downloads.sh` and `install.sh` in the **same folder**.
2. Open **Terminal** and run:
   ```bash
   cd /path/to/that/folder
   bash install.sh
   ```
3. **Grant permission.** macOS blocks background scripts from accessing Downloads, Documents, and Pictures until you allow it:
   1. Open **System Settings → Privacy & Security → Full Disk Access**.
   2. Click **+**, press **Cmd + Shift + G**, type `/bin/bash`, and press Enter.
   3. Make sure its toggle is **on**.

After installing, you can move or delete the original two files. The installer copies the script to `~/Scripts/organize_downloads.sh`, and the background job runs that copy.

---

## How It Works

- The job runs whenever `~/Downloads` changes, plus every 60 seconds as a safety net.
- **Incomplete downloads** (`.crdownload`, `.download`, `.part`, `.partial`, `.tmp`) are skipped until they finish.
- Files modified in the last 5 seconds are skipped in case they're still being written. The next run picks them up.
- **Hidden files, folders, and files without an extension** are ignored.
- **Name conflicts never overwrite anything.** If `report.pdf` already exists, the new file becomes `report (1).pdf`, then `report (2).pdf`, and so on.

---

## Testing

Download any PDF or PNG. Within a few seconds it should appear in Documents or Pictures.

To check the activity log:
```bash
cat ~/Library/Logs/organize-downloads.log
```

To watch it live:
```bash
tail -f ~/Library/Logs/organize-downloads.log
```

---

## Customization

### Add or remove file types

Edit `~/Scripts/organize_downloads.sh` and change these lines:
```bash
DOC_EXTS="pdf txt rtf doc docx ..."
PIC_EXTS="jpg jpeg png gif ..."
```
Use lowercase, space-separated extensions. Changes apply on the next run, so you don't need to reinstall.

### Change destination folders

Edit these lines in the same script:
```bash
DOCS="$HOME/Documents"
PICS="$HOME/Pictures"
```
Each destination folder must already exist.

### Store the script somewhere other than `~/Scripts`

Before installing, edit this line in `install.sh`:
```bash
SCRIPT_DIR="$HOME/Scripts"
```
Then run `bash install.sh`. Re-running the installer safely replaces any previous setup.

> ⚠️ Don't move `~/Scripts/organize_downloads.sh` by hand after installing. The background job points to that exact path. To relocate it, use the step above.

---

## Managing the Background Job

**Check if it's running:**
```bash
launchctl list | grep organize-downloads
```

**Stop it:**
```bash
launchctl bootout gui/$(id -u) ~/Library/LaunchAgents/com.user.organize-downloads.plist
```

**Start it again:**
```bash
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.user.organize-downloads.plist
```

---

## Uninstall

```bash
launchctl bootout gui/$(id -u) ~/Library/LaunchAgents/com.user.organize-downloads.plist
rm ~/Library/LaunchAgents/com.user.organize-downloads.plist
rm ~/Scripts/organize_downloads.sh
rm ~/Library/Logs/organize-downloads.log ~/Library/Logs/organize-downloads.err
```
Optionally, remove `/bin/bash` from **Full Disk Access** in System Settings.

---

## Troubleshooting

| Problem | Fix |
|---|---|
| Files aren't moving | Check that `/bin/bash` has Full Disk Access, then look at `~/Library/Logs/organize-downloads.err` |
| Log shows `Operation not permitted` | Full Disk Access is missing or turned off for `/bin/bash` |
| A file type isn't sorted | Add its extension to `DOC_EXTS` or `PIC_EXTS` |
| Job isn't listed in `launchctl list` | Run `bash install.sh` again |
| A file stays in Downloads briefly | Normal: recent files wait up to about a minute in case they're still downloading |