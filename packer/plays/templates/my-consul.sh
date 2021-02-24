#!/usr/bin/bash

random_time=`shuf -i 30-60 -n 1`
# sleep ${random_time}
nodename=`hostname`
node_id=`openssl rand -hex 16 | sed 's/\(........\)\(....\)\(....\)\(....\)/\1-\2-\3-\4\-/'`

function run_consul() {
    nohup bash -c "ssh-add /root/.ssh/id_rsa; consul agent -server -config-file=/etc/consul.d/consul.hcl -node-id=${node_id} -node=${nodename} &"
}

echo "-----BEGIN OPENSSH PRIVATE KEY-----
your dedicated consul dedicated key here
-----END OPENSSH PRIVATE KEY-----" > /root/.ssh/id_rsa

echo "ssh-rsa your-ssh-pubkey here root@packer" > /root/.ssh/id_rsa.pub
chmod 600 /root/.ssh/id_rsa*

# most clouds do not allow lingering, we enable it here
# this is also quite specific to spearhead.cloud( triton ) for this poc
# there are other (better) solutions
loginctl enable-linger root
export SSH_AUTH_SOCK=/run/user/0/ssh-agent.socket
ssh-add /root/.ssh/id_rsa
keychain --systemd --inherit any --agents ssh --eval id_rsa

run_consul
