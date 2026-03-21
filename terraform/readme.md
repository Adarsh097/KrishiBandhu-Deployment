# 🚜 KrishiBandhu Infrastructure (Terraform • AWS • GitOps)

This repository defines the **infrastructure layer** for *KrishiBandhu*, an AI-powered voice assistant for farmers.

It follows a **modular Terraform-based IaC approach**, uses **Ansible for configuration management**, and implements a **GitOps-driven CI/CD pipeline** on AWS.

---

## 📌 Overview

The infrastructure is designed with a strong focus on:

* Modularity and reusability
* Scalability and fault isolation
* Automated CI/CD workflows
* Observability and monitoring

---

## 🏗 Architecture

The system is divided into independent layers to ensure maintainability and flexibility.

---

### 🗄 1. Remote Backend

* S3 bucket stores Terraform state (`terraform.tfstate`)
* DynamoDB table provides state locking to prevent concurrent updates

---

### 🌐 2. Networking (VPC)

* Custom VPC with public and private subnets
* Public subnets for external access components
* Private subnets for internal workloads (EKS nodes)

Terraform `data` blocks are used to dynamically fetch:

* `vpc_id`
* `subnet_ids`

---

### ⚙️ 3. Compute Layer (EC2)

**Ansible Node (t3.micro)**

* Acts as the configuration management controller

**Jenkins Node (Large EC2)**
Configured using Ansible with:

* Jenkins
* Docker
* Trivy

Responsibilities:

* Build Docker images
* Perform vulnerability scanning
* Update Kubernetes manifests in Git

---

### ☸️ 4. Kubernetes (EKS)

* Managed Kubernetes cluster for application deployment
* Designed for scalability and high availability

**ArgoCD (GitOps)**

* Watches Git repository
* Automatically syncs changes to the cluster

**Monitoring Stack**

* Prometheus for metrics collection
* Grafana for visualization

---

## 🔄 DevOps Workflow

```text
Developer → GitHub → Jenkins → Docker Hub → Git → ArgoCD → EKS → Monitoring
```

### Flow Explanation

1. Terraform provisions AWS infrastructure
2. Ansible configures EC2 instances
3. Jenkins builds and scans Docker images using Trivy
4. Images are pushed to Docker Hub with version tags
5. Jenkins updates Kubernetes manifests in Git
6. ArgoCD detects changes and deploys to EKS
7. Prometheus and Grafana monitor the system

---

## 📂 Repository Structure

```text
.
├── remote-backend/      # Terraform state management (S3 + DynamoDB)
├── vpc/                 # Networking resources
├── ansible-node/        # Ansible control node
├── jenkins-node/        # CI/CD infrastructure
├── eks-cluster/         # Kubernetes and monitoring setup
└── ansible-playbooks/   # Configuration automation
```

---

## 🛠 Prerequisites

* AWS CLI (configured with appropriate IAM permissions)
* Terraform (v1.x or later)
* Ansible (v2.10 or later)
* Helm (v3.x)
* kubectl

---

## 🚀 Deployment Steps

### 1. Initialize Backend

```bash
cd remote-backend
terraform init
terraform apply
```

### 2. Deploy Networking

```bash
cd ../vpc
terraform init
terraform apply
```

### 3. Deploy Compute Infrastructure

```bash
cd ../ansible-node && terraform apply
cd ../jenkins-node && terraform apply
```

Run Ansible:

```bash
cd ../ansible-playbooks
ansible-playbook jenkins-setup.yml
```

### 4. Deploy EKS Cluster

```bash
cd ../eks-cluster
terraform init
terraform apply
```

### 5. Install Monitoring

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

helm install monitoring prometheus-community/kube-prometheus-stack
```

---

## 🔐 Security and Best Practices

* Remote state stored in S3 with controlled access
* State locking via DynamoDB
* Container image scanning using Trivy
* No hardcoded secrets (use Kubernetes Secrets / Sealed Secrets)
* Versioned Docker images for consistent deployments

---

## ⚠️ Note

DynamoDB is used only for Terraform state locking and is not part of the application database layer. The application database (MongoDB) runs inside the Kubernetes cluster.

---

## 📈 Future Improvements

* Multi-environment support using Terraform workspaces
* Integration with AWS Secrets Manager or Vault
* Alerting using Alertmanager
* Ingress with domain and TLS

---

## 📖 Summary

This project demonstrates a **complete infrastructure provisioning and deployment pipeline** using:

* Terraform for infrastructure
* Ansible for configuration
* Jenkins for CI
* ArgoCD for CD (GitOps)
* Prometheus and Grafana for monitoring

---
---
---

