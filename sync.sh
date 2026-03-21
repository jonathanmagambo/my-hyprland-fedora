#!/usr/bin/env bash
# Syncs your local dotfiles back to this repo.
# Run from wherever you cloned this repo.
# Usage: ./sync.sh

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CONF_DIR="$HOME/.config"

mkdir -p "$REPO_DIR/dotfiles/.config"

items=(cava fastfetch hypr kitty matugen rofi swaync waybar wayclick wlogout)

echo "Syncing configs..."
for item in "${items[@]}"; do
    if [ -d "$CONF_DIR/$item" ]; then
        cp -r "$CONF_DIR/$item" "$REPO_DIR/dotfiles/.config/"
        echo "✅ Synced $item"
    else
        echo "⚠️  Skipping $item (not found in ~/.config)"
    fi
done

# Sync dotfiles
cp "$HOME/.zshrc" "$REPO_DIR/dotfiles/"
echo "✅ Synced .zshrc"

cp -r "$HOME/.scripts/" "$REPO_DIR/dotfiles/.scripts/"
echo "✅ Synced .scripts"

cp -r "$HOME/.themes/" "$REPO_DIR/dotfiles/.themes/"
echo "✅ Synced .themes"

# Sync wallpapers (prefer ~/Wallpapers, fallback to ~/Pictures/Wallpapers)
if [ -d "$HOME/Wallpapers" ]; then
    cp -r "$HOME/Wallpapers/" "$REPO_DIR/dotfiles/Wallpapers/"
    echo "✅ Synced Wallpapers"
elif [ -d "$HOME/Pictures/Wallpapers" ]; then
    cp -r "$HOME/Pictures/Wallpapers/" "$REPO_DIR/dotfiles/Wallpapers/"
    echo "✅ Synced Wallpapers (from Pictures)"
fi

cd "$REPO_DIR" || exit

git add .

if git diff-index --quiet HEAD --; then
    echo "✨ No changes to push."
else
    git commit -m "Update dots: $(date +'%Y-%m-%d %H:%M')"
    git push origin main
    echo "🎉 Pushed to GitHub!"
fi
