#!/bin/bash

# nice installer
# mass programs installation in Linux


CONFIG_FILE="config.txt"
LOG_FILE="log/install.log"
DEFAULT_PACKAGES=("vlc" "gimp" "git" "code" "wireshark-qt")

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
        log_message "ERR: Root required. Rerun with sudo."
        echo -e "${RED}ERR: Root required. Rerun with sudo.${NC}"
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
        log_message "ERR: Couldn't detect package manager"
        echo -e "${RED}ERR: Couldn't detect package manager${NC}"
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
            log_message "Retrying to install $package..."
            echo -e "${YELLOW}Retrying to install $package...${NC}"
            sleep 2
        fi
    done

    return 1
}


update_repositories() {
    local pm="$1"

    log_message "Updating package information..."
    echo -e "${BLUE}Updating package information...${NC}"
    case $pm in
        "apt")
            apt-get update &>> "$LOG_FILE"
            ;;
        "dnf")
            dnf check-update &>> "$LOG_FILE"
            ;;
        "yum")
            yum check-update &>> "$LOG_FILE"
            ;;
        "zypper")
            zypper refresh &>> "$LOG_FILE"
            ;;
        "pacman")
            pacman -Sy &>> "$LOG_FILE"
            ;;
    esac
}


read_config_file() {
    local packages=()
    if [[ -f "$CONFIG_FILE" ]]; then
        while IFS= read -r line || [[ -n "$line" ]]; do
            # skip newlines
            if [[ -n "$line" && ! "$line" =~ ^[[:space:]]*# ]]; then
                # remove spaces
                local package=$(echo "$line" | xargs)
                packages+=("$package")
            fi
        done < "$CONFIG_FILE"
    else

        packages=("${DEFAULT_PACKAGES[@]}")
    fi

    echo "${packages[@]}"
}


main() {

    mkdir -p "$(dirname "$LOG_FILE")"

    > "$LOG_FILE"

    log_message "===  Nice Installer ==="
    echo -e "${BLUE}===  Nice Installer ===${NC}"

    check_root_privileges

    local package_manager=$(detect_package_manager)
    log_message "Your packet manager: $package_manager"
    echo -e "${BLUE}Your packet manager: $package_manager${NC}"

    log_message "Reading config file..."
    echo -e "${BLUE}Reading config file...${NC}"
    local packages=($(read_config_file))


    echo -e "${BLUE}========================================${NC}"
    echo -e "These packages will be installed:"
    for package in "${packages[@]}"; do
        echo -e "  - $package"
    done


    read -p "Continue with installation? (Y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_message "Canceled"
        echo -e "${YELLOW}Canceled${NC}"
        exit 0
    fi


    update_repositories "$package_manager"

    # Установка пакетов
    local success_count=0
    local fail_count=0
    local skipped_count=0


    log_message "Installation started"
    echo -e "${BLUE}Installation started${NC}"


    for package in "${packages[@]}"; do
        if is_package_installed "$package" "$package_manager"; then
            log_message "⚠️ $package is already installed"
            echo -e "${YELLOW}⚠️ $package is already installed${NC}"
            ((skipped_count++))
            continue
        fi

        log_message "Installing $package..."
        echo -e "${BLUE}Installing $package...${NC}"

        if install_package "$package" "$package_manager"; then
            log_message "✅ $package installed successfully"
            echo -e "${GREEN}✅ $package installed successfully${NC}"
            ((success_count++))
        else
            log_message "❌ ERR: $package was not installed"
            echo -e "${RED}❌ ERR: $package was not installed${NC}"
            ((fail_count++))
        fi
    done

    # REPORT
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}Installation report${NC}"
    echo -e "${GREEN}Installed: $success_count${NC}"
    echo -e "${YELLOW}Skipped: $skipped_count${NC}"
    echo -e "${RED}ERRORS: $fail_count${NC}"
    echo -e "${BLUE}log file: $LOG_FILE${NC}"

    if [[ $fail_count -eq 0 ]]; then
        echo -e "${GREEN}All packages installed${NC}"
    else
        echo -e "${RED}ERR: Some packages were not installed. Check log file${NC}"
    fi

    log_message "Installed: $success_count, Skipped: $skipped_count, ERRORS: $fail_count"
    echo -e "${BLUE}Installed: $success_count, Skipped: $skipped_count, ERRORS: $fail_count${NC}"
}


trap 'log_message "User interrupt"; exit 1' INT TERM
main "$@"