#!/bin/bash
#
# Log Rotation with Archiving - Configuration File Support
# Usage: ./rotate-with-archive.sh [archive_dir] [keep_recent] [archive_days]
#
# Rotates logs, keeps recent ones in backup dir, archives old ones

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load configuration
CONFIG_FILE="${SCRIPT_DIR}/logrotate.config"
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    echo "ERROR: Configuration file not found: $CONFIG_FILE"
    exit 1
fi

# Override settings if provided as arguments
ARCHIVE_DIR=${1:-$ARCHIVE_DIR}
KEEP_RECENT=${2:-$ARCHIVE_KEEP_RECENT}
ARCHIVE_DAYS=${3:-$ARCHIVE_RETENTION_DAYS}

echo "=== Log Rotation with Archiving ==="
echo "Configuration loaded from: $CONFIG_FILE"
echo "Log file: $LOG_FILE"
echo "Backup directory: $BACKUP_DIR"
echo "Archive directory: $ARCHIVE_DIR"
echo "Keep recent: $KEEP_RECENT"
echo "Archive retention: $ARCHIVE_DAYS days"
echo

# Create archive directory if it doesn't exist
mkdir -p "$ARCHIVE_DIR" || {
    echo "ERROR: Cannot create archive directory: $ARCHIVE_DIR"
    exit 1
}

# Check if log file exists and is not empty
if [ ! -f "$LOG_FILE" ]; then
    echo "ERROR: Log file not found: $LOG_FILE"
    exit 1
fi

if [ ! -s "$LOG_FILE" ]; then
    echo "Log file is empty, skipping rotation"
    exit 0
fi

# Rotate the log
TIMESTAMP=$(date +"$TIMESTAMP_FORMAT")
LOG_BASENAME=$(basename "$LOG_FILE")
ROTATED_LOG="${BACKUP_DIR}/${LOG_BASENAME}-${TIMESTAMP}"

echo "Rotating log..."
cp "$LOG_FILE" "$ROTATED_LOG" || {
    echo "ERROR: Failed to copy log file"
    exit 1
}

: > "$LOG_FILE" || {
    echo "ERROR: Failed to truncate log file"
    exit 1
}

echo "✓ Created: $ROTATED_LOG"

# Compress
if [ "$COMPRESSION_TOOL" != "none" ] && command -v "$COMPRESSION_TOOL" &> /dev/null; then
    echo "Compressing with $COMPRESSION_TOOL..."
    
    case "$COMPRESSION_TOOL" in
        gzip)
            gzip -$GZIP_LEVEL "$ROTATED_LOG"
            ROTATED_LOG="${ROTATED_LOG}.gz"
            ;;
        bzip2)
            bzip2 "$ROTATED_LOG"
            ROTATED_LOG="${ROTATED_LOG}.bz2"
            ;;
        xz)
            xz "$ROTATED_LOG"
            ROTATED_LOG="${ROTATED_LOG}.xz"
            ;;
    esac
    
    echo "✓ Compressed: $ROTATED_LOG"
fi

# Move old logs to archive (keep only KEEP_RECENT in backup dir)
echo
echo "Managing backups and archives..."
cd "$BACKUP_DIR" || exit 1

LOG_COUNT=$(ls -1 "${LOG_BASENAME}"-* 2>/dev/null | wc -l)

if [ "$LOG_COUNT" -gt "$KEEP_RECENT" ]; then
    TO_ARCHIVE=$((LOG_COUNT - KEEP_RECENT))
    echo "Moving $TO_ARCHIVE log(s) to archive..."
    
    ls -1t "${LOG_BASENAME}"-* | tail -n "$TO_ARCHIVE" | while read -r old_log; do
        echo "  Archiving: $old_log"
        mv "$old_log" "$ARCHIVE_DIR/"
    done
else
    echo "Found $LOG_COUNT logs in backup dir (within limit of $KEEP_RECENT)"
fi

# Clean up old archives (older than ARCHIVE_DAYS)
echo
echo "Cleaning archives older than $ARCHIVE_DAYS days..."
DELETED_COUNT=0
find "$ARCHIVE_DIR" -name "${LOG_BASENAME}-*" -type f -mtime +$ARCHIVE_DAYS | while read -r old_archive; do
    echo "  Deleting: $(basename "$old_archive")"
    rm -f "$old_archive"
    DELETED_COUNT=$((DELETED_COUNT + 1))
done

if [ "$DELETED_COUNT" -eq 0 ]; then
    echo "No archives old enough to delete"
fi

echo
echo "=== Rotation Summary ==="
echo "Current log: $LOG_FILE ($(du -h "$LOG_FILE" 2>/dev/null | cut -f1))"
echo "Recent backups in $BACKUP_DIR: $(ls -1 "$BACKUP_DIR/${LOG_BASENAME}"-* 2>/dev/null | wc -l)"
echo "Archived logs in $ARCHIVE_DIR: $(ls -1 "$ARCHIVE_DIR/${LOG_BASENAME}"-* 2>/dev/null | wc -l)"
echo "Latest backup: $ROTATED_LOG"
echo
echo "✓ Rotation complete!"
