<div align="center">

# Hyprland Fedora Dotfiles

**Custom Hyprland dotfiles for Fedora 41+, built on top of [KooL's Fedora-Hyprland](https://github.com/JaKooLit/Fedora-Hyprland) installer.**

</div>

---

## Quick Setup

On a fresh **Fedora 41+** install, after running `sudo dnf update -y && reboot`:

```bash
git clone https://github.com/jonathanmagambo/my-hyprland-fedora.git ~/my-hyprland-fedora
cd ~/my-hyprland-fedora
chmod +x setup.sh
./setup.sh
```

The script will:

1. Clone and run KooL's Fedora-Hyprland installer (interactive — pick your options)
2. Automatically apply these custom dotfiles on top
3. Fix the animation symlink, make all scripts executable, and install extra packages

---

## What's Inside

```
my-hyprland-fedora/
├── setup.sh          <- Run this first. Does everything.
├── apply-dots.sh     <- Run this alone if the KooL installer is already done.
└── dotfiles/
    ├── .zshrc
    ├── .scripts/         <- Theme switcher, wallpaper picker, etc.
    ├── Wallpapers/
    └── .config/
        ├── hypr/         <- Hyprland config (keybinds, animations, look & feel)
        ├── waybar/       <- Multiple bar layouts (Full-Bar, Dock, True.Bar...)
        ├── kitty/        <- Terminal
        ├── rofi/         <- App launcher
        ├── swaync/       <- Notifications
        ├── cava/         <- Music visualizer
        ├── fastfetch/    <- System info (shown on terminal open)
        ├── matugen/      <- Color generation
        └── wlogout/      <- Power menu
```

---

## Key Keybinds

| Keys | Action |
|------|--------|
| `SUPER + Return` | Open terminal (Kitty) |
| `SUPER + SPACE` | App launcher (Rofi) |
| `SUPER + W` | Browser (Mullvad Browser) |
| `SUPER + E` | File manager (Dolphin) |
| `SUPER + A` | Discord (with Vencord) |
| `SUPER + G` | Telegram |
| `SUPER + Z` | Zed editor |
| `SUPER + T` | Theme switcher |
| `SUPER + D` | Wallpaper picker |
| `SUPER + H` | Config editor menu |
| `SUPER + L` | Lock screen |
| `SUPER + M` | Logout/power menu |
| `SUPER + Q` | Close window |
| `SUPER + V` | Toggle float |
| `CTRL + S` | Screenshot region to clipboard |
| `ALT + 9` | Toggle Waybar |

---

## Customization

### Change your browser

Mullvad Browser is set as the default. To switch, edit `dotfiles/.config/hypr/configs/programs.conf`:

```bash
$browser = mullvad-browser    # change to: firefox, zen-browser, chromium, etc.
```

### Change your messaging app

```bash
$message = flatpak run com.discordapp.Discord
```

Discord + Vencord is the default. Change to any other app if preferred.

### Switch Waybar layout

Press `SUPER + H` and select "Waybar", then pick a layout:

- `Full-Bar`
- `Dock`
- `Semi-Minimal`
- `True.Bar`
- `True.Dock`

### Switch animations

Press `SUPER + ALT + A` or press `SUPER + H` and select "Animations".

---

## Optional Apps

When you run `apply-dots.sh`, it will prompt you individually for each of the following apps before installing anything:

| App | Method |
|-----|--------|
| Mullvad VPN | Official RPM repo |
| Mullvad Browser | Official RPM repo |
| Discord + Vencord | Discord via Flatpak, then Vencord CLI installer |
| Telegram Desktop | Flatpak |
| Zed Editor | Official install script (`~/.local/bin/zed`) |

Just answer `y` or `N` at each prompt — skipping any you don't want.

Anything not listed above can be installed manually:

```bash
# Zen Browser
flatpak install flathub app.zen_browser.zen

# Spotify
flatpak install flathub com.spotify.Client

# Spicetify (Spotify customization)
curl -fsSL https://raw.githubusercontent.com/spicetify/cli/main/install.sh | sh
```

---

## Requirements

- **Fedora 41+**
- Internet connection during setup
- `git` (auto-installed by `setup.sh` if missing)

---

## Fixes Applied from the Original Dotfiles

| File | Issue | Fix |
|------|-------|-----|
| `.zshrc` | `alias i="sudo pacman -S"` | Changed to `dnf install -y` |
| `.zshrc` | `alias ls="exa -l"` | Changed to `lsd -l` (Fedora installer uses lsd) |
| `.zshrc` | Hardcoded `/home/zusqii/.spicetify` | Changed to `$HOME/.spicetify` |
| `programs.conf` | `zen-browser` (not in Fedora repos) | Defaulted to `mullvad-browser`, installed via apply-dots.sh |
| `keybinds.conf` | `~/user_scripts/wayclick/...` path (broken) | Commented out; enable manually |
| `keybinds.conf` | `.scripts/toggle.blur.sh` (missing `~/`) | Fixed to `~/.scripts/toggle.blur.sh` |
| `configs.sh` | `codium` (not installed by default) | Changed to `xdg-open` (system default editor) |
| `current_animations.conf` | Broken symlink to `/home/zusqii/` | `apply-dots.sh` recreates it correctly |
