# 🚀 Jenkins CI/CD Pipeline Setup

A beginner-friendly CI/CD setup on AWS. This will demonstrates a hybrid architecture:
- **Jenkins**: Runs directly on the EC2 instance.
- **SonarQube & Nexus**: Run as Docker containers for easy management.
- **Security**: Integrated with Trivy for vulnerability scanning.


### 🎯 Architecture Overview

| Component     | Hosted On             | Why?                                                          |
|---------------|-----------------------|---------------------------------------------------------------|
| **Jenkins**   | **EC2 Instance (VM)** | Gives Jenkins full access to the host for executing shell scripts and Docker commands easily.     |
| **SonarQube** | **Docker Container**  | Keeps the database and dependencies isolated; easy to spin up/down.           |
| **Nexus**     | **Docker Container**  | Simplifies storage management and updates.                    |
| **Trivy**     | **EC2 Instance (VM)** | Installed directly for scanning files and images.             |

### 📂 Repository Structure
This repo contains the configurations and scripts used in the pipeline.
```txt
├── Jenkinsfile        # The main pipeline script
├── scripts/           # Tools scripts (Jenkins, Docker, Trivy)
├── config/            # Tools Configuration
└── README.md          # This documentation
```

---

### 🛠️ Prerequisites

Before you start, ensure you have:
1. **AWS EC2 Instance**: Ubuntu 24.04 or Amazon Linux 2024 (t3.medium recommended).
2. **Security Group Ports**: Open these ports in your AWS Security Group:
   - `8080` (Jenkins)
   - `9000` (SonarQube)
   - `8081` (Nexus)
   - `22` (SSH)


### ⚙️ Setup Guide

We follow the official documentation for installations to ensure you always get the latest stable versions.

**Step-1: Install Docker**

Follow the official guide to install Docker Engine on your instance.
👉 **[Official Docker Installation Guide (Ubuntu)](https://docs.docker.com/engine/install/ubuntu/)**

**⚠️ Critical Configuration (After Install):**

Once Docker is installed, you **must** configure permissions so Jenkins can run Docker commands later.

```bash
# 1. Add current user to docker group
sudo usermod -aG docker $USER

# 2. Apply permissions to Docker socket
sudo chmod 666 /var/run/docker.sock
```


**Step-2: Install Jenkins (Using Script)**

Follow the official guide to install Jenkins (Debian/Ubuntu).
👉 [Official Jenkins Installation Guide](https://www.jenkins.io/doc/book/installing/linux/#debianubuntu)

📝 Notes:
- Ensure you install Java 17 or Java 21 (required by Jenkins).
- After installation, run this command to give Jenkins access to Docker:

```sh
# Add Jenkins to Docker group
sudo usermod -aG docker jenkins

# Restart Jenkins to apply changes
sudo systemctl restart jenkins
```

**Step-3: Install Trivy**

Follow the official guide to install the Trivy security scanner.
👉 [Official Trivy Installation Guide](https://trivy.dev/docs/latest/getting-started/installation/)


**Step-4: Run SonarQube & Nexus (In Containers)**

Since these run in containers, simply execute the following commands to start them with the correct network and volume settings.

**1. Create a Network**
```sh
# Create dedicated Docker network
sudo docker network create sonarnet
```

**2. Start SonarQube & Database**
```sh
# PostgreSQL Database for SonarQube
sudo docker run -d \
  --name sonar-db \
  --network sonarnet \
  -e POSTGRES_USER=sonar \
  -e POSTGRES_PASSWORD=sonar \
  -e POSTGRES_DB=sonar \
  -v postgres-data:/var/lib/postgresql/data \
  postgres:18-alpine

# SonarQube Server
sudo docker run -d \
  --name sonarqube \
  --network sonarnet \
  -p 9000:9000 \
  -e SONAR_JDBC_URL=jdbc:postgresql://sonar-db:5432/sonar \
  -e SONAR_JDBC_USERNAME=sonar \
  -e SONAR_JDBC_PASSWORD=sonar \
  -v sonarqube-data:/opt/sonarqube/data \
  sonarqube:community
```

**3. Start Nexus**
```sh
sudo docker run -d \
  --name nexus \
  -p 8081:8081 \
  -v nexus-data:/nexus-data \
  sonatype/nexus3:3.87.0
```


### 🔍 Accessing Your Tools
Once installed, access your tools via your browser:
| Tool      | URL                       | Default Creds (First Login)                       |
| --------- | ------------------------- | ------------------------------------------------- |
| Jenkins   | http://<your-ec2-ip>:8080 | cat /var/lib/jenkins/secrets/initialAdminPassword |
| SonarQube | http://<your-ec2-ip>:9000 | admin / admin                                     |
| Nexus     | http://<your-ec2-ip>:8081 | Inside container: /nexus-data/admin.password      |


### 📝 Pipeline Workflow
- **Git Checkout:** Jenkins pulls code from this repo.
- **Build:** Compiles the application.
- **SonarQube Analysis:** Checks code quality.
- **Trivy Scan:** Scans filesystem using scripts in scripts/.
- **Nexus Push:** Uploads the artifact.
- **Docker Build & Push:** Creates image and pushes to registry.

---

### 📚 References

- [Jenkins Docs](https://www.jenkins.io/doc/)
- [Jenkins Pipeline Syntax](https://www.jenkins.io/doc/book/pipeline/syntax/)
- [Docker Docs](https://docs.docker.com/)
- [Trivy Docs](https://trivy.dev/docs/)
- [SonarQube Docs](https://docs.sonarsource.com/sonarqube-server)
- [Nexus Docs](https://help.sonatype.com/en/sonatype-nexus-repository.html)
