data "http" "ip" {
  url = "http://ipv4.icanhazip.com"
}

resource "tls_private_key" "bastion" {
  algorithm = "ED25519"
}