#!/bin/bash

: '
    @Author: José Costa      - https://github.com/zepedrocosta
'

set -euo pipefail
IFS=$'\n\t'

GREEN="\033[0;32m"
CYAN="\033[0;36m"
ORANGE="\033[0;33m"
RED="\033[0;31m"
NONE="\033[0m"

log() { echo -e "[$(date '+%H:%M:%S')] $1"; }
success() { log "${GREEN}$1${NONE}"; }
warn() { log "${ORANGE}$1${NONE}"; }
error() {
    log "${RED}Error:${NONE} $1" >&2
    exit 1
}

timer() {
    local message="$1"
    local done_msg="${2:-Done!}"
    local secs=3
    while [ $secs -gt 0 ]; do
        echo -ne "${CYAN}$message ${ORANGE}$secs\r${NONE}"
        sleep 1
        ((secs--))
    done
    echo -e "${CYAN}$message ${ORANGE}0\r${NONE}"
    success "$done_msg"
}

trap 'error "Installation interrupted."' INT TERM

INSTALL_DIR="$HOME/.script"
TARGET_SCRIPT="$INSTALL_DIR/script.sh"
SOURCE_DIR="$(pwd)"
SOURCE_SCRIPT="$SOURCE_DIR/script.sh"

[ -f "$SOURCE_SCRIPT" ] || error "Could not find ./script.sh in current directory."

timer "Installing the script now..."
mkdir -p "$INSTALL_DIR"

# Copy the entire directory contents
cp -r "$SOURCE_DIR/"* "$INSTALL_DIR/"

chmod u+x "$TARGET_SCRIPT"
sed -i 's/\r$//' "$TARGET_SCRIPT"

success "Script and related files copied successfully!"

SHELL_RC=""
case "$SHELL" in
    */bash) SHELL_RC="$HOME/.bashrc" ;;
    */zsh) SHELL_RC="$HOME/.zshrc" ;;
    */fish) SHELL_RC="$HOME/.config/fish/config.fish" ;;
    *)
        SHELL_RC="$HOME/.bashrc"
        warn "Unknown shell, defaulting to .bashrc"
        ;;
esac

ALIAS_CMD="alias system='$TARGET_SCRIPT'"

if ! grep -Fxq "$ALIAS_CMD" "$SHELL_RC" 2>/dev/null; then
    echo -e "\n$ALIAS_CMD" >>"$SHELL_RC"
    success "Alias 'system' added to $SHELL_RC"
else
    warn "Alias 'system' already exists in $SHELL_RC"
fi

if [ -n "$SHELL_RC" ] && [ -f "$SHELL_RC" ]; then
    source "$SHELL_RC" || true
fi

success "Installation complete! 🎉"
echo -e "Reboot the VM and run '${CYAN}system${NONE}' to launch your script."
