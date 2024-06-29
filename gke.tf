# Variáveis extras
variable "gke_username" {
  description = "User do GKE"
  default     = ""
}

variable "gke_password" {
  description = "Password do GKE"
  default     = ""
}

variable "gke_num_nodes" {
  description = "Número de nodes para o cluster"
  default     = 1
}

# Cluster GKE
resource "google_container_cluster" "priscila_cluster" {
  name                     = sensitive("${var.project_id}-gke")
  location                 = var.region
  remove_default_node_pool = true
  initial_node_count       = 1  # Reduzido para o mínimo necessário
  network                  = google_compute_network.vpc.name
  subnetwork               = google_compute_subnetwork.subnet.name

}

# Node Pool
resource "google_container_node_pool" "nodes_primarios" {
  name       = "${google_container_cluster.priscila_cluster.name}-node-pool"
  location   = var.region
  cluster    = google_container_cluster.priscila_cluster.name
  node_count = var.gke_num_nodes  # Reduzido para o mínimo necessário

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring"
    ]

    labels = {
      env = sensitive(var.project_id)
    }

    machine_type = "e2-micro"
    tags         = ["gke-node", sensitive("${var.project_id}-gke")]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}
