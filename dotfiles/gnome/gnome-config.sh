#!/bin/bash

GNOME_CONFIG_DIR="$(pwd)/gnome-settings"

# Directories to include (explicitly excluding monitor settings)
INCLUDE_KEYS=(
    "/org/gnome/desktop/"
    "/org/gnome/shell/"
    "/org/gnome/settings-daemon/plugins/media-keys/"
    "/org/gnome/desktop/wm/keybindings/"
)

function export_gnome_config {
    echo "Exporting GNOME settings..."
    mkdir -p "$GNOME_CONFIG_DIR"

    for key in "${INCLUDE_KEYS[@]}"; do
        key_name=$(echo "$key" | tr '/' '_')  # Replace slashes with underscores for filename
        file="$GNOME_CONFIG_DIR/$key_name.dconf"

        echo "Saving $key to $file..."
        dconf dump "$key" > "$file"
    done

    echo "GNOME settings saved in $GNOME_CONFIG_DIR"
}

function import_gnome_config {
    if [ -d "$GNOME_CONFIG_DIR" ]; then
        echo "Importing GNOME settings..."
        for file in "$GNOME_CONFIG_DIR"/*.dconf; do
            if [ -f "$file" ]; then
                key=$(basename "$file" .dconf | tr '_' '/')  # Convert filename back to dconf path
                echo "Loading $file into $key..."
                dconf load "$key" < "$file"
            fi
        done
        echo "GNOME settings loaded."
    else
        echo "No GNOME configuration found in $GNOME_CONFIG_DIR"
    fi
}

case "$1" in
    export)
        export_gnome_config
        ;;
    import)
        import_gnome_config
        ;;
    *)
        echo "Usage: $0 {export|import}"
        exit 1
        ;;
esac
