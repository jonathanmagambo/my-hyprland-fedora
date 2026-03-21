#!/bin/bash
# ╔══════════════════════════════════════════════════════════════╗
# ║          FEDORA HYPRLAND - FULL SETUP SCRIPT                ║
# ║  Runs KooL's Fedora-Hyprland installer, then applies        ║
# ║  custom dotfiles on top.                                    ║
# ╚══════════════════════════════════════════════════════════════╝
#
# USAGE:
#   chmod +x setup.sh
#   ./setup.sh
#
# REQUIREMENTS: Fedora 41+
# NOTE: Run a full system update + reboot BEFORE running this.

set -e

INSTALLER_DIR="$HOME/Fedora-Hyprland"

GREEN="\e[32m"
YELLOW="\e[33m"
CYAN="\e[36m"
RED="\e[31m"
RESET="\e[0m"

echo -e "${CYAN}"
echo "  ██╗  ██╗██╗   ██╗██████╗ ██████╗ ██╗      █████╗ ███╗   ██╗██████╗ "
echo "  ██║  ██║╚██╗ ██╔╝██╔══██╗██╔══██╗██║     ██╔══██╗████╗  ██║██╔══██╗"
echo "  ███████║ ╚████╔╝ ██████╔╝██████╔╝██║     ███████║██╔██╗ ██║██║  ██║"
echo "  ██╔══██║  ╚██╔╝  ██╔═══╝ ██╔══██╗██║     ██╔══██║██║╚██╗██║██║  ██║"
echo "  ██║  ██║   ██║   ██║     ██║  ██║███████╗██║  ██║██║ ╚████║██████╔╝"
echo "  ╚═╝  ╚═╝   ╚═╝   ╚═╝     ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝ "
echo -e "${RESET}"
echo -e "${YELLOW}  Fedora 41+ | Hyprland | Custom Dotfiles${RESET}"
echo ""

# ── Step 1: Safety checks ─────────────────────────────────────────────────────
if [[ $EUID -eq 0 ]]; then
    echo "ERROR: Do NOT run this script as root."
    exit 1
fi

if ! grep -q "Fedora" /etc/os-release 2>/dev/null; then
    echo "ERROR: This script is for Fedora only."
    exit 1
fi

FEDORA_VERSION=$(grep -oP '\d+' /etc/fedora-release | head -1)
echo -e "${GREEN}  Fedora ${FEDORA_VERSION} detected${RESET}"

if [[ "$FEDORA_VERSION" -lt 41 ]]; then
    echo -e "${RED}ERROR: Fedora ${FEDORA_VERSION} is not supported. This setup requires Fedora 41+.${RESET}"
    exit 1
fi

# ── Step 2: GDM detection (GNOME / Security Lab installs) ─────────────────────
# If GDM is running, the KooL installer cannot install SDDM without first
# disabling it. Detect and prompt the user.
echo ""
if systemctl is-active --quiet gdm.service 2>/dev/null || systemctl is-active --quiet gdm3.service 2>/dev/null; then
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${YELLOW}  WARNING: GDM (GNOME Display Manager) is running.${RESET}"
    echo -e "${YELLOW}  Fedora Security Lab ships with GNOME + GDM by default.${RESET}"
    echo ""
    echo -e "${CYAN}  To install SDDM (recommended for Hyprland), you must:${RESET}"
    echo "   1. Disable GDM:  sudo systemctl disable --now gdm.service"
    echo "   2. Reboot"
    echo "   3. Log into TTY (Ctrl+Alt+F2), then re-run this script"
    echo "   4. Choose SDDM when the installer asks"
    echo ""
    echo -e "${YELLOW}  OR: Continue without SDDM and launch Hyprland via TTY (type 'Hyprland')${RESET}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo ""
    read -rp "Disable GDM now and prepare for SDDM? (Requires reboot) [y/N]: " DISABLE_GDM
    if [[ "${DISABLE_GDM,,}" == "y" ]]; then
        echo -e "${CYAN}  Disabling GDM...${RESET}"
        sudo systemctl disable gdm.service 2>/dev/null || sudo systemctl disable gdm3.service 2>/dev/null || true
        echo -e "${GREEN}  GDM disabled.${RESET}"
        echo ""
        echo -e "${YELLOW}  Next steps:${RESET}"
        echo "   1. Reboot now:  sudo reboot"
        echo "   2. Log in via TTY (Ctrl+Alt+F2)"
        echo "   3. cd into this folder and run: ./setup.sh"
        echo "   4. In the installer, select SDDM and an SDDM theme"
        echo ""
        read -rp "Reboot now? [y/N]: " DO_REBOOT
        if [[ "${DO_REBOOT,,}" == "y" ]]; then
            sudo reboot
        fi
        exit 0
    fi
fi

# ── Step 3: Ensure git is available ───────────────────────────────────────────
if ! command -v git &>/dev/null; then
    echo -e "${CYAN}  Installing git...${RESET}"
    sudo dnf install -y git
fi

# ── Step 4: Run KooL Fedora-Hyprland installer ────────────────────────────────
echo ""
echo -e "${CYAN}━━━ Step 1/2: KooL Fedora-Hyprland Installer ━━━${RESET}"
echo ""

if [ -d "$INSTALLER_DIR" ]; then
    echo -e "${YELLOW}  Found existing $INSTALLER_DIR — pulling latest...${RESET}"
    cd "$INSTALLER_DIR" && git pull
else
    echo -e "${GREEN}  Cloning Fedora-Hyprland installer...${RESET}"
    git clone --depth=1 https://github.com/JaKooLit/Fedora-Hyprland.git "$INSTALLER_DIR"
fi

cd "$INSTALLER_DIR"
chmod +x install.sh

echo ""
echo -e "${YELLOW}  Installer tips:${RESET}"
echo "   - Select: ZSH, GTK themes, XDG Portal, Thunar"
echo "   - Select: 'dots' to install KooL's base dotfiles"
echo "   - Select: SDDM (only if GDM was disabled and you rebooted)"
echo "   - Select: NVIDIA if you have an NVIDIA GPU"
echo "   - Quickshell is optional (AGS fallback works fine)"
echo ""
echo -e "${YELLOW}  Press ENTER to launch the installer...${RESET}"
read -r
./install.sh

# ── Step 5: Apply custom dotfiles ─────────────────────────────────────────────
echo ""
echo -e "${CYAN}━━━ Step 2/2: Applying Custom Dotfiles ━━━${RESET}"
echo ""
chmod +x "$(dirname "$0")/apply-dots.sh"
"$(dirname "$0")/apply-dots.sh"
