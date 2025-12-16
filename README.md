# Log Rotation System with Configurable Paths

Easy-to-use log rotation scripts for managing access logs without root access. All paths are configurable through a central configuration file.

## Turning On Log Files

Before rotating logs, you need to ensure your log files are active and collecting data.

### Enabling Personal Log Files

The Personal Log File service depends on specific files in your Web directory: `access_log`, `referer_log`, and `extended_log`. When these files exist, they accumulate data via nightly installments. You can enable one, two, or all three files depending on what information you need.

**To turn on a personal log file:**

1. Log into your web development server using a terminal emulator.
2. At the prompt, change directories to your home directory:
   ```bash
   cd ~
   ```
3. Use the `touch` command to create and enable a log file. For example, to enable your personal extended_log file:
   ```bash
   touch extended_log
   ```
   Or to enable all three log files at once:
   ```bash
   touch access_log referer_log extended_log
   ```

**Note:** Your log file is now enabled, but it will be empty until around midnight when the first batch of data is delivered. Once data starts accumulating, you can use these rotation scripts to manage the log files.

### Understanding the Three Log Types

- **access_log** - Records all requests to your website (most commonly used)
- **referer_log** - Records which pages referred visitors to your site
- **extended_log** - Records detailed information about each request

**These rotation scripts can handle any or all of these log files.** See the "Rotating Multiple Log Files" section below for setup instructions.

## Download & Setup

### Quick Install

```bash
# 1. Extract the downloaded archive
# For .tar.gz files:
tar xzf logrotate-system.tar.gz
cd logrotate-system

# OR for .zip files:
unzip logrotate-system.zip
cd logrotate-system

# 2. Make scripts executable
chmod +x *.sh

# 3. Configure your paths
./configure-logrotate.sh

# 4. Test the rotation
./rotate-access-log.sh

# 5. Set up automation
./setup-cron.sh
```

## What's Included

| File | Description |
|------|-------------|
| **logrotate.config** | Central configuration file (paths, settings) |
| **configure-logrotate.sh** | Interactive setup wizard |
| **rotate-access-log.sh** | Time-based rotation script |
| **rotate-by-size.sh** | Size-based rotation script |
| **rotate-with-archive.sh** | Rotation with archiving |
| **setup-cron.sh** | Automated scheduling helper |

## Quick Start Guide

**IMPORTANT: Choose Your Setup**
- **Single Log File:** Follow Step 1A to rotate just one log (e.g., access_log only)
- **Multiple Log Files:** Follow Step 1B to rotate all three logs (access_log, referer_log, extended_log)

### Step 1A: Configure for Single Log File

**Option A: Interactive (Recommended)**
```bash
./configure-logrotate.sh
```
This will ask you:
- Where is your log file? (e.g., `/hw00/d19/x/access_log`)
- Where should backups go? (e.g., `/home/user/log-backups`)
- How many logs to keep?
- Compression settings

**Option B: Manual Edit**
```bash
nano logrotate.config
```
Edit these key settings:
```bash
LOG_FILE="/hw00/d19/x/access_log"
BACKUP_DIR="/home/user/log-backups"
DEFAULT_KEEP_COUNT=7
```

### Step 1B: Configure for Multiple Log Files (All Three)

To rotate all three log types (access_log, referer_log, extended_log), create separate config files:

```bash
# Create three config files
cp logrotate.config access_log.config
cp logrotate.config referer_log.config
cp logrotate.config extended_log.config
```

Edit each config file with the appropriate log file path:

```bash
# Edit access_log.config
nano access_log.config
# Set: LOG_FILE="/hw00/d19/x/access_log"
#      BACKUP_DIR="/home/user/access-backups"

# Edit referer_log.config
nano referer_log.config
# Set: LOG_FILE="/hw00/d19/x/referer_log"
#      BACKUP_DIR="/home/user/referer-backups"

# Edit extended_log.config
nano extended_log.config
# Set: LOG_FILE="/hw00/d19/x/extended_log"
#      BACKUP_DIR="/home/user/extended-backups"
```

