#!/usr/bin/env bash

# First, add the GPG key for the official Docker repository to the system
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Add the Docker repository to APT sources
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Next, update the package database with the Docker packages from the newly added repo:
sudo apt-get -qq update

# Install Docker
sudo apt-get -qq install -y docker-ce

echo "Start the vault server"
sudo docker network create -d bridge mynetwork
sudo docker run --cap-add=IPC_LOCK -d -p 8200:8200 --network=mynetwork -v $(pwd)/vault:/vault --name vaultserver vault server
echo "Waiting for Vault to start"
while true ; do
  result=$(sudo docker logs vaultserver 2> /dev/null | grep -c "==> Vault server started! Log data will stream in below:")
  if [ $result = 1 ] ; then
    echo "Vault has started"
    break
  fi
  sleep 1
done

sudo docker cp $(pwd)/vault.init.sh vaultserver:/vault.init.sh
sudo docker exec vaultserver /vault.init.sh > vault.initialization.out
./vault.initialization.out.parse.sh

sudo docker exec vaultserver /bin/sh -c 'export VAULT_ADDR="http://127.0.0.1:8200";vault operator unseal '$(< ./vault/UnsealKey1)
sudo docker exec vaultserver /bin/sh -c 'export VAULT_ADDR="http://127.0.0.1:8200";vault operator unseal '$(< ./vault/UnsealKey2)
sudo docker exec vaultserver /bin/sh -c 'export VAULT_ADDR="http://127.0.0.1:8200";vault operator unseal '$(< ./vault/UnsealKey3)

sudo docker exec vaultserver /bin/sh -c 'export VAULT_ADDR="http://127.0.0.1:8200";vault login '$(< ./vault/InitialRootToken)
