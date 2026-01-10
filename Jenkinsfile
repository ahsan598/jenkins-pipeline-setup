pipeline {
    agent any

    tools {
        jdk 'JDK-21'
        maven 'Maven-3'
    }

    environment {
        DOCKER_REGISTRY = 'docker.io'
        IMAGE_NAME = 'username/myapp' 
        SONAR_HOST = 'http://<server_ip>:9000'
        NEXUS_URL = 'http://<server_ip>:8081'
    }

    stages {
        stage('Cleanup Workspace') {
            steps {
                cleanWs()
            }
        }
        
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

        stage('Run Tests') {
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
                
                publishHTML([allowMissing: true, 
                             alwaysLinkToLastBuild: true, 
                             keepAll: true, 
                             reportDir: '.', 
                             reportFiles: 'dependency-check-report.html', 
                             reportName: 'OWASP Dependency Check'])
            }
        }

        stage('Build Application') {
            steps {
                sh "mvn package -DskipTests=true"
            }
        }

        stage('Deploy to Nexus') {
            steps {
                configFileProvider([configFile(fileId: 'global-maven', variable: 'MAVEN_SETTINGS')]) {
                    sh "mvn deploy -s $MAVEN_SETTINGS -DskipTests=true"
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${IMAGE_NAME}:${BUILD_NUMBER}", "-f docker/Dockerfile .")
                    sh "docker tag ${IMAGE_NAME}:${BUILD_NUMBER} ${IMAGE_NAME}:latest"
                }
            }
        }

        stage('Trivy Image Scan') {
            steps {
                script {
                    // JSON Report
                    sh "trivy image --severity HIGH,CRITICAL --format json -o trivy-report.json ${IMAGE_NAME}:${BUILD_NUMBER}"
                    sh "trivy image --severity HIGH,CRITICAL --format table ${IMAGE_NAME}:${BUILD_NUMBER}"
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    withDockerRegistry(credentialsId: 'docker-cred', url: "https://${DOCKER_REGISTRY}") {
                        sh "docker push ${IMAGE_NAME}:${BUILD_NUMBER}"
                        sh "docker push ${IMAGE_NAME}:latest"
                    }
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
