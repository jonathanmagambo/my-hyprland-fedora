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
# REQUIREMENTS: Fedora 41, fresh install, full system update done first.

set -e

DOTFILES_DIR="$(cd "$(dirname "$0")/dotfiles" && pwd)"
INSTALLER_DIR="$HOME/Fedora-Hyprland"

GREEN="\e[32m"
YELLOW="\e[33m"
CYAN="\e[36m"
RESET="\e[0m"

echo -e "${CYAN}"
echo "  ██╗  ██╗██╗   ██╗██████╗ ██████╗ ██╗      █████╗ ███╗   ██╗██████╗ "
echo "  ██║  ██║╚██╗ ██╔╝██╔══██╗██╔══██╗██║     ██╔══██╗████╗  ██║██╔══██╗"
echo "  ███████║ ╚████╔╝ ██████╔╝██████╔╝██║     ███████║██╔██╗ ██║██║  ██║"
echo "  ██╔══██║  ╚██╔╝  ██╔═══╝ ██╔══██╗██║     ██╔══██║██║╚██╗██║██║  ██║"
echo "  ██║  ██║   ██║   ██║     ██║  ██║███████╗██║  ██║██║ ╚████║██████╔╝"
echo "  ╚═╝  ╚═╝   ╚═╝   ╚═╝     ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝ "
echo -e "${RESET}"
echo -e "${YELLOW}  Fedora 41 + Hyprland + Custom Dotfiles${RESET}"
echo ""

# ── Step 1: Safety checks ─────────────────────────────────────────────────────
if [[ $EUID -eq 0 ]]; then
    echo "❌ Do NOT run this script as root."
    exit 1
fi

if ! grep -q "Fedora" /etc/os-release 2>/dev/null; then
    echo "❌ This script is for Fedora only."
    exit 1
fi

FEDORA_VERSION=$(grep -oP '\d+' /etc/fedora-release | head -1)
echo -e "${GREEN}✔ Fedora ${FEDORA_VERSION} detected${RESET}"

if [[ "$FEDORA_VERSION" -lt 41 ]]; then
    echo "⚠️  Warning: This setup was tested on Fedora 41+. You are on Fedora ${FEDORA_VERSION}."
    read -rp "Continue anyway? (y/N): " CONT
    [[ "${CONT,,}" != "y" ]] && exit 1
fi

# ── Step 2: Install KooL Fedora-Hyprland ─────────────────────────────────────
echo ""
echo -e "${CYAN}━━━ Step 1/2: KooL Fedora-Hyprland Installer ━━━${RESET}"
echo ""

if [ -d "$INSTALLER_DIR" ]; then
    echo -e "${YELLOW}↻ Found existing $INSTALLER_DIR — pulling latest...${RESET}"
    cd "$INSTALLER_DIR" && git pull
else
    echo -e "${GREEN}↓ Cloning Fedora-Hyprland installer...${RESET}"
    git clone --depth=1 https://github.com/JaKooLit/Fedora-Hyprland.git "$INSTALLER_DIR"
fi

cd "$INSTALLER_DIR"
chmod +x install.sh
echo ""
echo -e "${YELLOW}📋 When the installer asks about dotfiles, select 'dots' to download KooL's base.${RESET}"
echo -e "${YELLOW}   ✅ Also select: ZSH, GTK themes, SDDM, XDG Portal, Thunar${RESET}"
echo -e "${YELLOW}   Press ENTER to continue into the installer...${RESET}"
read -r
./install.sh

# ── Step 3: Apply custom dotfiles ─────────────────────────────────────────────
echo ""
echo -e "${CYAN}━━━ Step 2/2: Applying Custom Dotfiles ━━━${RESET}"
echo ""

chmod +x "$DOTFILES_DIR/../apply-dots.sh"
"$DOTFILES_DIR/../apply-dots.sh"