**OR** use the same backup directory for all three:
```bash
BACKUP_DIR="/home/user/log-backups"  # Same for all three configs
```

### Step 2: Test Your Setup

**For Single Log File:**
```bash
# Run a test rotation
./rotate-access-log.sh

# Check the results
ls -lh $BACKUP_DIR/
```

**For Multiple Log Files:**
```bash
# Test each log rotation
CONFIG_FILE="./access_log.config" ./rotate-access-log.sh
CONFIG_FILE="./referer_log.config" ./rotate-access-log.sh
CONFIG_FILE="./extended_log.config" ./rotate-access-log.sh

# Check the results
ls -lh /home/user/access-backups/
ls -lh /home/user/referer-backups/
ls -lh /home/user/extended-backups/
```

### Step 3: Automate It

**For Single Log File:**
```bash
# Interactive cron setup
./setup-cron.sh

# Or manually add to crontab:
crontab -e

# Add this line for daily rotation at 2 AM:
0 2 * * * /full/path/to/rotate-access-log.sh >> ~/logrotate.log 2>&1
```

**For Multiple Log Files:**
```bash
# Edit crontab
crontab -e

# Add these lines to rotate all three logs daily at 2 AM:
0 2 * * * CONFIG_FILE=/full/path/to/access_log.config /full/path/to/rotate-access-log.sh >> ~/logrotate.log 2>&1
0 2 * * * CONFIG_FILE=/full/path/to/referer_log.config /full/path/to/rotate-access-log.sh >> ~/logrotate.log 2>&1
0 2 * * * CONFIG_FILE=/full/path/to/extended_log.config /full/path/to/rotate-access-log.sh >> ~/logrotate.log 2>&1
```

**Note:** The three rotations will run one after another. If you prefer them at different times:
```bash
0 2 * * * CONFIG_FILE=/full/path/to/access_log.config /full/path/to/rotate-access-log.sh >> ~/logrotate.log 2>&1
5 2 * * * CONFIG_FILE=/full/path/to/referer_log.config /full/path/to/rotate-access-log.sh >> ~/logrotate.log 2>&1
10 2 * * * CONFIG_FILE=/full/path/to/extended_log.config /full/path/to/rotate-access-log.sh >> ~/logrotate.log 2>&1
```

## Complete Example: Rotating All Three Log Types

Here's a step-by-step walkthrough for setting up rotation for access_log, referer_log, and extended_log:

### Step-by-Step Setup

**1. Extract the scripts:**
```bash
tar xzf logrotate-system.tar.gz
cd logrotate-system
chmod +x *.sh
```

**2. Create three config files:**
```bash
cp logrotate.config access_log.config
cp logrotate.config referer_log.config
cp logrotate.config extended_log.config
```

**3. Edit access_log.config:**
```bash
nano access_log.config
```
Set these values:
```bash
LOG_FILE="/hw00/d19/x/access_log"
BACKUP_DIR="/home/user/backups/access"
DEFAULT_KEEP_COUNT=7
```

**4. Edit referer_log.config:**
```bash
nano referer_log.config
```
Set these values:
```bash
LOG_FILE="/hw00/d19/x/referer_log"
BACKUP_DIR="/home/user/backups/referer"
DEFAULT_KEEP_COUNT=7
```

**5. Edit extended_log.config:**
```bash
nano extended_log.config
```
Set these values:
```bash
LOG_FILE="/hw00/d19/x/extended_log"
BACKUP_DIR="/home/user/backups/extended"
DEFAULT_KEEP_COUNT=7
```

**6. Test each rotation:**
```bash
CONFIG_FILE="./access_log.config" ./rotate-access-log.sh
CONFIG_FILE="./referer_log.config" ./rotate-access-log.sh
CONFIG_FILE="./extended_log.config" ./rotate-access-log.sh
```

