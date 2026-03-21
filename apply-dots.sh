#!/bin/bash
# ╔══════════════════════════════════════════════════════════════╗
# ║          APPLY CUSTOM DOTFILES                              ║
# ║  Run this AFTER the KooL Fedora-Hyprland installer.        ║
# ║  Overlays the custom dotfiles on top.                      ║
# ╚══════════════════════════════════════════════════════════════╝
#
# USAGE (standalone, after running KooL installer):
#   chmod +x apply-dots.sh
#   ./apply-dots.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOTFILES_DIR="$SCRIPT_DIR/dotfiles"

GREEN="\e[32m"
YELLOW="\e[33m"
CYAN="\e[36m"
RED="\e[31m"
RESET="\e[0m"

# Helper: ask a yes/no question, return 0 for yes
ask() {
    local prompt="$1"
    local reply
    read -rp "$(echo -e "${YELLOW}  $prompt [y/N]: ${RESET}")" reply
    [[ "${reply,,}" == "y" ]]
}

echo -e "${CYAN}━━━ Applying Custom Dotfiles ━━━${RESET}"
echo ""

# ── Backup existing configs ───────────────────────────────────────────────────
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
echo -e "${YELLOW}  Backing up existing configs to $BACKUP_DIR ...${RESET}"
mkdir -p "$BACKUP_DIR"
[ -d "$HOME/.config/hypr" ]     && cp -r "$HOME/.config/hypr"     "$BACKUP_DIR/"
[ -d "$HOME/.config/waybar" ]   && cp -r "$HOME/.config/waybar"   "$BACKUP_DIR/"
[ -d "$HOME/.config/kitty" ]    && cp -r "$HOME/.config/kitty"    "$BACKUP_DIR/"
[ -d "$HOME/.config/rofi" ]     && cp -r "$HOME/.config/rofi"     "$BACKUP_DIR/"
[ -d "$HOME/.config/swaync" ]   && cp -r "$HOME/.config/swaync"   "$BACKUP_DIR/"
[ -f "$HOME/.zshrc" ]           && cp "$HOME/.zshrc"              "$BACKUP_DIR/.zshrc"
echo -e "${GREEN}  Backup done: $BACKUP_DIR${RESET}"
echo ""

# ── Copy config files ─────────────────────────────────────────────────────────
echo -e "${CYAN}  Copying ~/.config files...${RESET}"
cp -r "$DOTFILES_DIR/.config/"* "$HOME/.config/"
echo -e "${GREEN}  Done${RESET}"

echo -e "${CYAN}  Copying .zshrc...${RESET}"
cp "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
echo -e "${GREEN}  Done${RESET}"

echo -e "${CYAN}  Copying .scripts...${RESET}"
mkdir -p "$HOME/.scripts"
cp -r "$DOTFILES_DIR/.scripts/"* "$HOME/.scripts/"
echo -e "${GREEN}  Done${RESET}"

echo -e "${CYAN}  Copying .themes (presets + wallpapers)...${RESET}"
mkdir -p "$HOME/.themes"
cp -r "$DOTFILES_DIR/.themes/"* "$HOME/.themes/"
echo -e "${GREEN}  Done${RESET}"

echo -e "${CYAN}  Copying Wallpapers to ~/Wallpapers...${RESET}"
mkdir -p "$HOME/Wallpapers"
cp -r "$DOTFILES_DIR/Wallpapers/"* "$HOME/Wallpapers/"
echo -e "${GREEN}  Done${RESET}"

# ── Fix animation symlink ─────────────────────────────────────────────────────
ANIM_DIR="$HOME/.config/hypr/configs/animations"
echo -e "${CYAN}  Fixing animation symlink...${RESET}"
if [ -d "$ANIM_DIR" ]; then
    rm -f "$ANIM_DIR/current_animations.conf"
    ln -sf "$ANIM_DIR/Horizontal-Quick.conf" "$ANIM_DIR/current_animations.conf"
    echo -e "${GREEN}  current_animations.conf -> Horizontal-Quick.conf${RESET}"
fi

# ── Make all scripts executable ───────────────────────────────────────────────
echo -e "${CYAN}  Making scripts executable...${RESET}"
find "$HOME/.config" -name "*.sh" -exec chmod +x {} \;
find "$HOME/.scripts" -name "*.sh" -exec chmod +x {} \;
chmod +x "$SCRIPT_DIR/sync.sh" 2>/dev/null || true
echo -e "${GREEN}  Done${RESET}"

# ── Install core packages ─────────────────────────────────────────────────────
echo ""
echo -e "${CYAN}  Installing core packages...${RESET}"
# ncmpcpp = music player, mpd = music daemon, mpd-mpris = MPRIS bridge for media keys
# grim + slurp + wl-clipboard = screenshot tools (CTRL+S keybind)
# brightnessctl = brightness keys support
# fastfetch = system info tool
sudo dnf install -y ncmpcpp mpd mpd-mpris grim slurp wl-clipboard brightnessctl fastfetch 2>/dev/null || true

# swww (animated wallpaper daemon — via COPR if not already installed by KooL)
if ! command -v swww &>/dev/null; then
    echo -e "${YELLOW}  Installing swww via COPR...${RESET}"
    sudo dnf copr enable -y sdegler/hyprland 2>/dev/null || true
    sudo dnf install -y swww 2>/dev/null || true
fi

# matugen (color generation from wallpaper — via COPR)
if ! command -v matugen &>/dev/null; then
    echo -e "${YELLOW}  Installing matugen via COPR...${RESET}"
    sudo dnf install -y matugen 2>/dev/null || true
fi

