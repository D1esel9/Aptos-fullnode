#!/bin/bash

#After installing the validator, we take a new server and execute the commands:
sudo apt update && sudo apt upgrade -y

sudo apt-get install ca-certificates curl gnupg lsb-release -y

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get install docker-ce docker-ce-cli containerd.io -y

mkdir -p ~/.docker/cli-plugins/

curl -SL https://github.com/docker/compose/releases/download/v2.6.1/docker-compose-linux-x86_64 -o ~/.docker/cli-plugins/docker-compose

chmod +x ~/.docker/cli-plugins/docker-compose

sudo chown $USER /var/run/docker.sock

mkdir ~/testnet && cd ~/testnet

wget -qO docker-compose.yaml https://raw.githubusercontent.com/aptos-labs/aptos-core/main/docker/compose/aptos-node/docker-compose-fullnode.yaml

wget -qO fullnode.yaml https://raw.githubusercontent.com/aptos-labs/aptos-core/main/docker/compose/aptos-node/fullnode.yaml

nano fullnode.yaml

#We substitute the ip from the validator and save.
#We go to the validator serv and download from there to the full node serv to the ~/testnet/ directory
#validator-full-node-identity.yaml genesis.blob waypoint.txt#

docker compose up -d

#We go to the validator server, change the ip of the full node

aptos genesis set-validator-configuration \
    --keys-dir ~/$WORKSPACE --local-repository-dir ~/$WORKSPACE \
    --username $NODENAME \
    --validator-host $PUBLIC_IP:6180 \
    --full-node-host <YOUR_FULLNODE_IP>:6182
    
cd .aptos
docker compose restart

#Checking logs and synchronization on a full node
curl 127.0.0.1:9101/metrics 2> /dev/null | grep aptos_state_sync_version | grep type