**7. Set up automation:**
```bash
crontab -e
```
Add these lines:
```bash
# Rotate all three logs daily at 2 AM
0 2 * * * CONFIG_FILE=~/logrotate-system/access_log.config ~/logrotate-system/rotate-access-log.sh >> ~/logrotate.log 2>&1
0 2 * * * CONFIG_FILE=~/logrotate-system/referer_log.config ~/logrotate-system/rotate-access-log.sh >> ~/logrotate.log 2>&1
0 2 * * * CONFIG_FILE=~/logrotate-system/extended_log.config ~/logrotate-system/rotate-access-log.sh >> ~/logrotate.log 2>&1
```

**8. Verify cron setup:**
```bash
crontab -l | grep rotate
```

**Result:** All three log files will be automatically rotated daily at 2 AM, with backups stored in separate directories.

## Usage Examples

### Basic Time-Based Rotation

```bash
# Rotate now (keep 7 backups - default)
./rotate-access-log.sh

# Rotate and keep 14 backups
./rotate-access-log.sh 14
```

**What it does:**
- Copies `/hw00/d19/x/access_log` to backup directory
- Adds timestamp: `access_log-20241216-143022.gz`
- Empties the original log file
- Deletes old backups (keeps only the specified count)

### Size-Based Rotation

```bash
# Rotate only if log exceeds 100MB (default)
./rotate-by-size.sh

# Rotate if > 50MB, keep 10 backups
./rotate-by-size.sh 50 10
```

**When to use:** 
- Unpredictable traffic patterns
- Want to control disk usage strictly by size
- Prevent logs from growing too large

### Rotation with Archiving

```bash
# Use defaults from config
./rotate-with-archive.sh

# Custom: archive location, keep 5 recent, 180 days archive
./rotate-with-archive.sh /archive/logs 5 180
```

**How it works:**
1. Rotates the log
2. Keeps 7 most recent in backup directory
3. Moves older logs to archive directory
4. Deletes archives older than 90 days (configurable)

## Configuration Reference

### Key Settings in logrotate.config

```bash
# === Main Paths ===
LOG_FILE="/hw00/d19/x/access_log"      # Your log file location
BACKUP_DIR="/home/user/log-backups"    # Where rotated logs are stored

# === Retention ===
DEFAULT_KEEP_COUNT=7                    # Number of rotations to keep
DEFAULT_MAX_SIZE_MB=100                 # Size threshold for rotation (MB)

# === Archive Settings ===
ARCHIVE_DIR="$HOME/log-archive"        # Long-term storage location
ARCHIVE_KEEP_RECENT=7                  # Keep N recent in BACKUP_DIR
ARCHIVE_RETENTION_DAYS=90              # Keep archives for N days

# === Compression ===
COMPRESSION_TOOL="gzip"                # Options: gzip, bzip2, xz, none
GZIP_LEVEL=6                           # 1=fastest, 9=best compression

# === Naming ===
TIMESTAMP_FORMAT="%Y%m%d-%H%M%S"      # Filename timestamp format
```

### Common Path Configurations

**1. Backups in same directory as log:**
```bash
LOG_FILE="/hw00/d19/x/access_log"
BACKUP_DIR="/hw00/d19/x"
```

**2. Backups in separate directory:**
```bash
LOG_FILE="/hw00/d19/x/access_log"
BACKUP_DIR="/home/user/log-backups"
```

**3. Backups in home directory:**
```bash
LOG_FILE="/hw00/d19/x/access_log"
BACKUP_DIR="$HOME/backups/web-logs"
```

## Automation with Cron

### Using the Setup Helper

```bash
./setup-cron.sh
```

Choose from preset schedules:
1. **Daily** at 2:00 AM
2. **Every 6 hours** (size check)
3. **Weekly** on Sunday at 2:00 AM
4. **Hourly** (high traffic)
5. **Custom** schedule

### Manual Cron Configuration

```bash
# Edit your crontab
crontab -e

# Add one of these lines:
```