# Enable Flatpak + Flathub (may not be pre-configured on some Fedora spins)
if command -v flatpak &>/dev/null; then
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo 2>/dev/null || true
    echo -e "${GREEN}  Flatpak + Flathub configured${RESET}"
fi

echo -e "${GREEN}  Core packages done${RESET}"

# ── Optional apps (prompted individually) ────────────────────────────────────
echo ""
echo -e "${CYAN}━━━ Optional App Installs ━━━${RESET}"
echo -e "${YELLOW}  Answer y/N for each app you want installed.${RESET}"
echo ""

# ── Mullvad VPN ───────────────────────────────────────────────────────────────
if ask "Install Mullvad VPN?"; then
    echo -e "${CYAN}  Adding Mullvad repository...${RESET}"
    sudo dnf config-manager addrepo \
        --from-repofile=https://repository.mullvad.net/rpm/stable/mullvad.repo 2>/dev/null || \
    sudo dnf config-manager \
        --add-repo https://repository.mullvad.net/rpm/stable/mullvad.repo 2>/dev/null || true
    echo -e "${CYAN}  Installing mullvad-vpn...${RESET}"
    sudo dnf install -y mullvad-vpn
    echo -e "${GREEN}  Mullvad VPN installed${RESET}"
fi

# ── Mullvad Browser ───────────────────────────────────────────────────────────
if ask "Install Mullvad Browser?"; then
    echo -e "${CYAN}  Adding Mullvad repository (if not already added)...${RESET}"
    sudo dnf config-manager addrepo \
        --from-repofile=https://repository.mullvad.net/rpm/stable/mullvad.repo 2>/dev/null || \
    sudo dnf config-manager \
        --add-repo https://repository.mullvad.net/rpm/stable/mullvad.repo 2>/dev/null || true
    echo -e "${CYAN}  Installing mullvad-browser...${RESET}"
    sudo dnf install -y mullvad-browser
    echo -e "${GREEN}  Mullvad Browser installed${RESET}"
fi

# ── Discord + Vencord ─────────────────────────────────────────────────────────
if ask "Install Discord + Vencord (mod client)?"; then
    if ! command -v flatpak &>/dev/null; then
        echo -e "${RED}  Flatpak is not installed. Skipping Discord + Vencord.${RESET}"
    else
        echo -e "${CYAN}  Installing Discord via Flatpak...${RESET}"
        flatpak install -y flathub com.discordapp.Discord
        echo -e "${GREEN}  Discord installed${RESET}"

        echo -e "${CYAN}  Installing Vencord...${RESET}"
        # Download the official Vencord CLI installer to a user-owned temp file.
        # We avoid /tmp here because some setups mount it noexec.
        VENCORD_TMP="$(mktemp --tmpdir="$HOME")"
        curl -sSL \
            https://github.com/Vendicated/VencordInstaller/releases/latest/download/VencordInstallerCli-Linux \
            --output "$VENCORD_TMP" \
            --location \
            --fail
        chmod +x "$VENCORD_TMP"

        # The installer needs to know where the Flatpak Discord data lives.
        # Flatpak apps store their data under ~/.var/app/<id>, which is owned
        # by the real user — not root. We pass these vars explicitly so the
        # installer finds com.discordapp.Discord even when run elevated.
        REAL_HOME="$HOME"
        REAL_XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
        REAL_XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
        REAL_USER="$(whoami)"

        ELEVATED=false
        for elevate in sudo doas run0 pkexec; do
            if command -v "$elevate" &>/dev/null; then
                "$elevate" env \
                    "HOME=$REAL_HOME" \
                    "XDG_DATA_HOME=$REAL_XDG_DATA_HOME" \
                    "XDG_CONFIG_HOME=$REAL_XDG_CONFIG_HOME" \
                    "SUDO_USER=$REAL_USER" \
                    "$VENCORD_TMP"
                ELEVATED=true
                break
            fi
        done

        rm -f "$VENCORD_TMP"

        if [ "$ELEVATED" = false ]; then
            echo -e "${RED}  Could not find sudo/doas/run0/pkexec. Vencord install skipped.${RESET}"
        else
            echo -e "${GREEN}  Vencord installed${RESET}"
        fi
    fi
fi

# ── Telegram ──────────────────────────────────────────────────────────────────
if ask "Install Telegram Desktop?"; then
    if ! command -v flatpak &>/dev/null; then
        echo -e "${RED}  Flatpak is not installed. Skipping Telegram.${RESET}"
    else
        echo -e "${CYAN}  Installing Telegram via Flatpak...${RESET}"
        flatpak install -y flathub org.telegram.desktop
        echo -e "${GREEN}  Telegram installed${RESET}"
    fi
fi

# ── Zed Editor ────────────────────────────────────────────────────────────────
if ask "Install Zed editor?"; then
    echo -e "${CYAN}  Installing Zed...${RESET}"
    curl -sSf https://zed.dev/install.sh | sh
    # Ensure ~/.local/bin is on PATH in .zshrc (idempotent)
    if ! grep -q 'HOME/.local/bin' "$HOME/.zshrc" 2>/dev/null; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc"
    fi
    echo -e "${GREEN}  Zed installed — run with: zed${RESET}"
fi

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${GREEN}  Custom dotfiles applied successfully!${RESET}"
echo ""
echo -e "${YELLOW}  Other optional installs you can do manually:${RESET}"
echo "   Zen Browser:  flatpak install flathub app.zen_browser.zen"
echo "   Spotify:      flatpak install flathub com.spotify.Client"
echo "   Spicetify:    curl -fsSL https://raw.githubusercontent.com/spicetify/cli/main/install.sh | sh"
echo ""
echo -e "${YELLOW}  Reboot your system to complete setup.${RESET}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
