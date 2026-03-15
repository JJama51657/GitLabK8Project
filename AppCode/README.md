<h1>ECS Blue/Green Deployment with Automated CI/CD</h1>

<h2>Project Overview</h2>
<p>This project demonstrates a <strong>production-style blue/green deployment pipeline</strong> for a containerized Java application using <strong>AWS ECS Fargate</strong>, <strong>CodeDeploy</strong>, and <strong>GitHub Actions</strong>. It focuses on <strong>zero-downtime deployments</strong>, <strong>automated rollback</strong>, and <strong>deployment safety</strong>.</p>

<h2>Features</h2>
<ul>
  <li><strong>Blue/Green Deployment:</strong> ECS + CodeDeploy traffic shifting with ALB health checks.</li>
  <li><strong>Tests + Checks:</strong> Performs Trivy security scans and SonarQube quality checks (applying left-shift security and fail-fast principles).</li>
  <li><strong>CI/CD Automation:</strong> GitHub Actions builds the app, then pushes Docker images to ECR, updates ECS task definitions, and triggers CodeDeploy Blue/Green deployments.</li>
  <li><strong>Automated Rollback:</strong> CloudWatch alarms trigger rollback on failures.</li>
  <li><strong>Failure Injection Testing:</strong> Validate rollback behavior with controlled test deployments.</li>
  <li><strong>Multi-stage Docker Build:</strong> Optimized production images.</li>
  <li><strong>Secure AWS Access:</strong> Uses OIDC GitHub Actions authentication (no hardcoded secrets).</li>
</ul>

<h2>Architecture Overview</h2>
<img width="512" height="7518" alt="image" src="https://github.com/user-attachments/assets/640fdd84-5944-4a59-a13d-22fa29d6c53b" />


<h2>Repository Structure</h2>
<pre>
.
├── app/                      # Application source code
├── docker-files/             # Dockerfiles and container build scripts
│   └── app/multistage/Dockerfile
├── .github/workflows/        # GitHub Actions CI/CD workflow
│   └── bluegreencodedeploy.yml
├── appspec.yaml              # CodeDeploy deployment specification
├── README.md                 # Project documentation
└── docker-compose.yml        # Optional local dev environment
</pre>

<h2>CI/CD Workflow</h2>
<ol>
  <li>Checkout repository</li>
  <li>Authenticate to AWS using OIDC GitHub Actions role</li>
  <li>Run tests and perform Trivy and SonarQube quality/security checks</li>
  <li>Build multi-stage Docker image and tag with commit SHA</li>
  <li>Push image to Amazon ECR</li>
  <li>Pull current ECS task definition and update image</li>
  <li>Register new task definition revision</li>
  <li>Prepare <code>appspec.yaml</code> with updated task definition</li>
  <li>Upload <code>appspec.yaml</code> to S3</li>
  <li>Trigger CodeDeploy Blue/Green deployment</li>
</ol>
<blockquote>Note: All AWS account IDs, IAM ARNs, and S3 bucket names are replaced with placeholders for public repositories.</blockquote>

<section>
  <h2>⚙ Key Configuration (appspec.yaml Excerpt)</h2>
  <p>
    The following excerpt from <code>appspec.yaml</code> shows how CodeDeploy integrates
    with the ECS service and Application Load Balancer to enable blue/green deployments.
    This configuration allows traffic shifting between task sets during deployment.
  </p>

  <pre><code>version: 0.0
Resources:
  - TargetService:
      Type: AWS::ECS::Service
      Properties:
        TaskDefinition: &lt;TASK_DEFINITION&gt;
        LoadBalancerInfo:
          ContainerName: app
          ContainerPort: 3000
</code></pre>

  <p>
    This configuration links the ECS service to CodeDeploy and enables controlled
    traffic shifting via the load balancer during blue/green deployments.
  </p>
</section>

<section>
  <h2>🔧 Failure Testing &amp; Operational Lessons</h2>

  <h3>Issue: Deployment Failed After Stopping Midway</h3>
  <p>
    During testing, I manually stopped a blue/green deployment in the traffic-shifting phase.
    When initiating a new deployment afterward, CodeDeploy failed to start the process.
  </p>

  <h3>Root Cause</h3>
  <p>
    Stopping the deployment left the Application Load Balancer target group weights in a
    partially shifted state. CodeDeploy requires the original traffic baseline of:
  </p>
  <ul>
    <li>100% traffic → Blue (original task set)</li>
    <li>0% traffic → Green (replacement task set)</li>
  </ul>
  <p>
    Because the weights were not reset automatically, the environment was left in an
    inconsistent state, preventing the next deployment from proceeding.
  </p>

  <h2>Resolution</h2>
  <ul>
    <li>Inspected ALB listener rules and target group weights</li>
    <li>Identified incorrect weighted routing configuration</li>
    <li>Manually reset weights to 100% Blue / 0% Green</li>
    <li>Triggered a new deployment successfully</li>
  </ul>

<h2>Key Learnings / Best Practices</h2>
<ul>
  <li>CodeDeploy assumes a known traffic baseline before starting blue/green.</li>
  <li>Manually interrupting deployments can leave infrastructure in a partially transitioned state.</li>
  <li>Gradual traffic shifting and pre-traffic health checks prevent downtime.</li>
  <li>CloudWatch alarms provide early detection of deployment issues.</li>
  <li>Controlled failure testing ensures rollback procedures are effective.</li>
  <li>ECS task definition versioning enables immutable, auditable deployments.</li>
  <li>GitHub OIDC + IAM role assumption avoids hardcoding AWS credentials.</li>
</ul>
</section>

<h2>Technologies Used</h2>
<ul>
  <li>AWS ECS (Fargate)</li>
  <li>AWS CodeDeploy</li>
  <li>Application Load Balancer (ALB)</li>
  <li>Amazon ECR</li>
  <li>CloudWatch + SNS</li>
  <li>GitHub Actions</li>
  <li>Docker (multi-stage builds)</li>
  <li>SonarQube + Trivy Scan</li>
  <li>Bash / jq automation scripts</li>
</ul>

<h2>Screenshots Of My Work</h2>
<ul>
  <li><p>GitHub Actions Worklow</p><img width="630" height="245" alt="Screenshot 2026-02-23 081709" src="https://github.com/user-attachments/assets/de053663-9ad9-4ce0-bcfb-a9eda56c342a" />
</li>
<li>
  <p>CodeDeploy Blue/Green Traffic Shift Process</p> <img width="744" height="311" alt="Screenshot 2026-02-11 195256" src="https://github.com/user-attachments/assets/1ef441e0-701a-47ac-8300-37e976ed6189" />
</li>
<li>
  <p>Alarm Threshold Rollback + Faliure Rollback</p><img width="584" height="425" alt="Screenshot 2026-02-09 181209" src="https://github.com/user-attachments/assets/eb1fc54d-6932-48a4-9153-3d08072bb864" />
</li>
<li><p>Multi-Stage Dockerfile</p><img width="1094" height="352" alt="Screenshot 2026-03-02 185037" src="https://github.com/user-attachments/assets/08556c63-e5f2-4367-a7f7-8134a65f2dd7" />

</li>
  
</ul>

<h2>Notes for Public Repos</h2>
<ul>
  <li>Replace any AWS account IDs, IAM roles, and bucket names with placeholders.</li>
  <li>Do not upload production secrets or <code>.env</code> files.</li>
  <li>Include Dockerfiles, workflow YAMLs, and source code for reproducibility.</li>
</ul>

</body>
</html>