**Daily rotation at 2 AM:**
```
0 2 * * * /full/path/to/rotate-access-log.sh >> ~/logrotate.log 2>&1
```

**Size check every 6 hours:**
```
0 */6 * * * /full/path/to/rotate-by-size.sh >> ~/logrotate.log 2>&1
```

**Weekly on Sunday at 2 AM:**
```
0 2 * * 0 /full/path/to/rotate-access-log.sh >> ~/logrotate.log 2>&1
```

**Hourly (high traffic sites):**
```
0 * * * * /full/path/to/rotate-access-log.sh 168 >> ~/logrotate.log 2>&1
```

**With archiving (daily):**
```
0 2 * * * /full/path/to/rotate-with-archive.sh >> ~/logrotate.log 2>&1
```

### Cron Schedule Format

```
* * * * * command
│ │ │ │ │
│ │ │ │ └─── Day of week (0-7, Sunday=0 or 7)
│ │ │ └───── Month (1-12)
│ │ └─────── Day of month (1-31)
│ └───────── Hour (0-23)
└─────────── Minute (0-59)
```

**Examples:**
- `0 2 * * *` - Daily at 2:00 AM
- `0 */6 * * *` - Every 6 hours
- `*/30 * * * *` - Every 30 minutes
- `0 2 * * 0` - Weekly on Sunday at 2:00 AM
- `0 2 1 * *` - Monthly on the 1st at 2:00 AM

## Monitoring & Management

### Check Configuration

```bash
# View current settings
cat logrotate.config

# Test configuration loads correctly
source logrotate.config && echo "Config OK"
```

### View Backups

```bash
# List all backups
ls -lh $BACKUP_DIR/

# Count backups
ls -1 $BACKUP_DIR/access_log-* 2>/dev/null | wc -l

# Check total disk usage
du -sh $BACKUP_DIR/
```

### Monitor Rotation Activity

```bash
# View rotation log (from cron jobs)
tail -f ~/logrotate.log

# Last 50 entries
tail -n 50 ~/logrotate.log

# Search for errors
grep -i error ~/logrotate.log
```

### View Compressed Logs

```bash
# View gzipped log
zcat $BACKUP_DIR/access_log-20241216-143022.gz | less

# Search in compressed log
zgrep "error" $BACKUP_DIR/access_log-*.gz

# Count lines in compressed log
zcat $BACKUP_DIR/access_log-*.gz | wc -l
```

### Check Cron Status

```bash
# List your cron jobs
crontab -l

# View cron jobs for log rotation
crontab -l | grep rotate

# Edit cron jobs
crontab -e
```

## Troubleshooting

### Problem: Config file not found

```bash
# Make sure logrotate.config is in the same directory as scripts
ls -l logrotate.config

# If missing, create it
./configure-logrotate.sh
```

### Problem: Permission denied

```bash
# Check log file permissions
ls -la /hw00/d19/x/access_log

# Check backup directory permissions
ls -la $BACKUP_DIR

# Test write access
touch /hw00/d19/x/test.tmp && rm /hw00/d19/x/test.tmp && echo "Write OK"

# Test backup directory write access
touch $BACKUP_DIR/test.tmp && rm $BACKUP_DIR/test.tmp && echo "Backup dir OK"
```

### Problem: Scripts not executing from cron

```bash
# Use full paths in crontab
0 2 * * * /full/path/to/rotate-access-log.sh >> ~/logrotate.log 2>&1

# Check cron is running
systemctl status cron   # or: service cron status

# Check cron logs (if accessible)
grep CRON /var/log/syslog
```

### Problem: Backups not being created

```bash
# Run script manually with debug output
bash -x ./rotate-access-log.sh

# Check if log file exists and has content
ls -lh /hw00/d19/x/access_log
du -h /hw00/d19/x/access_log

# Verify backup directory exists
ls -ld $BACKUP_DIR
```

### Problem: Old logs not being deleted

