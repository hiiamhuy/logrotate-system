#!/bin/bash
#
# Size-Based Log Rotation Script with Configuration File Support
# Usage: ./rotate-by-size.sh [max_size_mb] [keep_count]
#
# Rotates the log only if it exceeds the specified size

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
MAX_SIZE_MB=${1:-$DEFAULT_MAX_SIZE_MB}
KEEP_COUNT=${2:-$DEFAULT_KEEP_COUNT}

echo "=== Size-Based Log Rotation Script ==="
echo "Configuration loaded from: $CONFIG_FILE"
echo "Log file: $LOG_FILE"
echo "Backup directory: $BACKUP_DIR"
echo "Size threshold: ${MAX_SIZE_MB}MB"
echo "Keep count: $KEEP_COUNT"
echo

# Check if log file exists
if [ ! -f "$LOG_FILE" ]; then
    echo "ERROR: Log file not found: $LOG_FILE"
    exit 1
fi

# Get current file size in MB
CURRENT_SIZE=$(du -m "$LOG_FILE" | cut -f1)

echo "Current log size: ${CURRENT_SIZE}MB (threshold: ${MAX_SIZE_MB}MB)"

# Check if rotation is needed
if [ "$CURRENT_SIZE" -lt "$MAX_SIZE_MB" ]; then
    echo "✓ Log file is below threshold, no rotation needed"
    exit 0
fi

echo "⚠ Log file exceeds threshold, rotating..."
echo

# Create timestamp
TIMESTAMP=$(date +"$TIMESTAMP_FORMAT")
LOG_BASENAME=$(basename "$LOG_FILE")
ROTATED_LOG="${BACKUP_DIR}/${LOG_BASENAME}-${TIMESTAMP}"

# Copy and truncate
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

# Clean up old logs
echo "Cleaning up old logs..."
cd "$BACKUP_DIR" || exit 1

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
echo
echo "✓ Rotation complete!"
