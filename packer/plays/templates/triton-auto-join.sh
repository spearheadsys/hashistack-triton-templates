#!/usr/bin/bash

# we sleep a random amount to give all of our instances time to show up in cns
random_time=`shuf -i 30-60 -n 1`
sleep ${random_time}

# we use cns to bootstrap ourselves. other providers provide similar mechs 
# (vsphere with tags, aws/azure,. etc with labels,) ...
# the purpose is to get a list of your consul nodes (ip/hostname)
retry_join=""
records=`dig consul-server.svc.41824237-4616-42e3-d189-f9bd0242b4e4.ro-1.on.spearhead.cloud +short`

for record in $records; do
	retry_join+=" \"${record}\","
done

sed "s/\#.*retry_join.*/retry_join=\[$retry_join\]/" -i /etc/consul.d/consul.hcl

systemctl restart consul
exit 0