```bash
# Check KEEP_COUNT setting
grep DEFAULT_KEEP_COUNT logrotate.config

# Manually test cleanup
./rotate-access-log.sh 5  # Should keep only 5
```

## Directory Structure Examples

### Simple Setup (Same Directory)

```
/hw00/d19/x/
├── access_log                      # Current log (active)
├── access_log-20241216-020000.gz  # Rotated backup
├── access_log-20241215-020000.gz
├── access_log-20241214-020000.gz
└── ... (7 total backups)
```

### Separate Backup Directory

```
/hw00/d19/x/
└── access_log                      # Current log (active)

/home/user/log-backups/
├── access_log-20241216-020000.gz  # Rotated backups
├── access_log-20241215-020000.gz
├── access_log-20241214-020000.gz
└── ... (7 total backups)
```

### With Archiving

```
/hw00/d19/x/
└── access_log                      # Current log (active)

/home/user/log-backups/             # Recent (7 days)
├── access_log-20241216.gz
├── access_log-20241215.gz
└── ... (7 most recent)

/home/user/log-archive/             # Archive (90 days)
├── access_log-20241130.gz
├── access_log-20241015.gz
└── ... (older logs up to 90 days)
```

## Recommended Setups by Traffic Level

### Low Traffic (<10k requests/day)
```bash
# Weekly rotation, keep 8 weeks
DEFAULT_KEEP_COUNT=8
```
Cron: `0 2 * * 0 /path/to/rotate-access-log.sh >> ~/logrotate.log 2>&1`

### Medium Traffic (10k-100k requests/day)
```bash
# Daily rotation, keep 7 days
DEFAULT_KEEP_COUNT=7
```
Cron: `0 2 * * * /path/to/rotate-access-log.sh >> ~/logrotate.log 2>&1`

### High Traffic (100k-1M requests/day)
```bash
# Size-based, check every 3 hours
DEFAULT_MAX_SIZE_MB=50
DEFAULT_KEEP_COUNT=15
```
Cron: `0 */3 * * * /path/to/rotate-by-size.sh >> ~/logrotate.log 2>&1`

### Compliance/Audit Requirements
```bash
# Daily with archiving (1 year retention)
ARCHIVE_RETENTION_DAYS=365
```
Cron: `0 2 * * * /path/to/rotate-with-archive.sh >> ~/logrotate.log 2>&1`

## Advanced Configuration

### Rotating Multiple Log Files

**Method 1: Separate Config Files (Recommended)**

This is the cleanest approach for managing multiple log types:

```bash
# Create separate configs
cp logrotate.config access_log.config
cp logrotate.config referer_log.config
cp logrotate.config extended_log.config

# Edit each with specific paths
nano access_log.config
# LOG_FILE="/hw00/d19/x/access_log"
# BACKUP_DIR="/home/user/backups/access"

nano referer_log.config
# LOG_FILE="/hw00/d19/x/referer_log"
# BACKUP_DIR="/home/user/backups/referer"

nano extended_log.config
# LOG_FILE="/hw00/d19/x/extended_log"
# BACKUP_DIR="/home/user/backups/extended"
```

**Add to crontab:**
```bash
crontab -e

# Rotate all three logs daily at 2 AM
0 2 * * * CONFIG_FILE=~/log-rotation/access_log.config ~/log-rotation/rotate-access-log.sh >> ~/logrotate.log 2>&1
0 2 * * * CONFIG_FILE=~/log-rotation/referer_log.config ~/log-rotation/rotate-access-log.sh >> ~/logrotate.log 2>&1
0 2 * * * CONFIG_FILE=~/log-rotation/extended_log.config ~/log-rotation/rotate-access-log.sh >> ~/logrotate.log 2>&1
```

**Method 2: Shared Backup Directory**

If you want all rotated logs in the same directory:

