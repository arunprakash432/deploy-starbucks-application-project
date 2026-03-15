module "sonarqube_ec2" {
  source = "./modules/ec2"

  ami           = "ami-0a14f53a6fe4dfcd1" # Ubuntu AMI
  key_name      = "master-machine-key"
  instance_name = "sonarqube-server"
  sg_name       = "sonarqube-sg"

  ingress_ports = [
    22,
    80,
    443,
    9000
  ]
}

module "monitoring_ec2" {
  source = "./modules/ec2"

  ami           = "ami-0a14f53a6fe4dfcd1" # Ubuntu AMI
  key_name      = "master-machine-key"
  instance_name = "monitoring-server"
  sg_name       = "monitoring-sg"

  ingress_ports = [
    22,
    80,
    443,
    3000,
    9090,
    9115
  ]
}

module "eks_cluster" {
  source = "./modules/eks"

  cluster_name = var.eks_cluster_name
  node_count   = 2
}