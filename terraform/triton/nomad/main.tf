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

resource "triton_machine" "test-nomad-server" {
  name    = "test-nomad-${count.index}"
  package = "c-1-2-50-g1"
  image   = "882f4da6-9b34-4be9-adcb-23e087d5611f"
  count = 3

  tags = {
    nomad-server  = "yes"
  }

  cns {
    services = ["nomad-server"]
  }

}
