#!/usr/bin/bash

random_time=`shuf -i 30-60 -n 1`
# sleep ${random_time}
nodename=`hostname`
# we bind to net1: net0 is the public ip net1 is the fablan and others are docker
consul_bind_addr=`ip addr show net1 | awk '/inet / {gsub(/\/.*/,"",$2); print $2}'`
node_id=`openssl rand -hex 16 | sed 's/\(........\)\(....\)\(....\)\(....\)/\1-\2-\3-\4\-/'`

function run_nomad() {
    nohup bash -c "ssh-add /root/.ssh/id_rsa; nomad agent -config=/etc/nomad.d/nomad.hcl -data-dir=/opt/nomad/ &"
    nohup bash -c "consul agent -bind=${consul_bind_addr} -retry-join 'provider=triton account=xxx url=https://eu-ro-1.api.spearhead.cloud key_id=4f:29:a0:3b:ec:2e:b2:91:61:d8:db:d4:46:a2:b1:93 tag_key=consul-server tag_value=yes' -data-dir=/opt/consul -node-id=${node_id} -node=${nodename} &"
}

echo "-----BEGIN OPENSSH PRIVATE KEY-----
your key
-----END OPENSSH PRIVATE KEY-----" > /root/.ssh/id_rsa

echo "ssh-rsa your-pub-key-here root@packer" > /root/.ssh/id_rsa.pub
chmod 600 /root/.ssh/id_rsa*

loginctl enable-linger root
export SSH_AUTH_SOCK=/run/user/0/ssh-agent.socket
ssh-add /root/.ssh/id_rsa
keychain --systemd --inherit any --agents ssh --eval id_rsa

run_nomad

