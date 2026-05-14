<h1>Java Microservice — GitOps CI/CD on AWS EKS</h1>

<p>
End-to-end DevOps pipeline deploying a Java application to AWS EKS using Terraform, GitLab CI/CD, ArgoCD, and a full observability stack.
</p>
<hr>
<h2>🚀 Architecture Evolution</h2>

<h3>v1 – EC2-Based Monitoring (Pre-Kubernetes)</h3>
<ul>
<li>Deployed application on EC2</li>
<li>Manually installed Prometheus, Grafana, and Loki</li>
<li>Monitoring stack managed separately from application</li>
</ul>
<p><b>Problem:</b> High maintenance, not scalable, not cloud-native</p>

<h3>v2 – Kubernetes Foundation (EKS via Terraform)</h3>
<ul>
<li>Provisioned EKS cluster using Terraform</li>
<li>Deployed workloads manually using <code>kubectl apply</code></li>
</ul>
<p><b>Problem:</b> Deployment process still manual and not reproducible</p>

<h3>v3 – CI Integration (GitLab CI + OIDC)</h3>
<ul>
<li>Implemented GitLab CI pipeline</li>
<li>Used OIDC for secure AWS authentication</li>
<li>Automated build and push to ECR</li>
</ul>
<p><b>Progress:</b> CI achieved, but CD still manual</p>


<h3>v4 – GitOps Adoption (ArgoCD)</h3>
<ul>
<li>Deployed ArgoCD using Terraform</li>
<li>Introduced GitOps workflow with separate repositories</li>
<li>Automatic sync based on branch changes</li>
</ul>
<p><b>Impact:</b> Fully automated, declarative deployments</p>

<h3>v5 – Helm-Based Standardization</h3>
<ul>
<li>Replaced raw Kubernetes manifests with Helm charts</li>
<li>Introduced environment-based configuration (dev/test/prod)</li>
<li>Implemented branch-based promotion strategy</li>
</ul>
<p><b>Impact:</b> Reusable and scalable deployment model</p>

<h3>v6 – Integrated Observability (Cloud-Native Approach)</h3>
<ul>
<li>Initially planned separate monitoring deployment</li>
<li>Shifted to container-native observability stack</li>
<li>Integrated Helm Chart with official images for Prometheus, Grafana, and Loki</li>
</ul>
<p><b>Insight:</b> Leveraging ecosystem-standard tooling improves consistency and maintainability</p>

<h3>v7 – Production Enhancements</h3>
<ul>
<li>Implemented Horizontal Pod Autoscaler (HPA)</li>
<li>Added resource limits and requests</li>
<li>Integrated ExternalDNS for automated DNS management</li>
</ul>
<p><b>Impact:</b> Production-ready, scalable platform</p>

<h3>v8 – Maximised Policy Enforcement</h3>
<ul>
<li>Deployed OPA Gatekeeper via Terraform Helm module</li>
<li>Implemented ConstraintTemplate to enforce allowed image registries at admission level</li>
<li>Scoped constraint to tomcat pods only via label selector</li>
<li>Registry value configurable per environment via values.yaml</li>
<li>Configured GitLab RBAC to restrict pipeline job execution to authorised roles only</li>
<li>Controlled merge and push permissions per repository</li>
</ul>
<p><b>Impact:</b> End-to-end least-privilege enforcement — from source control access through to what runs in the cluster</p>

