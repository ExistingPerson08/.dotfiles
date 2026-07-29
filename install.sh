#!/bin/bash

set -e

REPO_URL="https://github.com/ExistingPerson08/.dotfiles.git"
CLONE_DIR="/tmp/dotfiles-install"

APP_CONFIG_DIR="$HOME/.var/app"
WALLPAPERS_DIR="$XDG_PICTURES_DIR/Wallpapers"

xdg-user-dirs-update
source "$HOME/.config/user-dirs.dirs"

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
XDG_DOCUMENTS_DIR="${XDG_DOCUMENTS_DIR:-$HOME/Documents}"
XDG_PICTURES_DIR="${XDG_PICTURES_DIR:-$HOME/Pictures}"
XDG_TEMPLATES_DIR="${XDG_TEMPLATES_DIR:-$HOME/Templates}"
XDG_DOWNLOAD_DIR="${XDG_DOWNLOAD_DIR:-$HOME/Downloads}"
XDG_MUSIC_DIR="${XDG_MUSIC_DIR:-$HOME/Music}"
XDG_VIDEOS_DIR="${XDG_VIDEOS_DIR:-$HOME/Videos}"
XDG_PUBLICSHARE_DIR="${XDG_PUBLICSHARE_DIR:-$HOME/Public}"
XDG_DESKTOP_DIR="${XDG_DESKTOP_DIR:-$HOME/Desktop}"

echo "=========================================="
echo "      EXISTING PERSONS's .DOTFILES   "
echo "=========================================="

echo ""
echo "⚠️  This will overwrite your configs and home folder."
read -p "Do you want to continue? (y/n): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Installation canceled."
    exit 1
fi

echo ""
echo "-- CLONING REPOSITORY --"
echo ""

rm -rf "$CLONE_DIR"
git clone "$REPO_URL" "$CLONE_DIR"

echo ""
echo "-- INSTALLING HOMEBREW --"
echo ""

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" 2>/dev/null || eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null

echo "-> Installing homebrew packages..."
xargs -a "$CLONE_DIR/brew.list" brew install

echo ""
echo "-- INSTALLING FLATPAKS --"
echo ""

flatpak remote-add --if-not-exists --system flathub https://dl.flathub.org/repo/flathub.flatpakrepo
xargs -a "$CLONE_DIR/flatpaks.list" flatpak install --system -y

echo ""
echo "-- INSTALLING PACKAGES --"
echo ""

xargs -a "$CLONE_DIR/packages.list" sudo rakuos install -y

sudo rakuos setup-gaming

echo ""
echo "-- INSTALLING FONTS --"
echo ""

mkdir -p ~/.local/share/fonts
curl -L "https://github.com/IdreesInc/Monocraft/releases/download/v4.2.1/Monocraft.ttc" -o "$HOME/.local/share/fonts/Monocraft.ttc"
fc-cache -fv

echo ""
echo "-- SETTING UP FOLDERS --"
echo ""

TEMP_DIR="$XDG_TEMPLATES_DIR"
DOCS_DIR="${XDG_DOCUMENTS_DIR}"
SRC_DIR="$CLONE_DIR/templates"
cp -rv "$SRC_DIR"/* "$TEMP_DIR/"

mkdir -p "$APP_CONFIG_DIR"
mkdir -p "$WALLPAPERS_DIR"
mkdir $HOME/Screenshots
mkdir -p $HOME/Applications/Games
mkdir $XDG_DOCUMENTS_DIR/code
mkdir $XDG_DOCUMENTS_DIR/quickemu
mkdir $XDG_DOCUMENTS_DIR/notes

echo "-> Setting nautilus bookmarks"

CODE="$(eval echo "$DOCS_DIR")/code"
NOTES="$(eval echo "$DOCS_DIR")/notes"
mkdir -p ~/.config/gtk-3.0
echo "file://$CODE Code" >> ~/.config/gtk-3.0/bookmarks
echo "file://$NOTES Notes" >> ~/.config/gtk-3.0/bookmarks

echo ""
echo "-- SETTING UP DOTFILES --"
echo ""

# .config
if [ -d "$CLONE_DIR/config" ]; then
    echo "-> Copiing configurations to $XDG_CONFIG_HOME"
    cp -rf "$CLONE_DIR/config"/. "$XDG_CONFIG_HOME/"
fi

# .local
if [ -d "$CLONE_DIR/local" ]; then
    echo "-> Copiing data to ~/.local"
    cp -rf "$CLONE_DIR/local"/. "$HOME/.local/"
fi

# app_config -> ~/var/app
if [ -d "$CLONE_DIR/app_config" ]; then
    echo "-> Copiing app config to $APP_CONFIG_DIR"
    cp -rf "$CLONE_DIR/app_config"/. "$APP_CONFIG_DIR/"
fi

# wallpapers -> Picture/wallpapers
if [ -d "$CLONE_DIR/wallpapers" ]; then
    echo "Copiing wallpapers to $WALLPAPERS_DIR"
    cp -rf "$CLONE_DIR/wallpapers"/. "$WALLPAPERS_DIR/"
fi

# templates -> XDG Templates
if [ -d "$CLONE_DIR/templates" ]; then
    echo "-> Copiing templates to $XDG_TEMPLATES_DIR"
    cp -rf "$CLONE_DIR/templates"/. "$XDG_TEMPLATES_DIR/"
fi

echo ""
echo "-- FINISH! --"
echo ""
