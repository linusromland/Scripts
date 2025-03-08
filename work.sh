#!/bin/bash

# Script to manage the VPN connection and remote desktop session required for remote work. 

VPN_CONFIG="/home/linusromland/.ovpn/surikat-vpn.ovpn"
RDP_PASSWORD_FILE="/home/linusromland/.rdp/work_rdp_password.txt"

is_vpn_connected() {
    openvpn3 session-list | grep -q "surikat-vpn"
}

vpn_connect() {
    if is_vpn_connected; then
        echo "VPN is already connected!"
    else
        echo "Starting VPN..."
        openvpn3 session-start --config "$VPN_CONFIG" && echo "VPN started."
    fi
}

vpn_disconnect() {
    if ! is_vpn_connected; then
        echo "VPN is not connected!"
    else
        echo "Disconnecting VPN..."
        openvpn3 session-manage --disconnect --config "$VPN_CONFIG" && echo "VPN disconnected."
    fi
}

vpn_status() {
    if is_vpn_connected; then
        echo "VPN is connected."

        public_ip=$(curl -s https://ipinfo.io/ip)
        echo "Public IP: $public_ip"
    else
        echo "VPN is not connected."
    fi
}

start_remote() {
    if ! is_vpn_connected; then
        echo "VPN must be connected before starting the remote session."
        exit 1
    fi

    echo "Starting remote desktop..."
    xfreerdp /v:192.168.11.69 /u:linusromland /p:$(cat "$RDP_PASSWORD_FILE") /f +clipboard /d:"" && echo "Remote desktop started."
}

case "$1" in
    vpn)
        case "$2" in
            connect)
                vpn_connect
                ;;
            disconnect)
                vpn_disconnect
                ;;
            status)
                vpn_status
                ;;
            *)
                echo "Usage: $0 vpn {start|disconnect|status}"
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
