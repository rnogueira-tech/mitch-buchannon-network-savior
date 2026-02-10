#!/bin/bash

# =========================================================
# Mitch Buchannon
# =========================================================
# Description: Restart Lan interface if failed
# Author: RNogueira
# Requirements:

VERSION="1.0.0"
SCRIPT_NAME="mitch_buchannon"

# =========================================================
# Configuration
# =========================================================
INTERFACE="eth2"                        # Interface to be monitored
LOG_DIR="/volume1/logs/mitch_buchannon" # Log directory
LOG_RETENTION_DAYS=7                    # Log retention
LOG_LEVEL="DEBUG"                       # Log Level ex.: DEBUG, INFO, WARN, ERROR

# =========================================================
# LOGGING AND INITIALIZATION FUNCTIONS
# =========================================================
LOG_FILE_BASE_NAME="$SCRIPT_NAME.log"

initialize() {
    mkdir -p "$LOG_DIR"
    update_log_file
    clean_old_logs
    log "INFO" "Initialization" "=== Starting $SCRIPT_NAME version $VERSION ==="
}

update_log_file() {
    CURRENT_DATE=$(date +%Y-%m-%d)
    LOG_FILE="$LOG_DIR/$CURRENT_DATE-$LOG_FILE_BASE_NAME"
    touch "$LOG_FILE" 2>/dev/null
}

log() {
    local severity=$(printf '%-5.5s' "$1")
    local process=$(printf '%-15.15s' "$2")
    local message="$3"

    local level_num
    case "$LOG_LEVEL" in
        "DEBUG") level_num=4 ;;
        "INFO") level_num=3 ;;
        "WARN") level_num=2 ;;
        "ERROR") level_num=1 ;;
        *) level_num=3 ;;
    esac

    local severity_num
    case "$severity" in
        "DEBUG") severity_num=4 ;;
        "INFO") severity_num=3 ;;
        "WARN") severity_num=2 ;;
        "ERROR") severity_num=1 ;;
        *) severity_num=3 ;;
    esac

    [ "$severity_num" -gt "$level_num" ] && return

    if [ "$(date +%Y-%m-%d)" != "$CURRENT_DATE" ]; then
        update_log_file
        clean_old_logs
    fi

    echo "$(date '+%H:%M:%S')-[$severity][$process]-$message" >> "$LOG_FILE"
}

clean_old_logs() {
    find "$LOG_DIR" -name "*-${LOG_FILE_BASE_NAME}" -type f -mtime +"$LOG_RETENTION_DAYS" -delete 2>/dev/null
}

# =========================================================
# HELPER FUNCTIONS
# =========================================================

check_interface_exists() {
    if ip link show "$INTERFACE" > /dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

check_interface_up() {
    local state
    state=$(cat "/sys/class/net/$INTERFACE/operstate" 2>/dev/null)

    if [ "$state" = "up" ]; then
        log "DEBUG" "InterfaceCheck" "Interface $INTERFACE está UP"
        return 0
    else
        log "WARN" "InterfaceCheck" "Interface $INTERFACE está $state"
        return 1
    fi
}

#check_interface_has_ip() {
#    if /sbin/ifconfig "$INTERFACE" | grep -q "inet "; then
#        log "DEBUG" "InterfaceCheck" "Interface $INTERFACE tem endereço IP"
#        return 0
#    else
#        log "WARN" "InterfaceCheck" "Interface $INTERFACE não tem endereço IP"
#        return 1
#    fi
#}


# =========================================================
# BUSSINESS FUNCTIONS
# =========================================================


refresh_interface() {

    if check_interface_exists; then
        log "DEBUG" "InterfaceCheck" "Interface $INTERFACE present. No action required."
        return 0
    fi
    log "WARN" "Recovery" "Interface $INTERFACE not found!"

    /sbin/ifconfig "$INTERFACE" up > /dev/null 2>&1
    sleep 5

    if check_interface_up; then
        log "INFO" "Recovery" "Recovered on the first attempt (ifconfig up)."
        return 0
    fi

    /etc/rc.network restart
    sleep 10

    if check_interface_exists; then
        log "INFO" "Recovery" "Recovered on the second attempt (rc.network restart)."
        return 0
    else
        log "ERROR" "Recovery" "Fail to recover interface $INTERFACE"
        return 1
    fi
}

# =========================================================
# MAIN EXECUTION
# =========================================================

main() {
    initialize

    if ! refresh_interface; then
        log "ERROR" "Script" "Interface check failed"
    fi
}

# Execute script
main
