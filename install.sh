#!/bin/bash

set -e

REPO_URL="https://github.com/ExistingPerson08/.dotfiles.git"
CLONE_DIR="/tmp/dotfiles-install"

APP_CONFIG_DIR="$HOME/.var/app"
WALLPAPERS_DIR="$XDG_PICTURES_DIR/Wallpapers"

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

FD_FILE="/tmp/firedragon.flatpak"
curl -L  "https://gitlab.com/garuda-linux/firedragon/firedragon13/-/releases/v13.0.0/downloads/firedragon-catppuccin.flatpak-x64.flatpak" -o "$FD_FILE"
flatpak install -y --system "$FD_FILE"

echo ""
echo "-- INSTALLING PACKAGES --"
echo ""

xargs -a "$CLONE_DIR/packages.list" sudo rakuos install -y

sudo rakuos setup-gaming

echo ""
echo "-- SETTING UP FOLDERS --"
echo ""

TEMP_DIR="$XDG_TEMPLATES_DIR"
DOCS_DIR="${XDG_DOCUMENTS_DIR}"
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
