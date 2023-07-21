#!/bin/bash

# Create the check_internet.sh script
cat << 'EOF' > /usr/local/bin/check_internet.sh
#!/bin/bash

# Function to ping Google's public DNS
function check_internet() {
    if ping -c 3 8.8.8.8 &> /dev/null
    then
        return 0
    else
        return 1
    fi
}

# Ping Google's public DNS twice, with a 1-minute delay between
check_internet
if [ $? -eq 0 ]
then
    exit 0
fi

sleep 60

check_internet
if [ $? -eq 0 ]
then
    exit 0
fi

# If both sets of pings fail, set up the access point
nmcli dev wifi hotspot ifname wlan0 con-name LicheeRV-AI ssid LicheeRV-AI password mypassword
EOF

# Make the script executable
chmod +x /usr/local/bin/check_internet.sh

# Create the systemd service
cat << 'EOF' > /etc/systemd/system/check_internet.service
[Unit]
Description=Check Internet connectivity and create hotspot if unavailable
After=network.target

[Service]
ExecStart=/usr/local/bin/check_internet.sh
Type=idle
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd, enable and start the service
systemctl daemon-reload
systemctl enable check_internet.service
systemctl start check_internet.service
