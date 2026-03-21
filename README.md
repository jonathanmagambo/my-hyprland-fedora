<div align="center">

# 🌸 Hyprland Fedora Dotfiles

**Custom Hyprland dotfiles for Fedora 41, built on top of [KooL's Fedora-Hyprland](https://github.com/JaKooLit/Fedora-Hyprland) installer.**

</div>

---

## ⚡ Quick Setup (One-Line)

On a fresh **Fedora 41** install, after running `sudo dnf update -y && reboot`:

```bash
git clone https://github.com/YOUR_USERNAME/my-hyprland-fedora.git ~/my-hyprland-fedora
cd ~/my-hyprland-fedora
chmod +x setup.sh
./setup.sh
```

That's it. The script will:
1. Clone + run KooL's Fedora-Hyprland installer (interactive — pick your options)
2. Automatically apply these custom dotfiles on top
3. Fix the animation symlink, make all scripts executable, and install extra packages

---

## 📦 What's Inside

```
my-hyprland-fedora/
├── setup.sh          ← Run this first. Does everything.
├── apply-dots.sh     ← Run this alone if KooL installer already done.
└── dotfiles/
    ├── .zshrc
    ├── .scripts/         ← Theme switcher, wallpaper picker, etc.
    ├── Wallpapers/
    └── .config/
        ├── hypr/         ← Hyprland config (keybinds, animations, look & feel)
        ├── waybar/       ← Multiple bar layouts (Full-Bar, Dock, True.Bar...)
        ├── kitty/        ← Terminal
        ├── rofi/         ← App launcher
        ├── swaync/       ← Notifications
        ├── cava/         ← Music visualizer
        ├── fastfetch/    ← System info (shown on terminal open)
        ├── matugen/      ← Color generation
        └── wlogout/      ← Power menu
```

---

## ⌨️ Key Keybinds

| Keys | Action |
|------|--------|
| `SUPER + Return` | Open terminal (Kitty) |
| `SUPER + SPACE` | App launcher (Rofi) |
| `SUPER + W` | Browser (Firefox — change in `programs.conf`) |
| `SUPER + E` | File manager (Thunar) |
| `SUPER + A` | Messaging app (Vesktop — install via Flatpak) |
| `SUPER + T` | Theme switcher |
| `SUPER + D` | Wallpaper picker |
| `SUPER + H` | Config editor menu |
| `SUPER + L` | Lock screen |
| `SUPER + M` | Logout/power menu |
| `SUPER + Q` | Close window |
| `SUPER + V` | Toggle float |
| `CTRL + S` | Screenshot region → clipboard |
| `ALT + 9` | Toggle Waybar |

---

## 🔧 Customization

### Change your browser
Edit `dotfiles/.config/hypr/configs/programs.conf`:
```bash
$browser = firefox      # change to: zen-browser, chromium, etc.
```

### Change your messaging app
```bash
$message = vesktop      # Flatpak: dev.vencord.Vesktop
```
Install with: `flatpak install flathub dev.vencord.Vesktop`

### Switch Waybar layout
Press `SUPER + H` → select "Waybar" → pick a layout:
- `Full-Bar`
- `Dock`
- `Semi-Minimal`
- `True.Bar`
- `True.Dock`

### Switch animations
Press `SUPER + ALT + A` or press `SUPER + H` → Animations

---

## 📦 Optional Apps (Install Manually)

```bash
# Vesktop (Discord client)
flatpak install flathub dev.vencord.Vesktop

# Zen Browser
flatpak install flathub app.zen_browser.zen

# Spotify
flatpak install flathub com.spotify.Client

# Spicetify (Spotify customization)
curl -fsSL https://raw.githubusercontent.com/spicetify/cli/main/install.sh | sh
```

---

## 🐧 Requirements

- **Fedora 41** (tested; 42/43 should also work)
- Internet connection during setup
- `git` installed: `sudo dnf install -y git`

---

## ✅ What Was Fixed from the Original Dotfiles

| File | Issue | Fix |
|------|-------|-----|
| `.zshrc` | `alias i="sudo pacman -S"` | Changed to `dnf install -y` |
| `.zshrc` | `alias ls="exa -l"` | Changed to `lsd -l` (Fedora installer uses lsd) |
| `.zshrc` | Hardcoded `/home/zusqii/.spicetify` | Changed to `$HOME/.spicetify` |
| `programs.conf` | `zen-browser` (not in Fedora repos) | Defaulted to `firefox`, added Flatpak note |
| `keybinds.conf` | `~/user_scripts/wayclick/...` path (broken) | Commented out, enable manually |
| `keybinds.conf` | `.scripts/toggle.blur.sh` (missing `~/`) | Fixed to `~/.scripts/toggle.blur.sh` |
| `configs.sh` | `codium` (not installed by default) | Changed to `xdg-open` (system default editor) |
| `current_animations.conf` | Broken symlink to `/home/zusqii/` | `apply-dots.sh` recreates it correctly |
