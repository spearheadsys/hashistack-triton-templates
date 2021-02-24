terraform {
  required_providers {
    triton = {
      source = "joyent/triton"
      version = "0.8.1"
    }
  }
}

provider "triton" {
    account = "root"
    key_id  = ""

    # If using a private installation of Triton, specify the URL, otherwise
    # set the URL according to the region you wish to provision.
    url = "https://eu-ro-1.api.spearhead.cloud"

    # If you want to use a triton account other than the main account, then
    # you can specify the username as follows
    # user = "myusername"

    key_material = "/Users/xxx/.ssh/id_rsa"

    # If using a test Triton installation (self-signed certifcate), use:
    insecure_skip_tls_verify = false
}

resource "triton_machine" "test-consul-server" {
  name    = "test-consul-${count.index}"
  package = "c-1-2-50-g1"
  image   = "cc1f1d56-2c8d-4f74-be0a-101e1419f8f6"
  count = 3

  tags = {
    consul-server  = "yes"
  }

  cns {
    services = ["consul-server"]
  }

#   metadata = {
#     hello = "again"
#   }

  # provisioner "remote-exec" {
  #   inline = [
  #     "rm -rf /opt/consul/*",
  #     "nohup consul agent -server -config-file=/etc/consul.d/consul.hcl -node=test-consul-${count.index} &"
  #   ]
  # }
  # requires additional connect - seems sloppy

}
