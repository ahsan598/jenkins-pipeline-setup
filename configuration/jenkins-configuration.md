# 🚀 Post-Installation Jenkins Configuration Guide

After installing Jenkins, follow these steps to configure essential **integrations, tools, and credentials** for a production-ready CI/CD environment.


### 🛠️ Install Required Plugins
Navigate to Manage Jenkins → Plugins → Available Plugins and install:

- **Docker Pipeline** - Docker commands in pipeline
- **Kubernetes** - Kubernetes deployment
- **Kubernetes CLI** - Kubectl integration (for K8s many of them are interdependent)
- **SonarQube Scanner** - Code quality analysis
- **OWASP Dependency-Check** - Vulnerability detection
- **Maven Integration** - Maven build support
- **Pipeline Stage View** - Visual pipeline representation
- **Config File Provider** - Configuration file management
- **Email Extension** - Advanced email notifications


### 🔧 Global Tool Configuration
Navigate to **Manage Jenkins** → **Tools** to configure build tools.

**1. JDK (Java Development Kit)**
- Name: jdk21
- Version: Select the stable version

**2. Git**
- Name: git
- Version: auto-install

**3. Maven**
- Name: maven3
- Version: Select the stable version

**4. Docker**
- Name: docker
- Version: auto-install

**5. SonarQube Scanner**
- Name: sonar-scanner
- Version: auto-install


### ⚙️ Configure External Servers
Navigate to **Manage Jenkins** → System to configure **external tool** integrations:

**1. SonarQube Server**
- Name: `sonar`
- Server URL: `http://<YOUR_SERVER_IP>:9000`
- Token: Add via **Credentials → Secret Text**

**2. Nexus Repo**
- Server ID: `nexus`
- Server URL: `http://<YOUR_SERVER_IP>:8081`
- Credentials: Nexus credentials

**3. DockerHub Registry**
- Registry URL: default
- Credentials: DockerHub credentials

**4. GitHub Integration**
- Add GitHub Personal Access Token (PAT)

**5. Email (SMTP)**
- Server: `smtp.gmail.com`
- Port: `465` (SSL) or `587` (TLS)
- Username: Your email
- Password: Use App Password if using Gmail


### Credentials Setup
Navigate to Manage Jenkins → Credentials → Global → Add Credentials

| ID                      | Type              | Used For               |
| ----------------------- | ----------------- | ---------------------- |
| `dockerhub-credentials` | Username/Password | Push Docker images     |
| `github-token`          | Secret text       | GitHub API + Webhooks  |
| `sonarqube-token`       | Secret text       | Sonar analysis         |
| `nexus-credentials`     | Username/Password | Artifact upload        |



### 🚀 Next Steps

**Create your first Pipeline:**
1. Navigate to **New Item → Pipeline**
2. Enter a name (e.g., **CI-Pipeline**), select **Pipeline**, and click **OK**
3. In **Build History**, limit retained builds (recommended: **3 builds**)
4. Add your **Pipeline Script** in the Pipeline section
5. Use the **Pipeline Syntax Generator** to build stages or paste your existing **Jenkinsfile**
6. Configure GitHub webhook to: `http://<jenkins-url>:8080/github-webhook/`


🎉 Setup Complete — Jenkins is now fully configured for enterprise-grade CI/CD!
