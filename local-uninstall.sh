#!/bin/bash

if (pwd == $HOME)
then
    echo "Current working directory is $HOME."
else
    echo "Current working directory is $(pwd).  Changing to $HOME."
    cd $HOME
fi

echo "Checking if api-server VM is running."
    
if ( multipass info api-server | grep Running > /dev/null )
then
    echo "api-server VM is running. Stopping..."
    multipass stop api-server
else
    echo "api-server VM is stopped."
fi

if ( multipass info "api-server" > /dev/null )
then
    echo "Deleting api-server virtual machine instance..."
    multipass delete --purge api-server
else
    echo "api-server virtual machine instance does not exist."
fi

if ( ip=ssh-keygen -H -F $(multipass info "api-server" | grep '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' | awk '{print $2}') 2> /dev/null ) 
then
    echo -e "Deleting fingerprint from known host."
    ssh-keygen -f $HOME/.ssh/known_hosts -R "$ip"
else 
    echo -e "Fingerprint not present in known host."
fi 

if [ -f $HOME/.ssh/api-ed25519 ]
then
    echo "Removing ssh key pairs."
    rm -f $HOME/.ssh/api-ed25519 $HOME/.ssh/api-ed25519.pub
fi

if (multipass version)
then
    echo "Removing multipass..."
    sudo snap remove --purge multipass
else
    echo "Multipass is not installed."
fi