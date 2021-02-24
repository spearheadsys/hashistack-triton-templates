The result of running these jobs is a *hashistack* based cluster ready for provisioning of workloads (docker, exec, etc.). The resulting infrastructure is composed of:

- consul server using *service mesh(connect)* (tbd) (3 members)
- nomad server cluster (3 members)
- nomad clients (2 servers)

The nomad client servers are used to schedule your workloads. You need to size these accordingly.

## Important information
This bluepring has been used consistently for our dev/test/staging environmetns. For a production ready system you will need to do some planning and update. Specifically you will want to secure things with tls/ssl, you may want to add additional security such as ACL's and in more advanced scenarios you may want consul connect (service mesh). 
All components (consul, nomad in our case) can be run independently: e.g. you can run just the nomad cluster without consul, however you will not have any service discovery or monitoring.

You will need|want to create some variables (tfvars) to keep things DRY. Until then run through the scripts/plays and define your environment and variables (users, keys, etc.). A future version of this may add vars to terraform to help with this.

# Getting started
This blueprint is built specifically for spearhead.cloud (joyent-triton). If you would like to use these for your specific platform update the packer and terraform configuration with your desired builder/provider.

You will need a supported [terraform provider] and [packer builder]. 

I recommend you do the following in a virtualenv wiWindows the documentation (Hashicorp) suggests using [Chocolatey]th python3.8+. I am using MacOS, for (https://chocolatey.org/). 

### Setup your document structure (virtualenv)
```
virtualenv hashistack-triton-templates
cd hashistack-triton-templates; . bin/activate
git clone git@github.com:spearheadsys/hashistack-triton-templates.git
cd hashistack-triton-templates
```

> The above works in macos using homebrew/pkgsrc for installing additional packages (*hashistack*, python3x, npm for additiona resources (triton provider, andsible dinnamic inventories, etc.))

### Ansible
Ansible is used as a terraform provisioner as a proof of concept. It works for us because once we provision, ansible takes over highier level orchestration specifically application and configuration management. It makes sense for us, it may not be so for you. 
Also, it may help to remember:
* terraform is declarative
* ansible is procedural

## Install packer, ansible, nomad and terraform
```
brew tap hashicorp/tap; brew install hashicorp/tap/packer
brew install hashicorp/tap/terraform
brew install hashicorp/tap/nomad
pip install ansible
```

# Workflow
Best practices regarding DRY principles (specifically using terraform modules to create a single, coherent provisioning step of all components) *may* be expected for a production deployment. We provision each component independently for this scenario.


## Create packer images 
The first step is creating the imgages. Find these in the packer/\<component.json> files. If you want all components create them as follows otherwise create just the one your are interested in:
1. consul
2. nomad server
3. nomad-client    

4. Example create packer image for triton-consul
```
packer validate triton-consul.json
packer build triton-consul.json
```
> write down the image id (from the packer build command) in the terraform/\<provider>/main.tf file


## Now its time to create the infrastructure based on the images we just created.

1. Prepare and apply terraform in terraform/\<provider> directory

```
cd terraform/consul
terraform init
terraform validate
terraform plan
terraform apply
```

Consul *should* be the first component you provision as the scaffolding specifically looks for a consul service to auto_join.


# nomad server and workers
Repeat the terraform init|validate|plan|apply workflow for the other components (terraform/\<provider>/\<component>/, where component is one of:
* consul
* nomad
* nomad-client

You should now access your consul/nomad clusters based on their service-name (spearhead.cloud uses cns (container name service) that defines a DNS name for your service). All providers have a particular approach here, you will need to find out how you can reach you systems based on DNS hopefully with a tag (consul-server would return all consul servers with that specific tag).

# other notes
* we use ssh-agent as it works natively with our public cloud (soearhead.cloud, aws and gcp.) and we can reuse one ssh key to do what we want, usually per tenant (company). Depending on the provider and provisioner, communicators used you may not need these.
* Im pushing tfstate to this repo .. it is not consistent as I do not commit *every* state change (a better place is most likely consul for these, specifically if more people/systems will interact with these)
* encryption (tls) is not provided (add them manually or update the provisioners to include tls/encrypt stanzas and certificates)
* I am using two nics (external, one internal) in our images
   * consul listens on BOTH
   * one is our vxlan (usually internal per application/scope/etc.)
   * the public nic is just so we can quickly access it. It may also be any other nic, change the packer



[terraform provider]: https://www.terraform.io/docs/providers/index.html
[packer builder]: https://www.packer.io/docs/builders