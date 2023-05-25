resource "kubernetes_namespace" "playground" {
  metadata {
    name = "playground"
  }
}

#
# Helm release check
#
resource "helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  chart      = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  version    = "4.6.0"
  namespace  = "playground"
}

check "ingress_nginx_up" {
  data "external" "this" {
    program = ["python", "${path.module}/check_helm_status.py", "ingress-nginx", "playground"]
  }

  assert {
    condition     = data.external.this.result.status == "deployed"
    error_message = "Ingress NGINX is not deployed"
  }
}

#
# Key value check
#
resource "kubernetes_network_policy" "ingress_nginx" {
  metadata {
    name      = "nginx-ingress-network-policy"
    namespace = "playground"
  }

  spec {
    pod_selector {
      match_expressions {
        key      = "name"
        operator = "In"
        values   = ["ingress-nginx"]
      }
    }

    ingress {
      ports {
        port     = "http"
        protocol = "TCP"
      }

      from {
        ip_block {
          cidr = "10.0.0.0/16"
          except = [
            "10.0.0.0/24",
            "10.0.1.0/24",
          ]
        }
      }
    }

    egress {
      ports {
        port     = "http"
        protocol = "TCP"
      }

      to {
        ip_block {
          cidr = "0.0.0.0/0"
          except = [
            "10.0.0.0/24",
            "10.0.1.0/24",
          ]
        }
      }
    }

    policy_types = ["Ingress", "Egress"]
  }
}

check "kubernetes_network_policy_ingress_nginx_egress_cidr" {
  assert {
    condition     = kubernetes_network_policy.ingress_nginx.spec[0].egress[0].to[0].ip_block[0].cidr == "0.0.0.0/0"
    error_message = "Egress CIDR is not open to the public."
  }
}