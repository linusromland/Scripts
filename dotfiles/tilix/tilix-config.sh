#!/bin/bash

TILIX_CONFIG="$(pwd)/tilix-config.dconf"

function export_tilix_config {
    echo "Exporting Tilix configuration..."
    dconf dump /com/gexperts/Tilix/ > "$TILIX_CONFIG"
    echo "Tilix configuration saved to $TILIX_CONFIG"
}

function import_tilix_config {
    if [ -f "$TILIX_CONFIG" ]; then
        echo "Importing Tilix configuration..."
        dconf load /com/gexperts/Tilix/ < "$TILIX_CONFIG"
        echo "Tilix configuration loaded."
    else
        echo "No Tilix configuration found at $TILIX_CONFIG"
    fi
}

case "$1" in
    export)
        export_tilix_config
        ;;
    import)
        import_tilix_config
        ;;
    *)
        echo "Usage: $0 {export|import}"
        exit 1
        ;;
esac
