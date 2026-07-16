#!/bin/bash

# Setup git clone to tmp folder
SRC_DIR="/usr/share/spacefin/templates/"
WORK_DIR="./"

echo ""
echo "-- INSTALLING HOMEBREW --"
echo ""
# Not complete! (like everything else)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo ""
echo "-- INSTALLING FLATPAKS --"
echo ""

flatpak remote-add --if-not-exists --system flathub https://dl.flathub.org/repo/flathub.flatpakrepo
xargs -a $WORK_DIR/flatpaks-recommended.list flatpak install --system -y

echo ""
echo "-- SETTING UP FOLDERS --"
echo ""

TEMP_DIR="$XDG_TEMPLATES_DIR"
DOCS_DIR="${XDG_DOCUMENTS_DIR}"
cp -rv "$SRC_DIR"/* "$TEMP_DIR/"

mkdir $HOME/Screenshots
mkdir $HOME/Applications
mkdir $HOME/Applications/Games
mkdir $XDG_DOCUMENTS_DIR/code
mkdir $XDG_DOCUMENTS_DIR/quickemu
mkdir $XDG_DOCUMENTS_DIR/notes

CODE="$(eval echo "$DOCS_DIR")/code"
NOTES="$(eval echo "$DOCS_DIR")/notes"
mkdir -p ~/.config/gtk-3.0
echo "file://$CODE Code" >> ~/.config/gtk-3.0/bookmarks
echo "file://$NOTES Notes" >> ~/.config/gtk-3.0/bookmarks
