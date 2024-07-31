provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "insecure_rg" {
  name     = "insecure-rg"
  location = "East US"
}

resource "azurerm_kubernetes_cluster" "insecure_aks" {
  name                = "insecure-aks-cluster"
  location            = azurerm_resource_group.insecure_rg.location
  resource_group_name = azurerm_resource_group.insecure_rg.name
  dns_prefix          = "insecureaks"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_DS2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
  }

  role_based_access_control {
    enabled = true

    azure_active_directory {
      managed                = true
      admin_group_object_ids = [var.admin_group_object_id] # Add your Azure AD Group Object ID here
    }
  }

  # Insecure: Enable HTTP application routing (not recommended for production)
  addon_profile {
    http_application_routing {
      enabled = true
    }
  }
}

resource "azurerm_kubernetes_cluster_role_binding" "insecure_cluster_role_binding" {
  metadata {
    name      = "insecure-cluster-admin-binding"
    namespace = "kube-system"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"  # Insecure: Granting cluster-admin role
  }

  subject {
    kind      = "User"
    name      = "adminuser@example.com"  # Insecure: Hardcoded user email
    api_group = "rbac.authorization.k8s.io"
  }
}

resource "azurerm_kubernetes_cluster_role_binding" "insecure_role_binding" {
  metadata {
    name      = "insecure-admin-binding"
    namespace = "default"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "admin"  # Insecure: Granting admin role
  }

  subject {
    kind      = "User"
    name      = "adminuser@example.com"  # Insecure: Hardcoded user email
    api_group = "rbac.authorization.k8s.io"
  }
}

resource "azurerm_kubernetes_role_binding" "insecure_namespace_role_binding" {
  metadata {
    name      = "insecure-namespace-admin-binding"
    namespace = "insecure-namespace"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "admin"  # Insecure: Granting admin role
  }

  subject {
    kind      = "User"
    name      = "namespaceadmin@example.com"  # Insecure: Hardcoded user email
    api_group = "rbac.authorization.k8s.io"
  }
}

output "kubeconfig" {
  value = azurerm_kubernetes_cluster.insecure_aks.kube_config_raw
  sensitive = true
}

variable "admin_group_object_id" {
  description = "The Object ID of the Azure AD group that will have admin access to the cluster"
  type        = string
}
