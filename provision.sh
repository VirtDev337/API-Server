if [ $(uname) = "Linux" ]
then
    
    if ( snap --version 2>/dev/null )
    then
        echo "Snap is already installed."
    else
        echo "Installing snapd..."
        sudo apt install -yq snapd
    fi

    if ( multipass version 2>/dev/null )
    then
        echo "Multipass is already installed."
    else
        echo "Installing multipass..."
        sudo snap install multipass >/dev/null
    fi
fi

sudo snap start multipass.multipassd > /dev/null
multipass start --all > /dev/null

while ! (ss -l | grep multipass_socket)
do
    sleep 2
done

if [ -f "~/.ssh/api-ed25519" ]
then
    echo "SSH keys exist."
else
    ssh-keygen -f "~/.ssh/api-ed25519" -b 4096 -t ed25519 -N ''
fi

if ( grep "$(cat ~/.ssh/api-ed25519.pub)" ~/.config/api-server/cloud-config.yaml 2> /dev/null )
then
    echo "cloud-config.yaml configured correctly."
else
    echo "create cloud-config.yaml and add the ssh public key..."
    
    cat <<- EOF > ~/.config/api-server/cloud-config.yaml
users:
  - default
  - name: $USER
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    ssh_authorized_keys:
      - $(cat ~/.ssh/api-ed25519.pub)
EOF

fi

# Check if chosen VM already exists
echo "Checking for a api-server instance within multipass."
if ( multipass info "api-server" > /dev/null )
then
    echo "api-server VM exists."
    # Check current state chosen of VM
    echo "Checking if api-server VM is running."
    
    if ( multipass info api-server | grep Running > /dev/null )
    then
        echo "api-server VM is running."
    else
        echo "Starting api-server VM..."
        multipass start api-server
    fi
    
    ip=$(multipass info "api-server" | grep IPv4 | awk '{ print $2 }')
else
    echo "Creating api-server vm..."
    multipass launch --cpus 2 --disk 10G --memory 4G --name "api-server" --cloud-init cloud-config.yaml
    
    ip=$(multipass info "api-server" | grep IPv4 | awk '{ print $2 }')
    
    echo "Copying $app install script to vm ~/..."
    scp -i ~/.ssh/api-ed25519 -o StrictHostKeyChecking=accept-new -q "./deploy.sh" $USER@$ip:"/home/$USER/.config/api-server/deploy.sh"

    echo "Running the api-server install script..."
    ssh -i ~/.ssh/api-ed25519 $USER@$ip "bash ~/.config/api-server/deploy.sh"
fi

echo "Establishing SSH connection to api-server..."
ssh -i ~/.ssh/api-ed25519 $USER@$ip

exit
