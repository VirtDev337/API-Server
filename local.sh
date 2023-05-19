#!/bin/bash

if (nodejs --verison)
then
    echo "Node.js is installed and is version $(nodejs --version)"
else
    echo "Installing Node.js..."
    sudo apt update
    sudo apt install nodejs
fi

if (npm --version)
then
    echo "NPM is installed and is version $(npm --version)"
else
    echo "Installing NPM..."
    sudo apt install npm
fi

if (git --version)
then
    echo "Git is installed and is version $(git --version)"
else
    echo "Installing git..."
    sudo apt install git
fi

if (pwd == $HOME) 
then
    echo "You are in the home directory."
else
    cd /home/$USER
fi

echo "Cloning API-Server from github..."
git clone https://github.com/VirtDev337/API-Server.git
error=$?
if [ -d API-Server ]
then
    echo "API-Server exists, clone successful. Changing current working directory..."
    cd API-Server
else
    echo "API-Server was not successful. $?"
    exit $error
fi

