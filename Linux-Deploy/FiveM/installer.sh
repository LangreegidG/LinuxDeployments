#!/usr/bin/env bash

# Define Variables
echo "Defining Variables"
FIVEM_DOWNLOAD_URL="https://runtime.fivem.net/artifacts/fivem/build_proot_linux/master/"
TS3_DOWNLOAD_URL="https://files.teamspeak-services.com/releases/server/3.13.7/teamspeak3-server_linux_amd64-3.13.7.tar.bz2"
TS3_SERVER_DIR="/deploy/teamspeak3-server_linux_amd64"
TS3_START_SCRIPT="$TS3_SERVER_DIR/ts3server_startscript.sh"
TS3_USER="teamspeak"
SERVER_HOSTING_COMPANY="That One Host LLC"

# Choose & Display ASCII Banner
echo "Check Server Hosting Company"
if [[ $SERVER_HOSTING_COMPANY == "That One Host LLC" ]]; 
	    then
            
            echo '  ________          __     ____                __  __           __     __    __    ______';
            echo ' /_  __/ /_  ____ _/ /_   / __ \____  ___     / / / /___  _____/ /_   / /   / /   / ____/';
            echo '  / / / __ \/ __ \`/ __/  / / / / __ \/ _ \   / /_/ / __ \/ ___/ __/  / /   / /   / /     ';
            echo ' / / / / / / /_/ / /_   / /_/ / / / /  __/  / __  / /_/ (__  ) /_   / /___/ /___/ /___   ';
            echo '/_/ /_/ /_/\__,_/\__/   \____/_/ /_/\___/  /_/ /_/\____/____/\__/  /_____/_____/\____/   ';
            echo '                                                                                         ';

    elif
        [[ $SERVER_HOSTING_COMPANY == "Four Seasons Hosting" ]]; then
            
            echo '    ______                    _____                                     __  __           __  _            ';
            echo '   / ____/___  __  _______   / ___/___  ____ __________  ____  _____   / / / /___  _____/ /_(_)___  ____ _';
            echo '  / /_  / __ \/ / / / ___/   \__ \/ _ \/ __ \`/ ___/ __ \/ __ \/ ___/  / /_/ / __ \/ ___/ __/ / __ \/ __ \`/';
            echo ' / __/ / /_/ / /_/ / /      ___/ /  __/ /_/ (__  ) /_/ / / / (__  )  / __  / /_/ (__  ) /_/ / / / / /_/ / ';
            echo '/_/    \____/\__,_/_/      /____/\___/\__,_/____/\____/_/ /_/____/  /_/ /_/\____/____/\__/_/_/ /_/\__, /  ';
            echo '                                                                                                 /____/   ';

    else
        echo 'Your installation package has not been authorized. The installer will now exit, goodbye.'
        exit

fi


# Display some text to the user
echo "Welcome to $SERVER_HOSTING_COMPANY. By executing this script, you will start an installation package that will install Node JS, a FiveM Server, and a Teamspeak server on your system. Please make sure you have the necessary permissions to install these packages before proceeding.

Please note that executing this script may result in the loss of data or cause damage to your system. We are not responsible for any such loss or damage. It is highly recommended that you back up any important data before running this script.

If you are ready to proceed, please run the script and follow the prompts. If you have any questions or concerns, please do not hesitate to contact us.

Thank you for choosing our services!"
echo "Press CTRL+C to cancel installation."
echo "Press any key to confirm that you agree to these terms & conditions &  that you are ready to move forward with the install..."

# Wait for the user to press a key
read -n1 -r -p "" key

# Create Root Deploy Directory
echo "Attemping to create install directory - /deploy"
mkdir -p /deploy
cd /deploy

# Create FiveM Download Directory
echo "Creating FiveM Download Directory"
mkdir -p /fivem
cd /fivem

# Download Latest Fivem Artifacts
echo "Attempting to find latest FiveM Artifacts"
LATEST_BUILD=$(curl -s "${FIVEM_DOWNLOAD_URL}" | grep -o 'fx.*\.tar\.xz' | sort | tail -n1)
curl -s "${FIVEM_DOWNLOAD_URL}${LATEST_BUILD}" -o "${LATEST_BUILD}"

#Extract the FiveM Artifacts
echo "Extracting FiveM Server Artifacts"
tar -xf "${LATEST_BUILD}"

# Create a new user for the Teamspeak server
echo "Creating user for Teamspeak Server"
sudo useradd -m -U -r -s /bin/false "$TS3_USER"

# Download Latest TS3 Server
echo "Downloading Latest Teamspeak Server"
wget "$TS3_DOWNLOAD_URL" -P "/deploy"

# Extract Teamspeak Server Files
echo "Extracting Teamspeak Server Files"
tar -xvjf "/deploy/$(basename "$TS3_DOWNLOAD_URL")" -C "/deploy"

# Move Server Files to the TS3 Install Directory
echo "Moving Teamspeak Server Files to Install Directory"
sudo mv "/deploy/$(basename "$TS3_DOWNLOAD_URL" .tar.bz2)" "$TS3_SERVER_DIR"

# Define Folder Ownership
echo "Defining Folder Ownership"
sudo chown -R "$TS3_USER:$TS3_USER" "$TS3_SERVER_DIR"

# Download and install the latest version of Node.JS and NPM
echo "Downloading Node JS & NPM"
curl -sL https://deb.nodesource.com/setup_16.x | sudo -E bash -
sudo apt-get install -y nodejs
echo "Displaying Node JS & NPM Version"
echo "Node.js version: $(node -v)"
echo "NPM version: $(npm -v)"

# Check if UFW is installed
echo "Checking if UFW is installed"
if [ -x "$(command -v ufw)" ]; then
    echo "UFW is installed"
else
    echo "UFW is not installed"
    sudo apt install ufw
fi

# Allow Firewall Ports
echo "Starting Firewall Configuration"
sudo ufw allow 30120 #FiveM
sudo ufw allow 9987 #Teamspeak - Voice
sudo ufw allow 30033 #Teamspeak - File Transfer
sudo ufw allow 40120 #FiveM-TXAdmin

# Enabling Firewall
echo "Enabling Firewall"
sudo ufw enable

# Reload Firewall
echo "Reloading Firewall"
sufo ufw reload

# End > Access Downloaded Server Directory
echo "Changing to FiveM Directory"
cd /deploy/fivem/server

# End > Start FiveM Server
echo "Start FiveM Server"
./run.sh +exec server.cfg

# End > Start the Teamspeak Server
cd $TS3_SERVER_DIR
sudo -u "$TS3_USER" "$TS3_START_SCRIPT" start
