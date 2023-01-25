variable "cloudflare_api_token" {
    type = string
}
variable "account_id" {
    type = string
}

variable "tunnel_secret" {
    type = string
}
 


terraform {
  backend "s3" {
    bucket         = "vultr-vdi"
    key            = "dev/cloudflare.tfstate"
    region         = "ap-northeast-2"
  }
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.0"
    }
  }
}
provider "cloudflare" {
  api_token = var.cloudflare_api_token
}
resource "cloudflare_argo_tunnel" "k8s_zero_trust_tunnel" {
  account_id = var.account_id
  name       = "jayney"
  secret     = var.tunnel_secret
}

resource "cloudflare_tunnel_route" "k8s_zero_trust_tunnel_ipv4" {
  account_id = var.account_id
  tunnel_id  = cloudflare_argo_tunnel.k8s_zero_trust_tunnel.id
  network    = "198.51.100.101/32"
  comment    = "Kubernetes API Server (IPv4)"
}
 
resource "cloudflare_tunnel_route" "k8s_zero_trust_tunnel_ipv6" {
  account_id = var.account_id
  tunnel_id  = cloudflare_argo_tunnel.k8s_zero_trust_tunnel.id
  network    = "2001:DB8::101/128"
  comment    = "Kubernetes API Server (IPv6)"
}

resource "cloudflare_teams_list" "k8s_apiserver_ips" {
  account_id = var.account_id
  name       = "Kubernetes API IPs"
  type       = "IP"
  items      = ["198.51.100.101/32", "2001:DB8::101/128"]
}
 
resource "cloudflare_teams_rule" "k8s_apiserver_zero_trust_http" {
  account_id  = var.account_id
  name        = "Don't inspect Kubernetes API"
  description = "Allow connections from kubectl to API"
  precedence  = 10000
  action      = "off"
  enabled     = true
  filters     = ["http"]
  traffic     = format("any(http.conn.dst_ip[*] in $%s)", replace(cloudflare_teams_list.k8s_apiserver_ips.id, "-", ""))
}

