#!/bin/bash

figlet -w 160 -f standard "Provision Vault"

export VAULT_DNS=$(echo `cat ~/.vault_dns`)
echo "VAULT at "$VAULT_DNS

figlet -f slant "Upload and run vault.init.sh"
echo "remote execution: mkdir /home/ubuntu/vault"
bolt command run 'mkdir /home/ubuntu/vault' --nodes $VAULT_DNS --user 'ubuntu' --no-host-key-check
echo "remote execution: mkdir /home/ubuntu/vault/config"
bolt command run 'mkdir /home/ubuntu/vault/config' --nodes $VAULT_DNS --user 'ubuntu' --no-host-key-check
echo "upload: vault.init.sh to /home/ubuntu/vault.init.sh"
bolt file upload 'vault.init.sh' '/home/ubuntu/vault.init.sh' --nodes $VAULT_DNS --user 'ubuntu' --no-host-key-check
echo "remote execution: chmod +x /home/ubuntu/vault.init.sh"
bolt command run 'chmod +x /home/ubuntu/vault.init.sh' --nodes $VAULT_DNS --user 'ubuntu' --no-host-key-check
echo "upload: vault.local.json to /home/ubuntu/vault/config/vault.local.json"
bolt file upload 'vault.local.json' '/home/ubuntu/vault/config/vault.local.json' --nodes $VAULT_DNS --user 'ubuntu' --no-host-key-check
echo "upload: vault.initialization.out.parse.sh to /home/ubuntu/vault.initialization.out.parse.sh"
bolt file upload 'vault.initialization.out.parse.sh' '/home/ubuntu/vault.initialization.out.parse.sh' --nodes $VAULT_DNS --user 'ubuntu' --no-host-key-check
echo "remote execution: chmod +x /home/ubuntu/vault.initialization.out.parse.sh"
bolt command run 'chmod +x /home/ubuntu/vault.initialization.out.parse.sh' --nodes $VAULT_DNS --user 'ubuntu' --no-host-key-check

figlet -w 160 -f slant "Upload and run provision_vault.sh"
echo "upload: provision_vault.sh to /home/ubuntu/provision_vault.sh"
bolt file upload 'provision_vault.sh' '/home/ubuntu/provision_vault.sh' --nodes $VAULT_DNS --user 'ubuntu' --no-host-key-check
echo "remote execution: chmod +x /home/ubuntu/provision_vault.sh"
bolt command run 'chmod +x /home/ubuntu/provision_vault.sh' --nodes $VAULT_DNS --user 'ubuntu' --no-host-key-check
echo "remote exeution: /home/ubuntu/provision_vault.sh"
bolt command run '/home/ubuntu/provision_vault.sh' --nodes $VAULT_DNS --user 'ubuntu' --no-host-key-check | tee ./.temp

while read line
do
   echo "$line" | grep  "token          \s*" | xargs | cut -d ' ' -f2 > ./.line
   if [ $(wc -c < ./.line) -ge 8 ]; then
      cp ./.line ~/.vault_initial_root_token
      rm ./.line
   fi
done < ./.temp
rm ./.temp ./.line