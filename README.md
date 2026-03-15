# Java Microservice — GitOps CI/CD on AWS EKS

End-to-end DevOps pipeline deploying a Java application to AWS EKS using Terraform, GitLab CI/CD, ArgoCD, and a full observability stack.

---

## Architecture Overview

![Architecture Diagram](screenshots/architecture.png)
> *Recommended: Draw a diagram showing GitLab CI → ECR → ArgoCD → EKS with dev/test/prod namespaces*

---

## Tech Stack

| Area | Tools |
|---|---|
| Infrastructure | Terraform, AWS EKS, VPC, ECR, IAM |
| CI/CD | GitLab CI/CD, OIDC Authentication |
| GitOps | ArgoCD, Helm |
| Observability | Prometheus, Grafana, Loki |
| Networking | NGINX Ingress, ExternalDNS, Route53 |
| Autoscaling | HPA |
| Language | Java |

---

## Features

- **Infrastructure as Code** — VPC, EKS cluster, IAM roles, and ECR access provisioned entirely with Terraform
- **Secure CI/CD** — GitLab pipelines authenticated via OIDC (no long-lived credentials), building and pushing versioned images to ECR
- **GitOps Delivery** — ArgoCD watches dedicated branches (`dev`, `test`, `main`) in the GitOps repo and automatically promotes changes into their respective Kubernetes namespaces
- **Environment Isolation** — Each environment maps to a dedicated branch and Kubernetes namespace, ensuring clean separation between dev, test, and production
- **Observability Stack** — Prometheus, Grafana, and Loki deployed alongside the application via Helm for metrics, dashboards, and log aggregation
- **Automated DNS** — ExternalDNS automatically creates Route53 records pointing to the NGINX Ingress load balancer on every deployment
- **Autoscaling** — HPA configured to automatically scale pods based on CPU/memory demand

---

## Screenshots

### ArgoCD — Application Sync
![ArgoCD Sync](screenshots/argocd-sync.png)

### ArgoCD — Dev/Test/Prod Applications
![ArgoCD Apps](screenshots/argocd-apps.png)

### Grafana Dashboard
![Grafana](screenshots/grafana-dashboard.png)

### GitLab CI Pipeline
![GitLab Pipeline](screenshots/gitlab-pipeline.png)

### AWS EKS Cluster
![EKS Cluster](screenshots/eks-cluster.png)

### ECR Repository
![ECR](screenshots/ecr-repo.png)

---

## Project Structure

```
├── TerraformEKS/
│   └── vprofile-project/
│       ├── eks-cluster.tf        # EKS cluster + node groups
│       ├── helm-provider.tf      # Kubernetes + Helm providers
│       ├── argocd.tf             # ArgoCD namespace + Helm install
│       ├── argocd-apps.tf        # ArgoCD Application manifests
│       ├── external-dns.tf       # NGINX ingress + ExternalDNS
│       └── route53.tf            # Route53 hosted zone data source
└── K8CICD/
    └── HelmCharts/
        └── tomcat-monitoring-chart/
            └── values.yaml       # Helm chart values
```

---

## CI/CD Flow

```
Code Push → GitLab CI
  → Build & Test Java app
  → Build Docker image
  → Push to ECR (versioned tag)
  → Merge to dev/test/main branch in GitOps repo
    → ArgoCD detects branch change
      → Deploys to corresponding namespace (vprofile-dev/test/prod)
        → ExternalDNS updates Route53
```

---

## Environment Strategy

| Branch | Namespace | URL |
|---|---|---|
| `dev` | `vprofile-dev` | `https://dev.tomcat.cutsopen.co.uk` |
| `test` | `vprofile-test` | `https://test.tomcat.cutsopen.co.uk` |
| `main` | `vprofile-prod` | `https://tomcat.cutsopen.co.uk` |

---

## Infrastructure

- **VPC** — Custom VPC with public/private subnets across multiple AZs
- **EKS** — Managed node groups with `t3.small` instances, autoscaling 1-3 nodes
- **ECR** — Private container registry with node IAM role pull access
- **IAM** — Least privilege roles for EKS nodes, ExternalDNS, and CI/CD

---

## Observability

| Tool | Purpose | URL |
|---|---|---|
| Prometheus | Metrics scraping | Internal |
| Grafana | Dashboards | `grafana.cutsopen.co.uk` |
| Loki | Log aggregation | Internal |

---

## Live URLs

| Environment | URL |
|---|---|
| Production | `https://tomcat.cutsopen.co.uk` |
| Dev | `https://dev.tomcat.cutsopen.co.uk` |
| Test | `https://test.tomcat.cutsopen.co.uk` |
| Grafana | `https://grafana.cutsopen.co.uk` |
