terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.25.2"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12.1"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.11.1"
    }
  }
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/kind-config"
  }
}

resource "helm_release" "kube_prometheus_stack" {
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = "monitoring"
}


provider "kubernetes" {}

resource "kubernetes_deployment" "example" {
  metadata {
    name = "app.js"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "app.js"
      }
    }

    template {
      metadata {
        labels = {
          app = "nodejs-app"
        }
      }

      spec {
        container {
          image = "matthabbey/helloworld-nodejs:v1"
          name  = "nodejs-app"
          port {
            container_port = 3000
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "example" {
  metadata {
    name = "nodejs-service"
  }

  spec {
    selector = {
      app = "app.js"
    }

    port {
      port        = 80
      target_port = 8000
    }
  }
}

provider "kubectl" {}

resource "kubectl_manifest" "example" {
  yaml_body = file("${path.module}/deployment.yaml")
}

