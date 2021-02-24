#!/usr/bin/bash

sed 's/ui \= true/ui \= false/g' -i /etc/consul.d/consul.hcl
sed 's/ui \= true/ui \= false/g' -i /etc/consul.d/consul.hcl