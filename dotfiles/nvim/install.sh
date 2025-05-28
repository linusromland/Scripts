#!/bin/bash

SOURCE_DIR="$(pwd)"
TARGET_DIR="$HOME/.config/nvim"

ln -s "$SOURCE_DIR" "$TARGET_DIR"

echo "Neovim config linked: $TARGET_DIR -> $SOURCE_DIR"
