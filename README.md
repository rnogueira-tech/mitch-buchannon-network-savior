# Mitch Buchannon Network Monitor

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## 📋 Description
Bash script to automatically monitor and restart network interfaces on Linux and Synology DSM systems.

⚠️ <b>Special Note:</b> This script was specifically created to address network interface failures when using the "DSM driver for Realtek RTL8152/8153/8156/8157/8159 based USB Ethernet adapters". Some users may experience occasionally drop connections on Synology systems, and this script provides automated recovery. 

🔥 <b>Test Environment:</b>
- Diskstation: DS423+
- DSM: 7.3.2
- Network adapter: Wavlink 5 Gbps (RTL8157/Type-C)
- r8152 driver version: r8152-geminilake-2.20.1-1_7.2  [https://github.com/bb-qq/r8152/releases/tag/2.20.1-1]

## ✨ Features
- Continuous network interface monitoring
- Multi-level automatic recovery
- Rotating log system
- Easy configuration via variables
- Log retention support

## 🚀 Installation

### Prerequisites
- Bash 4.0+
- Linux or Synology DSM system
- Root/sudo permissions

### Installation Steps

```bash
# 1. Clone the repository
git clone git clone https://github.com/rnogueira-tech/mitch-buchannon-network-savior.git

# 2. Enter the directory
cd mitch-buchannon-network-monitor

# 3. Grant execute permission
chmod +x mitch_buchannon.sh

# 4. Configure script (Check configuration section)
nano mitch_buchannon.sh
```
### ⚙️ Configuration

```bash
# 1. Set the network interface to monitor (default: eth2)
INTERFACE="eth2"

# 2. Set the log directory (default: /volume1/logs/monitors)
LOG_DIR="/volume1/logs/monitors"

# 3. Log retention days (default: 7)
LOG_RETENTION_DAYS=7

# 4. Log level: DEBUG, INFO, WARN, ERROR (default: DEBUG)
LOG_LEVEL="DEBUG"
```

## 🎈 Usage

### Basic Usage

Run the script manually:
```bash
# Run
sudo ./mitch_buchannon.sh

# Check the logs
tail -f /volume1/logs/monitors/$(date +%Y-%m-%d)-mitch_buchannon.log
```

### Automated Scheduling on Synology DSM
1. Open DSM Control Panel
2. Go to "Control Panel" → "Task Scheduler"
3. Create a Scheduled Task
4. Click "Create" → "Scheduled Task" → "User-defined script"
5. Configure "General" tab
```text
Task: Mitch Buchannon Network Monitor
User: root
```
6. Configure "Schedule" tab  (recommended every 5-15 minutes)
```text
Repite: Daily
Time:
    Start time: 00:00
    Continue running on the same day: Checked
    Repeat every: 10 minutes
```
7. Configure "Task Definition" tab
On script to execute:
```bash
    bash /path/to/your/mitch-buchannon-network-monitor/mitch_buchannon.sh
```
8. Set "OK" and Apply"
## 📊 Log Examples

Successful monitoring:
```text
2024-01-15 14:30:00 - [INFO][Initialization] - === Starting mitch_buchannon version 1.0.0 ===
2024-01-15 14:30:00 - [DEBUG][InterfaceCheck] - Interface eth2 is UP
2024-01-15 14:30:00 - [INFO][Main] - Interface check completed successfully
```
Realtek adapter recovery:
```text
2024-01-15 14:35:00 - [WARN][InterfaceCheck] - Realtek adapter eth2 is down (common RTL815x issue)
2024-01-15 14:35:00 - [INFO][InterfaceRecovery] - Attempting recovery for Realtek USB adapter
2024-01-15 14:35:05 - [INFO][InterfaceRecovery] - Successfully recovered Realtek adapter eth2
```
Driver-specific error:
```text
2024-01-15 14:40:00 - [ERROR][InterfaceCheck] - Realtek driver error detected on eth2
2024-01-15 14:40:00 - [INFO][DriverRecovery] - Reloading r8152 driver module
2024-01-15 14:40:10 - [INFO][DriverRecovery] - Driver reload successful
```

## 🛡️ Safety Notes
Always test the script in a controlled environment before deploying to production. The script will restart network interfaces, which may cause temporary connectivity loss.
313

## 🤝 Contribution

Contributions are welcome! Please:
1. Fork the project
2. Create a branch (git checkout -b feature/new-feature)
3. Commit your changes (git commit -m 'Add new feature')
4. Push to the branch (git push origin feature/new-feature)
5. Open a Pull Request

## 📞 Suporte
- Issues: GitHub Issues
- Community Help: Synology forums and Realtek driver communities

## 🙏 Agradecimentos
- Open source community
- bb-qq for maintaining the r8152 driver - [https://github.com/bb-qq/r8152]

