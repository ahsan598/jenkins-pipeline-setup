# Tools Configuration Guide


### ⚙️ Jenkins Configuration Guide
After installing Jenkins, follow these exact steps to connect it with Docker, SonarQube, and Nexus.

### 🛠️ Install Plugins
Go to: **Manage Jenkins → Plugins → Available Plugins**

Search for and install these key plugins:
- **Docker Pipeline** (for building/pushing images)
- **SonarQube Scanner** (for code analysis)
- **Pipeline: Stage View** (for better UI)
- **Config File Provider** (Critical for Nexus integration)
- **Eclipse Temurin Installer** (optional, if you want Jenkins to manage Java versions)
- **OWASP Dependency-Check** - Vulnerability detection
- **Maven Integration** - Maven build support
- **Email Extension** - Advanced email notifications

---

### 🔧 Global Tool Configuration
Go to: **Manage Jenkins → Tools**

**1. JDK (Java Development Kit)**
- Name: `jdk21`
- Version: Select the stable version

**2. Maven**
- Name: `maven3`
- Version: auto-install

**3. SonarQube Scanner**
- Name: `sonar-scanner`
- Version: auto-install

---

### ⚙️ Configure System Integrations
Go to: **Manage Jenkins → System**

**1. SonarQube Server**
- Name: `sonar`
- Server URL: `http://<YOUR_EC2-PUBLIC_IP>:9000`
- Token: Add via **Credentials → Secret Text**

**2. Nexus Repo**
- Server ID: `nexus`
- Server URL: `http://<YOUR_EC2-PUBLIC_IP>:8081`
- Credentials: Nexus credentials

**3. DockerHub Registry**
- Registry URL: default
- Credentials: DockerHub credentials

**4. GitHub Integration**
- Add GitHub Personal Access Token (PAT)

**5. Email (Optional)**
- Server: `smtp.gmail.com`
- Port: `465` (SSL) or `587` (TLS)
- Username: Your email
- Password: Use App Password if using Gmail


### 🔐 Credentials Setup
Go to: **Manage Jenkins → Credentials → System → Global credentials**

| Kind                   | ID                    | Secret / Password                          | Description         |
| ---------------------- | --------------------- | ------------------------------------------ | ------------------- |
| Secret Text            | sonarqube-token       | (Paste token from SonarQube User Settings) | SonarQube Auth      |
| Username with Password | dockerhub-credentials | (Your DockerHub Username & Password)       | For pushing images  |
| Username with Password | nexus-credentials     | admin / (Your Nexus Password)              | For Nexus artifacts |
| Secret Text            | github-token          | (Your GitHub PAT)                          | For Git checkout    |


### 🚀 Next Steps

**Create your first Pipeline:**
1. Navigate to **New Item → Pipeline**
2. Enter a name (e.g., **CI-Pipeline**), select **Pipeline**, and click **OK**
3. In **Build History**, limit retained builds (recommended: **3 builds**)
4. Add your **Pipeline Script** in the Pipeline section
5. Use the **Pipeline Syntax Generator** to build stages or paste your existing **Jenkinsfile**
6. Configure GitHub webhook to: `http://<jenkins-url>:8080/github-webhook/`


---

### ⚙️ Configure Nexus Repositories
Login to Nexus (admin/password) and create these repositories:

**1. Maven Releases (Hosted)**
   - Used for: Stable production artifacts.
   - Name: `maven-releases`
   - Version Policy: `Release`
   - Deployment Policy: **Disable Redeploy** (Important for security)

**2. Maven Snapshots (Hosted)**
   - Used for: Development artifacts.
   - Name: `maven-snapshots`
   - Version Policy: `Snapshot`
   - Deployment Policy: **Allow Redeploy**

**3. Maven Group (Group) - ⚠️ CRITICAL**
   - Used for: Single access point for Jenkins.
   - Name: `maven-public`
   - **Members**: Add `maven-releases`, `maven-snapshots`, and `maven-central` to the members list.
