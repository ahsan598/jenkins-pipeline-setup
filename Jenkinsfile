pipeline {
    agent any

    tools {
        jdk 'jdk21'
        maven 'maven3'
    }

    environment {
        DOCKER_REGISTRY = 'docker.io'
        IMAGE_NAME = 'username/myapp'
    }

    stages {
        stage('Git Checkout') { 
            steps {
                git branch: 'main', 
                    url: 'https://github.com/repo/repo_name.git',
                    credentialsId: 'github-token'
            }
        }
        stage('Code Compile') {
            steps {
                sh "mvn clean compile"
            }
        }
        stage('Unit Tests') {
            steps {
                sh "mvn test"
            }
            post {
                always {
                    junit '**/target/surefire-reports/*.xml'
                }
            }
        }
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonar') {
                    sh 'mvn sonar:sonar'
                }
            }
        }
        stage('Quality Gate') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }
        stage('OWASP Dependency Check') {
            steps {
                dependencyCheck additionalArguments: '--scan ./ --format HTML --out dependency-check-report.html', 
                                odcInstallation: 'DC'
            }
        }
        stage('Build Artifact') {
            steps {
                sh "mvn package -DskipTests=true"
            }
        }
        stage('Deploy to Nexus') {
            steps {
                withMaven(globalMavenSettingsConfig: 'global-maven', traceability: true)  {
                    sh "mvn deploy -DskipTests=true"
                }
            }
        }
        stage('Docker Build & Tag') {
            steps {
                script {
                    docker.build("${IMAGE_NAME}:${BUILD_NUMBER}", "-f docker/Dockerfile .")
                    sh "docker tag ${IMAGE_NAME}:${BUILD_NUMBER} ${IMAGE_NAME}:latest"
                }
            }
        }
        stage('Trivy Scan') {
            steps {
                script {
                    sh "trivy image --format table -o trivy-image-report.html ${IMAGE_NAME}:${BUILD_NUMBER}"
                }
            }
        }
        stage('Push to Registry') {
            steps {
                script {
                    withDockerRegistry(credentialsId: 'docker-cred', url: "https://${DOCKER_REGISTRY}") {
                        sh "docker push ${IMAGE_NAME}:latest"
                    }
                }
            }
        }
        stage('Deploy To Kubernetes') {
            steps {
               withKubeConfig(caCertificate: '', clusterName: 'kubernetes', contextName: '', credentialsId: 'k8s-cred', namespace: 'webapps', restrictKubeConfigAccess: false, serverUrl: 'https://172.31.8.146:6443') {
                        sh "kubectl apply -f manifest/deployment-service.yaml"
                }
            }
        }
        stage('Verify the Deployment') {
            steps {
               withKubeConfig(caCertificate: '', clusterName: 'kubernetes', contextName: '', credentialsId: 'k8s-cred', namespace: 'webapps', restrictKubeConfigAccess: false, serverUrl: 'https://172.31.8.146:6443') {
                        sh "kubectl get pods -n webapps"
                        sh "kubectl get svc -n webapps"
                }
            }
        }
    }
    post {
        success {
            script {
                echo 'Pipeline completed successfully!'
                def deploymentUrl = "http://your-app-url:${env.BUILD_NUMBER}"
                
                emailext (
                    subject: "Build Success: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                    body: """<p>Build completed successfully!</p>
                             <p>Job: ${env.JOB_NAME}</p>
                             <p>Build: ${env.BUILD_NUMBER}</p>
                             <p>Docker Image: ${IMAGE_NAME}:${env.BUILD_NUMBER}</p>
                             <p>Check Console: <a href="${env.BUILD_URL}console">Console</a></p>""",
                    to: "team@example.com",
                    mimeType: 'text/html'
                )
            }
        }

        failure {
            script {
                echo 'Pipeline failed!'
                emailext (
                    subject: "Build Failed: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                    body: """<p>Build Failed!</p>
                             <p>Job: ${env.JOB_NAME}</p>
                             <p>Build: ${env.BUILD_NUMBER}</p>
                             <p>Check Console: <a href="${env.BUILD_URL}console">Console</a></p>""",
                    to: "team@example.com",
                    mimeType: 'text/html'
                )
            }
        }
        always {
            echo 'Cleaning up workspace...'
            // Archive artifacts
            archiveArtifacts artifacts: '**/trivy-report.json, **/dependency-check-report.html', 
                             allowEmptyArchive: true
            cleanWs()
        }
    }
}