<h3>v9 – Secrets Management (ESO + IRSA)</h3>
<ul>
<li>Deployed External Secrets Operator (ESO) via Terraform Helm module into a dedicated <code>external-secrets</code> namespace</li>
<li>Configured IRSA (IAM Roles for Service Accounts) — ESO's service account is annotated with an IAM role ARN, allowing it to authenticate to AWS without static credentials</li>
<li>IAM role trust policy scoped to the exact OIDC issuer and service account (<code>system:serviceaccount:external-secrets:external-secrets</code>) using <code>sts:AssumeRoleWithWebIdentity</code></li>
<li>IAM policy grants least-privilege access: <code>secretsmanager:GetSecretValue</code> and <code>secretsmanager:DescribeSecret</code> only</li>
<li>Defined a <code>SecretStore</code> in the Helm chart pointing to AWS Secrets Manager, authenticated via the IRSA-bound service account</li>
<li>Defined an <code>ExternalSecret</code> in the Helm chart that pulls the secret value from Secrets Manager and materialises it as a native Kubernetes Secret</li>
</ul>
<p><b>Impact:</b> No secrets stored in Git or Kubernetes manifests — secrets are fetched directly from AWS Secrets Manager at runtime using short-lived, workload-scoped IAM credentials</p>

<h3>v10 – Automated TLS (cert-manager + Let's Encrypt)</h3>
<ul>
<li>Deployed cert-manager via Terraform Helm module into a dedicated <code>cert-manager</code> namespace with CRDs installed</li>
<li>Configured IRSA for cert-manager — dedicated IAM role scoped exclusively to <code>system:serviceaccount:cert-manager:cert-manager</code>, separate from the ExternalDNS role</li>
<li>IAM policy grants least-privilege Route53 access: <code>ChangeResourceRecordSets</code> and <code>GetChange</code> scoped to the specific hosted zone only</li>
<li>Defined a <code>ClusterIssuer</code> in the Helm chart pointing to Let's Encrypt using DNS-01 challenge via Route53</li>
<li>cert-manager ingress-shim detects the <code>cert-manager.io/cluster-issuer</code> annotation on the ingress and automatically triggers the ACME flow — no separate <code>Certificate</code> manifest needed</li>
<li>cert-manager writes a <code>_acme-challenge</code> TXT record to Route53 using its IRSA credentials, Let's Encrypt validates it, and the issued cert is stored as a Kubernetes secret</li>
<li>NGINX ingress loads the secret and terminates HTTPS — cert auto-renews at 60 days with no manual intervention</li>
</ul>
<p><b>Impact:</b> End-to-end automated TLS — certificates are requested, validated, issued, and renewed without any manual steps or static credentials</p>

<h3>v11 – Zero Downtime Deployments</h3>
<ul>
<li>Implemented RollingUpdate strategy with <code>maxUnavailable: 0</code> and <code>maxSurge: 1</code> to ensure no pods are taken down until replacements are ready</li>
<li>Added readiness probe to prevent traffic being sent to pods that are still starting up</li>
<li>Added liveness probe to automatically restart unhealthy pods</li>
<li>Configured <code>terminationGracePeriodSeconds: 60</code> to allow in-flight requests to complete before pod shutdown</li>
</ul>
<p><b>Impact:</b> Deployments are now fully zero downtime — no dropped requests during rolling updates</p>

<h3>📊 Final Outcome</h3>
<ul>
<li>Fully automated CI/CD + GitOps pipeline</li>
<li>Zero manual deployments</li>
<li>Zero downtime rolling updates with graceful pod termination</li>
<li>Unified infrastructure, deployment, and observability</li>
<li>Scalable and production-ready Kubernetes platform</li>
</ul>

<hr>

<h2>Architecture Overview</h2>

<p>
<img src="screenshots/GitCDDIagram.png" alt="Architecture Diagram" height=550>
</p>




<hr>


<h2>Features</h2>

<ul>
<li><b>Infrastructure as Code</b> — VPC, EKS cluster, IAM roles, and ECR access provisioned entirely with Terraform</li>
<li><b>Secure CI/CD</b> — GitLab pipelines authenticated via OIDC (no long-lived credentials)</li>
<li><b>GitOps Delivery</b> — ArgoCD watches branches (<code>dev</code>, <code>test</code>, <code>main</code>) and deploys automatically</li>
<li><b>Environment Isolation</b> — Each environment maps to its own Kubernetes namespace</li>
<li><b>Observability Stack</b> — Prometheus, Grafana and Loki deployed via Helm</li>
<li><b>Automated DNS</b> — ExternalDNS automatically updates Route53 records</li>
<li><b>Autoscaling</b> — HPA scales pods automatically based on CPU/memory demand</li>
<li><b>Policy Enforcement</b> — OPA Gatekeeper blocks non-compliant images at admission using ConstraintTemplates</li>
<li><b>GitLab RBAC</b> — Role-based access control restricting pipeline execution, merges, and pushes to authorised users</li>
<li><b>Zero Downtime Deployments</b> — RollingUpdate strategy with readiness/liveness probes and graceful termination ensuring no dropped requests during updates</li>
<li><b>Secrets Management</b> — External Secrets Operator syncs secrets from AWS Secrets Manager into Kubernetes; ESO authenticates via IRSA with no static credentials</li>
<li><b>Automated TLS</b> — cert-manager obtains and renews Let's Encrypt certificates automatically via DNS-01 challenge; authenticates to Route53 using a dedicated IRSA role</li>
</ul>

<hr>
<h2>Tech Stack</h2>

<table>
<tr>
<th>Area</th>
<th>Tools</th>
</tr>

<tr>
<td>Infrastructure</td>
<td>Terraform, AWS EKS, VPC, ECR, IAM</td>
</tr>

<tr>
<td>CI/CD</td>
<td>GitLab CI/CD, OIDC Authentication</td>
</tr>

<tr>
<td>GitOps</td>
<td>ArgoCD, Helm</td>
</tr>

<tr>
<td>Observability</td>
<td>Prometheus, Grafana, Loki</td>
</tr>

<tr>
<td>Networking</td>
<td>NGINX Ingress, ExternalDNS, Route53</td>
</tr>

<tr>
<td>Autoscaling</td>
<td>HPA</td>
</tr>

<tr>
<td>Policy</td>
<td>OPA Gatekeeper</td>
</tr>

<tr>
<td>Secrets Management</td>
<td>External Secrets Operator, AWS Secrets Manager, IRSA</td>
</tr>

<tr>
<td>TLS</td>
<td>cert-manager, Let's Encrypt, IRSA</td>
</tr>

<tr>
<td>Access Control</td>
<td>GitLab RBAC</td>
</tr>

<tr>
<td>Language</td>
<td>Java</td>
</tr>
</table>
<hr>


<h2>CI/CD Flow</h2>

<pre>
Code Push → GitLab CI
  → Build & Test Java app
  → Build Docker image
  → Push to ECR
  → Merge to dev/test/main branch
    → ArgoCD detects branch change
      → Deploys to namespace
        → ExternalDNS updates Route53
</pre>

<hr>

<h2>Environment Strategy</h2>

<table>
<tr>
<th>Branch</th>
<th>Namespace</th>
<th>URL</th>
</tr>

<tr>
<td>dev</td>
<td>vprofile-dev</td>
<td>https://dev.tomcat.cutsopen.co.uk</td>
</tr>

<tr>
<td>test</td>
<td>vprofile-test</td>
<td>https://test.tomcat.cutsopen.co.uk</td>
</tr>

<tr>
<td>main</td>
<td>vprofile-prod</td>
<td>https://tomcat.cutsopen.co.uk</td>
</tr>
</table>
<hr>
<h2>Infrastructure</h2>

<ul>
<li><b>VPC</b> — Custom VPC with public/private subnets across multiple AZs</li>
<li><b>EKS</b> — Managed node groups with <code>t3.small</code> instances (1–3 nodes autoscaling)</li>
<li><b>ECR</b> — Private container registry</li>
<li><b>IAM</b> — Least privilege roles for EKS nodes, ExternalDNS, and CI/CD</li>
</ul>


<hr>
<h2>🚨 Incident Handling & Lessons Learned</h2>

<ul>
<li>Observed only 4 metrics in Grafana from Prometheus</li>
<li>Verified Prometheus scraping and app connectivity to the Java microservice</li>
<li>Discovered application error on the webpage prevented JMX exporter from exposing metrics</li>
<li>Checked Loki logs and realized metrics issue could have been detected earlier via logs</li>
<li>Root cause: Image pull failed due to lack of ECR permissions</li>
<li>Fixed Terraform policies to allow ECR access → redeployed container</li>
<li><b>Lesson learned:</b> Always check both logs and metrics when troubleshooting, as either alone may hide the root cause</li>
</ul>
<hr>
<h2>Observability</h2>

<table>
<tr>
<th>Tool</th>
<th>Purpose</th>
<th>URL</th>
</tr>

<tr>
<td>Prometheus</td>
<td>Metrics scraping</td>
<td>Internal</td>
</tr>

<tr>
<td>Grafana</td>
<td>Dashboards</td>
<td>grafana.cutsopen.co.uk</td>
</tr>

<tr>
<td>Loki</td>
<td>Log aggregation</td>
<td>Internal</td>
</tr>
</table>

<hr>
<h2>Project Structure</h2>

<pre>
TerraformEKS/
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tf
└── modules/
    ├── vpc/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── eks/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── argocd/
    │   ├── main.tf
    │   └── outputs.tf
    ├── argocd-apps/
    │   ├── main.tf
    │   └── variables.tf
    ├── external-dns/
    │   ├── main.tf
    │   └── variables.tf
    ├── opa/
    │   ├── main.tf
    │   └── outputs.tf
    ├── eso/
    │   ├── main.tf
    │   └── variables.tf
    └── cert-manager/
        ├── main.tf
        └── variables.tf
HelmCharts/
└── tomcat-monitoring-chart/
    ├── templates/
    │   ├── apps/
    │   │   ├── hpa.yaml
    │   │   ├── ingress.yaml
    │   │   ├── jmx-configmap.yaml
    │   │   ├── tomcat-deployment.yaml
    │   │   └── tomcat-service.yaml
    │   ├── monitoring/
    │   │   ├── alloy-configmap.yaml
    │   │   ├── alloy-daemonset.yaml
    │   │   ├── alloy-rbac.yaml
    │   │   ├── grafana-datasources.yaml
    │   │   ├── grafana-deployment.yaml
    │   │   ├── loki-configmap.yaml
    │   │   ├── loki-deployment.yaml
    │   │   ├── prometheus-configmap.yaml
    │   │   └── prometheus-deployment.yaml
    │   ├── opa/
    │   │   ├── allowed-registry-template.yaml
    │   │   └── allowed-registry-constraint.yaml
    │   ├── Secretmanagement/
    │   │   ├── SecretStore.yaml
    │   │   └── ExternalSecrets.yaml
    │   └── cert-manager/
    │       └── cluster-issuer.yaml
    ├── Chart.yaml
    ├── values.yaml
    └── _helpers.tpl
AppCode/ (Committed to separate repo)
</pre>

<hr>
<h2>Screenshots</h2>

<h3>ArgoCD — Application Sync</h3>
<p><img src="screenshots/ArgoCdAppView.jpg" width="800"></p>

<h3>ArgoCD — Dev/Test/Prod Applications</h3>
<p><img src="screenshots/Screenshot 2026-03-15 211019.png" width="800"></p>

<h3>Grafana Dashboard</h3>
<p><img src="screenshots/Screenshot 2026-02-19 082508.png" width="800"></p>

<h3>GitLab CI Pipeline</h3>
<p><img src="screenshots/Screenshot 2026-03-15 235459.png" width="800"></p>

<h3>AWS EKS Cluster</h3>
<p><img src="screenshots/Screenshot 2026-03-15 225611.png" width="800"></p>


<hr>








</tr>
</table>