```bash
# All three configs use the same BACKUP_DIR
BACKUP_DIR="/home/user/log-backups"

# This keeps all rotated logs together:
# /home/user/log-backups/
#   ├── access_log-20241216.gz
#   ├── referer_log-20241216.gz
#   └── extended_log-20241216.gz
```

**Method 3: Different Log Types (Beyond access/referer/extended)**

For other log files (application logs, error logs, etc.):

```bash
# Create configs for any log type
cp logrotate.config app.config
cp logrotate.config error.config

# Edit each config with different paths
nano app.config   # Set LOG_FILE, BACKUP_DIR for app logs
nano error.config # Set LOG_FILE, BACKUP_DIR for error logs

# Use with scripts
CONFIG_FILE="./app.config" ./rotate-access-log.sh
CONFIG_FILE="./error.config" ./rotate-access-log.sh
```

Add to crontab:
```
0 2 * * * CONFIG_FILE=/path/to/app.config /path/to/rotate-access-log.sh >> ~/logrotate.log 2>&1
0 3 * * * CONFIG_FILE=/path/to/error.config /path/to/rotate-access-log.sh >> ~/logrotate.log 2>&1
```

### Custom Timestamp Formats

Edit `TIMESTAMP_FORMAT` in logrotate.config:

```bash
# Date only: access_log-20241216
TIMESTAMP_FORMAT="%Y%m%d"

# ISO format: access_log-2024-12-16
TIMESTAMP_FORMAT="%Y-%m-%d"

# Date and time: access_log-2024-12-16_14-30
TIMESTAMP_FORMAT="%Y-%m-%d_%H-%M"

# Week number: access_log-2024-W50
TIMESTAMP_FORMAT="%Y-W%U"

# Unix timestamp: access_log-1702818000
TIMESTAMP_FORMAT="%s"
```

### Different Compression Methods

```bash
# Fast compression (default)
COMPRESSION_TOOL="gzip"
GZIP_LEVEL=6

# Better compression (slower)
COMPRESSION_TOOL="bzip2"

# Best compression (slowest)
COMPRESSION_TOOL="xz"

# No compression
COMPRESSION_TOOL="none"
```

## FAQ

**Q: Do I need root access?**
A: No! These scripts work in user space as long as you have write access to the log file and backup directory.

**Q: Will the web server still write to the log after rotation?**
A: Yes! The scripts use the "copytruncate" method which keeps the file handle valid.

**Q: What if multiple scripts try to rotate at the same time?**
A: Each rotation creates a unique timestamp, so files won't overwrite each other.

**Q: Can I test without actually rotating?**
A: Yes, run: `bash -x ./rotate-access-log.sh` to see what would happen.

**Q: How do I remove automation?**
```bash
crontab -e  # Then delete the rotation line
```

**Q: Can I rotate multiple log files?**
A: Yes! Create separate config files for each log (see Advanced Configuration above).

**Q: How much disk space will I need?**
A: Roughly: (average_daily_log_size × keep_count) + current_log_size
Example: If logs are ~50MB/day and you keep 7 days = ~350MB + current

**Q: The log file was deleted instead of rotated?**
A: Make sure `cp` succeeded before truncating. Check permissions and disk space.

## Support Commands

```bash
# Debug configuration
source logrotate.config && env | grep -E "(LOG_|BACKUP_|ARCHIVE_)"

# Test rotation manually
./rotate-access-log.sh

# Check permissions
ls -la $LOG_FILE $BACKUP_DIR

# View recent rotation activity
tail -n 100 ~/logrotate.log

# Verify cron setup
crontab -l | grep rotate

# Check disk space
df -h $BACKUP_DIR
du -sh $BACKUP_DIR
```

## License & Credits

These scripts are provided as-is for managing log files in user space without root access. Feel free to modify and adapt them to your needs.

---

**Need Help?**
1. Check configuration: `cat logrotate.config`
2. Test manually: `./rotate-access-log.sh`
3. Check logs: `tail ~/logrotate.log`
4. Debug mode: `bash -x ./rotate-access-log.sh`
