#!/bin/bash

# Use root user
[ "$UID" -eq 0 ] || exec sudo bash "$0" "$@"

# Install iptables if not installed
if [ $(dpkg-query -W -f='${Status}' iptables 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  apt-get install iptables -y;
fi

# Delete all existing rules
iptables -F

# Set default chain policies
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP

# Get default interface
INTERFACE=$(route | grep '^default' | grep -o '[^ ]*$')

# Allow outgoing HTTPS
iptables -A OUTPUT -o $INTERFACE -p tcp --dport 443 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -i $INTERFACE -p tcp --sport 443 -m state --state ESTABLISHED -j ACCEPT

# Allow outbound DNS
iptables -A OUTPUT -p udp -o $INTERFACE --dport 53 -j ACCEPT
iptables -A INPUT -p udp -i $INTERFACE --sport 53 -j ACCEPT
