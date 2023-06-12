module "github_repository" {
  source                   = "github.com/den-vasyliev/tf-github-repository"
  github_owner             = var.GITHUB_OWNER
  github_token             = var.GITHUB_TOKEN
  repository_name          = var.FLUX_GITHUB_REPO
  public_key_openssh       = module.tls_private_key.public_key_openssh
  public_key_openssh_title = "flux0"
}

module "gke_cluster" {
  source         = "github.com/den-vasyliev/tf-google-gke-cluster?ref=gke_auth"
  GOOGLE_REGION  = var.GOOGLE_REGION
  GOOGLE_PROJECT = var.GOOGLE_PROJECT
  GKE_NUM_NODES  = var.GKE_NUM_NODES
}

module "flux_bootstrap" {
  source            = "github.com/den-vasyliev/tf-fluxcd-flux-bootstrap?ref=gke_auth"
  github_repository = "${var.GITHUB_OWNER}/${var.FLUX_GITHUB_REPO}"
  private_key       = module.tls_private_key.private_key_pem
  #  config_path       = module.gke_cluster.kubeconfig
  github_token = var.GITHUB_TOKEN
  config_host  = module.gke_cluster.config_host
  config_token = module.gke_cluster.config_token
  config_ca    = module.gke_cluster.config_ca
}

module "tls_private_key" {
  source    = "github.com/den-vasyliev/tf-hashicorp-tls-keys"
  algorithm = var.algorithm
}

# module "kind_cluster" {
#   source       = "github.com/den-vasyliev/tf-kind-cluster"
#   cluster_name = "kind-cluster"
#   config       = <<-EOF
#     kind: Cluster
#     apiVersion: kind.x-k8s.io/v1beta2
#     nodes:
#     - role: control-plane
#     - role: worker
#     - role: worker
#   EOF
# }

# module "flux_bootstrap" {
#   source            = "github.com/den-vasyliev/tf-fluxcd-flux-bootstrap?ref=gke_auth"
#   github_repository = "${var.GITHUB_OWNER}/${var.FLUX_GITHUB_REPO}"
#   private_key       = module.tls_private_key.private_key_pem
#   github_token      = var.GITHUB_TOKEN
#   config_host       = module.kind_cluster.config_host
#   config_token      = module.kind_cluster.config_token
#   config_ca         = module.kind_cluster.config_ca
# }