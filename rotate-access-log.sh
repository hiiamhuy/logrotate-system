#!/bin/bash
#
# Log Rotation Script with Configuration File Support
# Usage: ./rotate-access-log.sh [keep_count]
#
# This script rotates the access_log file using settings from logrotate.config

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load configuration
CONFIG_FILE="${SCRIPT_DIR}/logrotate.config"
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    echo "ERROR: Configuration file not found: $CONFIG_FILE"
    echo "Please create logrotate.config or specify paths manually"
    exit 1
fi

# Override keep count if provided as argument
KEEP_COUNT=${1:-$DEFAULT_KEEP_COUNT}

echo "=== Log Rotation Script ==="
echo "Configuration loaded from: $CONFIG_FILE"
echo "Log file: $LOG_FILE"
echo "Backup directory: $BACKUP_DIR"
echo "Keep count: $KEEP_COUNT"
echo

# Check if log file exists
if [ ! -f "$LOG_FILE" ]; then
    echo "ERROR: Log file not found: $LOG_FILE"
    exit 1
fi

# Check if log file is not empty
if [ ! -s "$LOG_FILE" ]; then
    echo "Log file is empty, nothing to rotate"
    exit 0
fi

# Check write permissions
if [ ! -w "$LOG_FILE" ]; then
    echo "ERROR: No write permission for log file: $LOG_FILE"
    exit 1
fi

if [ ! -w "$BACKUP_DIR" ]; then
    echo "ERROR: No write permission for backup directory: $BACKUP_DIR"
    exit 1
fi

# Create timestamp
TIMESTAMP=$(date +"$TIMESTAMP_FORMAT")
LOG_BASENAME=$(basename "$LOG_FILE")
ROTATED_LOG="${BACKUP_DIR}/${LOG_BASENAME}-${TIMESTAMP}"

echo "Rotating $LOG_FILE..."

# Copy the log file
cp "$LOG_FILE" "$ROTATED_LOG" || {
    echo "ERROR: Failed to copy log file"
    exit 1
}

# Truncate the original
: > "$LOG_FILE" || {
    echo "ERROR: Failed to truncate log file"
    exit 1
}

echo "✓ Created: $ROTATED_LOG"

# Compress the rotated log
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

# Clean up old logs in backup directory
echo "Cleaning up old logs (keeping $KEEP_COUNT most recent)..."
cd "$BACKUP_DIR" || exit 1

# Count log files for this log
LOG_COUNT=$(ls -1 "${LOG_BASENAME}"-* 2>/dev/null | wc -l)

if [ "$LOG_COUNT" -gt "$KEEP_COUNT" ]; then
    TO_DELETE=$((LOG_COUNT - KEEP_COUNT))
    echo "Found $LOG_COUNT logs, deleting $TO_DELETE oldest..."
    
    ls -1t "${LOG_BASENAME}"-* | tail -n "$TO_DELETE" | while read -r old_log; do
        echo "  Deleting: $old_log"
        rm -f "$old_log"
    done
else
    echo "Found $LOG_COUNT logs (within limit of $KEEP_COUNT)"
fi

echo
echo "=== Rotation Summary ==="
echo "Current log: $LOG_FILE ($(du -h "$LOG_FILE" 2>/dev/null | cut -f1))"
echo "Latest backup: $ROTATED_LOG"
echo "Total backups: $(ls -1 "$BACKUP_DIR/${LOG_BASENAME}"-* 2>/dev/null | wc -l)"
echo "Backup location: $BACKUP_DIR"
echo
echo "✓ Rotation complete!"
