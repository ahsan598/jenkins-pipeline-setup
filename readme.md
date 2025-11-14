# 🚀 Jenkins CI/CD Pipeline Setup (Multi-Instance on AWS)

A production-grade CI/CD architecture powered by **Jenkins**, integrated with **Docker, SonarQube, Nexus, and Trivy** for secure and automated software delivery — deployed across dedicated AWS EC2 instances.


### 🎯 Overview
This setup provisions a complete **DevOps pipeline** distributed across multiple EC2 instances for scalability and fault isolation:
| Instance               | Purpose                     | Key Tools                  |
| ---------------------- | --------------------------- | -------------------------- |
| **Jenkins Server**     | CI/CD Orchestration         | Jenkins, Docker, Trivy     |
| **SonarQube Server**   | Code Quality & Security     | SonarQube, PostgreSQL      |
| **Nexus Server**       | Artifact & Image Repository | Nexus Repository Manager 3 |
| **Kubernetes Cluster** | Application Deployment      | Kubernetes, kubectl, Helm  |


### 🎯 Key Objectives
- Automate CI/CD pipelines using **Jenkins Declarative Pipelines**
- Integrate **SonarQube** for code quality & security checks
- Manage build artifacts via **Nexus Repository**
- Use **Trivy** for vulnerability scanning
- Deploy containerized apps to **Kubernetes**


### 🧠 Pipeline Workflow
```txt
Developer → Git Push → Jenkins Pipeline → SonarQube Scan → Trivy Scan → Nexus Upload → Docker Build & Push → Kubernetes Deployment
```


### 📂 Project Structure:
```txt
Jenkins-Pipeline-Setup/
├── Jenkins
├── SonarQube
├── Nexus
├── scripts/
├── configs/
└── files/
```


### ⚙️ Setup Overview
| Phase                   | Description                                                     |
| ----------------------- | --------------------------------------------------------------- |
| **1. Jenkins Setup**    | Install Jenkins, Docker, Trivy; configure plugins & credentials |
| **2. SonarQube Setup**  | Deploy SonarQube + PostgreSQL for static code analysis          |
| **3. Nexus Setup**      | Run Nexus Repository for Maven/Docker artifact storage          |
| **4. Kubernetes Setup** | Deploy cluster and connect Jenkins via kubeconfig               |
| **5. CI/CD Pipeline**   | Automate build, test, scan, and deploy workflow                 |


### 📦 Pipeline Stages
1. Checkout Source Code
2. Build & Unit Test
3. SonarQube Code Analysis
4. Trivy Security Scan
5. Publish Artifacts to Nexus
6. Build & Push Docker Image
7. Deploy to Kubernetes Cluster


### 🔍 Access & Ports
| Tool                                | Port     | URL Example                    |
| ----------------------------------- | -------- | ------------------------------ |
| **Jenkins**                         | `8080`   | http://<jenkins-ip>:8080       |
| **SonarQube**                       | `9000`   | http://<sonarqube-ip>:9000     |
| **Nexus**                           | `8081`   | http://<nexus-ip>:8081         |
| **Kubernetes Dashboard (optional)** | `30000+` | http://<k8s-master>:<nodeport> |

> 🔐 Ensure these ports are allowed in the AWS Security Group for respective EC2 instances.


### 🔧 Toolchain Summary
| Tool           | Function               | Instance Type             |
| -------------- | ---------------------- | ------------------------- |
| **Jenkins**    | Pipeline Orchestration | EC2 (t3.medium)           |
| **SonarQube**  | Code Quality Analysis  | EC2 (t3.medium)           |
| **Nexus**      | Artifact Repository    | EC2 (t3.medium)           |
| **Trivy**      | Security Scanning      | Installed on Jenkins node |
| **Kubernetes** | Application Deployment | Multi-node cluster        |


### 🏁 Conclusion
This architecture delivers a secure, scalable, and automated CI/CD pipeline across AWS instances — enabling faster, reliable, and policy-compliant software delivery.

---

### 📚 References

- [Jenkins Docs](https://www.jenkins.io/doc/)
- [Jenkins Pipeline Syntax](https://www.jenkins.io/doc/book/pipeline/syntax/)
- [Docker Docs](https://docs.docker.com/)
- [Trivy Docs](https://trivy.dev/docs/)
- [SonarQube Docs](https://docs.sonarsource.com/sonarqube-server)
- [Nexus Docs](https://help.sonatype.com/en/sonatype-nexus-repository.html)
- [Kubernetes Docs](https://kubernetes.io/docs/home/)