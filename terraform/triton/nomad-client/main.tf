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

    key_material = "/Users/XXXX/.ssh/id_rsa"

    # If using a test Triton installation (self-signed certifcate), use:
    insecure_skip_tls_verify = false
}

resource "triton_machine" "test-nomad-client" {
  name    = "test-nomad-client-${count.index}"
  package = "c-1-2-50-g1"
  image   = "37140872-7091-4093-9aa5-8203db388ba2"
  count = 2

  tags = {
    nomad-client  = "yes"
  }

  cns {
    services = ["nomad-client"]
  }
  
  provisioner "remote-exec" {
    inline = [
      "systemctl start my-nomad",
    ]

    connection {
      type = "ssh"
      host = self.primaryip
      user = "root"
    }

  }
}

# data "triton_machine" "primaryip" {
#   name = "public_ip"
# }