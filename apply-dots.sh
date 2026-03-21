#!/bin/bash
# ╔══════════════════════════════════════════════════════════════╗
# ║          APPLY CUSTOM DOTFILES                              ║
# ║  Run this AFTER the KooL Fedora-Hyprland installer.        ║
# ║  Overlays the custom z.hyprdots on top.                    ║
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
RESET="\e[0m"

echo -e "${CYAN}━━━ Applying Custom Dotfiles ━━━${RESET}"
echo ""

# ── Backup existing configs ───────────────────────────────────────────────────
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
echo -e "${YELLOW}📦 Backing up existing configs to $BACKUP_DIR ...${RESET}"
mkdir -p "$BACKUP_DIR"
[ -d "$HOME/.config/hypr" ]     && cp -r "$HOME/.config/hypr"     "$BACKUP_DIR/"
[ -d "$HOME/.config/waybar" ]   && cp -r "$HOME/.config/waybar"   "$BACKUP_DIR/"
[ -d "$HOME/.config/kitty" ]    && cp -r "$HOME/.config/kitty"    "$BACKUP_DIR/"
[ -d "$HOME/.config/rofi" ]     && cp -r "$HOME/.config/rofi"     "$BACKUP_DIR/"
[ -d "$HOME/.config/swaync" ]   && cp -r "$HOME/.config/swaync"   "$BACKUP_DIR/"
[ -f "$HOME/.zshrc" ]           && cp "$HOME/.zshrc"              "$BACKUP_DIR/.zshrc"
echo -e "${GREEN}✔ Backup done at: $BACKUP_DIR${RESET}"
echo ""

# ── Copy dotfiles ─────────────────────────────────────────────────────────────
echo -e "${CYAN}📁 Copying config files...${RESET}"
cp -r "$DOTFILES_DIR/.config/"* "$HOME/.config/"
echo -e "${GREEN}✔ ~/.config files copied${RESET}"

echo -e "${CYAN}📁 Copying .zshrc ...${RESET}"
cp "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
echo -e "${GREEN}✔ ~/.zshrc copied${RESET}"

echo -e "${CYAN}📁 Copying .scripts ...${RESET}"
mkdir -p "$HOME/.scripts"
cp -r "$DOTFILES_DIR/.scripts/"* "$HOME/.scripts/"
echo -e "${GREEN}✔ ~/.scripts copied${RESET}"

echo -e "${CYAN}📁 Copying Wallpapers ...${RESET}"
mkdir -p "$HOME/Wallpapers"
cp -r "$DOTFILES_DIR/Wallpapers/"* "$HOME/Wallpapers/"
echo -e "${GREEN}✔ ~/Wallpapers copied${RESET}"

# ── Fix symlinks (current_animations.conf) ────────────────────────────────────
ANIM_DIR="$HOME/.config/hypr/configs/animations"
echo -e "${CYAN}🔗 Fixing animation symlink...${RESET}"
if [ -d "$ANIM_DIR" ]; then
    # Remove the broken symlink (pointed to old /home/zusqii path)
    rm -f "$ANIM_DIR/current_animations.conf"
    # Point it to Horizontal-Quick by default
    ln -sf "$ANIM_DIR/Horizontal-Quick.conf" "$ANIM_DIR/current_animations.conf"
    echo -e "${GREEN}✔ current_animations.conf symlink fixed -> Horizontal-Quick.conf${RESET}"
fi

# ── Make all scripts executable ───────────────────────────────────────────────
echo -e "${CYAN}🔐 Making all scripts executable...${RESET}"
find "$HOME/.config" -name "*.sh" -exec chmod +x {} \;
find "$HOME/.scripts" -name "*.sh" -exec chmod +x {} \;
echo -e "${GREEN}✔ Scripts are now executable${RESET}"

# ── Install extra packages not covered by KooL installer ─────────────────────
echo ""
echo -e "${CYAN}📦 Installing extra packages (ncmpcpp, mpd, flatpak apps)...${RESET}"
sudo dnf install -y ncmpcpp mpd mpd-mpris grim slurp wl-clipboard 2>/dev/null || true

# Enable Flatpak (usually already done on Fedora but just in case)
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo 2>/dev/null || true

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${GREEN}✅ Custom dotfiles applied successfully!${RESET}"
echo ""
echo -e "${YELLOW}💡 Optional installs:${RESET}"
echo "  - Vesktop (Discord): flatpak install flathub dev.vencord.Vesktop"
echo "  - Zen Browser:       flatpak install flathub app.zen_browser.zen"
echo "  - Spotify:           flatpak install flathub com.spotify.Client"
echo "  - Spicetify:         curl -fsSL https://raw.githubusercontent.com/spicetify/cli/main/install.sh | sh"
echo ""
echo -e "${YELLOW}🔄 Please reboot your system now!${RESET}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
