#!/bin/bash
# Organize ~/Downloads: documents -> ~/Documents, pictures -> ~/Pictures.
# Everything else (zip, dmg, etc.) is left alone.

DOWNLOADS="$HOME/Downloads"
DOCS="$HOME/Documents"
PICS="$HOME/Pictures"
LOG="$HOME/Library/Logs/organize-downloads.log"

# Edit these lists to add/remove file types (lowercase, space-separated)
DOC_EXTS="pdf txt rtf doc docx odt pages md csv xls xlsx numbers ppt pptx key epub"
PIC_EXTS="jpg jpeg png gif heic heif webp bmp tif tiff svg"

log() { echo "$(date '+%Y-%m-%d %H:%M:%S')  $*" >> "$LOG"; }

in_list() { case " $2 " in *" $1 "*) return 0 ;; esac; return 1; }

# If a file with the same name already exists, use "name (1).ext", "name (2).ext", ...
unique_dest() {
  local dir="$1" name="$2"
  local base="${name%.*}" ext="${name##*.}"
  local dest="$dir/$name" n=1
  while [ -e "$dest" ]; do
    dest="$dir/$base ($n).$ext"
    n=$((n + 1))
  done
  echo "$dest"
}

shopt -s nullglob
for f in "$DOWNLOADS"/*; do
  [ -f "$f" ] || continue                      # skip folders (and Safari's in-progress .download bundles)
  name="$(basename "$f")"
  case "$name" in .*) continue ;; esac         # skip hidden files
  case "$name" in *.*) ;; *) continue ;; esac  # skip files with no extension

  ext="$(echo "${name##*.}" | tr '[:upper:]' '[:lower:]')"
  case "$ext" in crdownload|download|part|partial|tmp) continue ;; esac  # still downloading

  # Skip anything modified in the last 5 seconds (may still be writing); next run will catch it
  age=$(( $(date +%s) - $(stat -f %m "$f") ))
  [ "$age" -lt 5 ] && continue

  if in_list "$ext" "$DOC_EXTS"; then
    target="$DOCS"
  elif in_list "$ext" "$PIC_EXTS"; then
    target="$PICS"
  else
    continue
  fi

  dest="$(unique_dest "$target" "$name")"
  if mv -n "$f" "$dest"; then
    log "Moved: $name -> $dest"
  else
    log "FAILED to move: $name"
  fi
done
