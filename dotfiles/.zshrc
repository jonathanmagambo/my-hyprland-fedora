# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Theme
ZSH_THEME="robbyrussell"

# Which plugins would you like to load?
plugins=(
	git 
	zsh-autosuggestions
	zsh-syntax-highlighting
)

# Plugin Edit
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=6'

source $ZSH/oh-my-zsh.sh

# Aliases
alias ls="lsd -l"           # lsd is installed by the Fedora-Hyprland installer
alias music="exec ncmpcpp"
alias exe="sudo chmod +x"
alias i="sudo dnf install -y"   # Fedora uses dnf, not pacman

fastfetch

# Spicetify (uncomment if you install it)
# export PATH=$PATH:$HOME/.spicetify

export PATH="$HOME/.local/bin:$PATH"
