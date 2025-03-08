#!/bin/bash

# Script to manage the VPN connection and remote desktop session required for remote work.

decrypt_rdp_password() {
    RDP_PASSWORD=$(pass surikat/rdp/password)
}

decrypt_vpn_credentials() {
    VPN_USERNAME=$(pass surikat/vpn/username)
    VPN_PASSWORD=$(pass surikat/vpn/password)
}

VPN_CONFIG_FILE="/home/linusromland/.ovpn/surikat-vpn.ovpn"

is_vpn_connected() {
    openvpn3 session-stats --config "$VPN_CONFIG_FILE" 2>&1 | grep -qv "No sessions started"
}

connect_vpn() {
    if is_vpn_connected; then
        echo "VPN is already connected!"
    else
        echo "Starting VPN..."
        decrypt_vpn_credentials
        printf "%sn%sn" "$VPN_USERNAME" "$VPN_PASSWORD" | openvpn3 session-start --config "$VPN_CONFIG_FILE" && echo "VPN started."
    fi
}

disconnect_vpn() {
    if ! is_vpn_connected; then
        echo "VPN is not connected!"
    else
        echo "Disconnecting VPN..."
        openvpn3 session-manage --disconnect --config "$VPN_CONFIG_FILE" && echo "VPN disconnected."
    fi
}

vpn_status() {
    if is_vpn_connected; then
        echo "VPN is connected."
    else
        echo "VPN is NOT connected."
    fi

    public_ip=$(curl -s https://ipinfo.io/ip)
    echo "Public IP: $public_ip"
}

start_remote() {
    if ! is_vpn_connected; then
        echo "VPN must be connected before starting the remote session."
        exit 1
    fi
    echo "Starting remote desktop..."
    decrypt_rdp_password
    xfreerdp /v:192.168.11.69 /u:linusromland /p:"$RDP_PASSWORD" /f clipboard /d:"" && echo "Remote desktop started."
}

case "$1" in
vpn)
    case "$2" in
    connect)
        connect_vpn
        ;;
    disconnect)
        disconnect_vpn
        ;;
    status)
        vpn_status
        ;;
    *)
        echo "Usage: $0 vpn {connect|disconnect|status}"
        exit 1
        ;;
    esac
    ;;
remote)
    start_remote
    ;;
*)
    echo "Usage: $0 {vpn|remote}"
    exit 1
    ;;
esac
