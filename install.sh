#!/bin/bash

# nice installer
# mass programs installation in Linux


CONFIG_FILE="config.txt"
LOG_FILE="log/install.log"
DEFAULT_PACKAGES=("vlc" "gimp" "git" "code" "wireshark")

#text colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color


log_message() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $message" >> "$LOG_FILE"
}


check_root_privileges() {
    if [[ $EUID -ne 0 ]]; then
        log_message "${RED}ERR: Root required. Rerun with sudo.${NC}"
        exit 1
    fi
}


detect_package_manager() {
    if command -v apt-get &> /dev/null; then
        echo "apt"
    elif command -v dnf &> /dev/null; then
        echo "dnf"
    elif command -v yum &> /dev/null; then
        echo "yum"
    elif command -v zypper &> /dev/null; then
        echo "zypper"
    elif command -v pacman &> /dev/null; then
        echo "pacman"
    else
        log_message "${RED}ERR: Couldn't detect package manager${NC}"
        exit 1
    fi
}


is_package_installed() {
    local package="$1"
    local pm="$2"

    case $pm in
        "apt")
            dpkg -l "$package" 2>/dev/null | grep -q "^ii" && return 0
            ;;
        "dnf"|"yum")
            rpm -q "$package" &> /dev/null && return 0
            ;;
        "pacman")
            pacman -Qi "$package" &> /dev/null && return 0
            ;;
    esac
    return 1
}


install_package() {
    local package="$1"
    local pm="$2"
    local attempt=0
    local max_attempts=2

    while [[ $attempt -lt $max_attempts ]]; do
        case $pm in
            "apt")
                apt-get install -y "$package" &>> "$LOG_FILE"
                ;;
            "dnf")
                dnf install -y "$package" &>> "$LOG_FILE"
                ;;
            "yum")
                yum install -y "$package" &>> "$LOG_FILE"
                ;;
            "zypper")
                zypper --non-interactive install "$package" &>> "$LOG_FILE"
                ;;
            "pacman")
                pacman -S --noconfirm "$package" &>> "$LOG_FILE"
                ;;
        esac

        if [[ $? -eq 0 ]]; then
            return 0
        fi

        ((attempt++))
        if [[ $attempt -lt $max_attempts ]]; then
            log_message "${YELLOW}Retrying to install $package...${NC}"
            sleep 2
        fi
    done

    return 1
}

main() {
  mkdir -p "$(dirname "$LOG_FILE")"
  echo -e "${BLUE}===  Nice Installer ===${NC}"
  log_message "===  Nice Installer ==="
  }

main