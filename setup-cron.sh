#!/bin/bash
#
# Cron Setup Helper - Uses Configuration File
# This script helps you set up automated log rotation using cron

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/logrotate.config"

echo "=== Log Rotation Cron Setup Helper ==="
echo

# Check if config exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "⚠ Configuration file not found: $CONFIG_FILE"
    echo
    read -p "Would you like to create it now? (y/n): " create_config
    if [ "$create_config" = "y" ] || [ "$create_config" = "Y" ]; then
        exec "${SCRIPT_DIR}/configure-logrotate.sh"
    else
        echo "Please run ./configure-logrotate.sh first"
        exit 1
    fi
fi

# Load config to show summary
source "$CONFIG_FILE"

echo "Current Configuration:"
echo "  Log file: $LOG_FILE"
echo "  Backup directory: $BACKUP_DIR"
echo

echo "Choose your rotation schedule:"
echo
echo "1. Daily rotation (runs at 2:00 AM daily)"
echo "2. Size-based rotation (checks every 6 hours)"
echo "3. Weekly rotation (runs Sunday at 2:00 AM)"
echo "4. Hourly rotation (for high-traffic logs)"
echo "5. Custom schedule (you specify)"
echo "6. View cron syntax reference"
echo
read -p "Choose an option (1-6): " choice

case $choice in
    1)
        SCHEDULE="0 2 * * *"
        SCRIPT="rotate-access-log.sh"
        DESCRIPTION="Daily at 2:00 AM"
        ;;
    2)
        SCHEDULE="0 */6 * * *"
        SCRIPT="rotate-by-size.sh"
        DESCRIPTION="Every 6 hours (size check)"
        ;;
    3)
        SCHEDULE="0 2 * * 0"
        SCRIPT="rotate-access-log.sh"
        DESCRIPTION="Weekly (Sunday at 2:00 AM)"
        ;;
    4)
        SCHEDULE="0 * * * *"
        SCRIPT="rotate-access-log.sh"
        DESCRIPTION="Hourly"
        ;;
    5)
        echo
        echo "Cron format: minute hour day month weekday"
        echo "Example: 0 2 * * * = Daily at 2:00 AM"
        echo
        read -p "Enter cron schedule: " SCHEDULE
        echo
        echo "Available scripts:"
        echo "  1. rotate-access-log.sh (time-based)"
        echo "  2. rotate-by-size.sh (size-based)"
        echo "  3. rotate-with-archive.sh (with archiving)"
        read -p "Choose script (1-3): " script_choice
        case $script_choice in
            1) SCRIPT="rotate-access-log.sh" ;;
            2) SCRIPT="rotate-by-size.sh" ;;
            3) SCRIPT="rotate-with-archive.sh" ;;
            *) echo "Invalid choice"; exit 1 ;;
        esac
        DESCRIPTION="Custom: $SCHEDULE"
        ;;
    6)
        echo
        echo "=== Cron Syntax Reference ==="
        echo "Format: * * * * * command"
        echo "        │ │ │ │ │"
        echo "        │ │ │ │ └─── Day of week (0-7, Sunday=0 or 7)"
        echo "        │ │ │ └───── Month (1-12)"
        echo "        │ │ └─────── Day of month (1-31)"
        echo "        │ └───────── Hour (0-23)"
        echo "        └─────────── Minute (0-59)"
        echo
        echo "Examples:"
        echo "  0 2 * * *     - Daily at 2:00 AM"
        echo "  0 */6 * * *   - Every 6 hours"
        echo "  0 2 * * 0     - Weekly on Sunday at 2:00 AM"
        echo "  0 * * * *     - Every hour"
        echo "  */30 * * * *  - Every 30 minutes"
        echo "  0 2 1 * *     - Monthly on the 1st at 2:00 AM"
        echo
        echo "Scripts in this directory:"
        ls -1 "${SCRIPT_DIR}"/rotate-*.sh 2>/dev/null
        echo
        echo "To setup cron, run this script again and choose an option."
        exit 0
        ;;
    *)
        echo "Invalid choice"
        exit 1
        ;;
esac

CRON_LINE="$SCHEDULE ${SCRIPT_DIR}/${SCRIPT} >> ${ROTATION_LOG} 2>&1"

echo
echo "Proposed cron entry:"
echo "---"
echo "$DESCRIPTION"
echo "$CRON_LINE"
echo "---"
echo
echo "This will:"
echo "  - Run: ${SCRIPT_DIR}/${SCRIPT}"
echo "  - Schedule: $DESCRIPTION"
echo "  - Log to: $ROTATION_LOG"
echo

read -p "Add this to your crontab? (y/n): " confirm

if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
    # Check if entry already exists
    if crontab -l 2>/dev/null | grep -q "$SCRIPT"; then
        echo
        echo "⚠ A cron entry for this script already exists!"
        crontab -l 2>/dev/null | grep "$SCRIPT"
        echo
        read -p "Replace it? (y/n): " replace
        if [ "$replace" = "y" ] || [ "$replace" = "Y" ]; then
            # Remove old entry
            crontab -l 2>/dev/null | grep -v "$SCRIPT" | crontab -
        else
            echo "Keeping existing entry. Exiting."
            exit 0
        fi
    fi
    
    # Add to crontab
    (crontab -l 2>/dev/null; echo "$CRON_LINE") | crontab -
    echo
    echo "✓ Added to crontab!"
    echo
    echo "Your current crontab entries for log rotation:"
    echo "---"
    crontab -l | grep -E "rotate-.*\.sh"
    echo "---"
    echo
    echo "Useful commands:"
    echo "  View rotation logs:   tail -f $ROTATION_LOG"
    echo "  Edit crontab:         crontab -e"
    echo "  List all cron jobs:   crontab -l"
    echo "  Remove this entry:    crontab -e (then delete the line)"
    echo
    echo "To test without waiting:"
    echo "  ${SCRIPT_DIR}/${SCRIPT}"
else
    echo
    echo "Not added to crontab."
    echo "To add manually, run: crontab -e"
    echo "Then add this line:"
    echo "$CRON_LINE"
fi
