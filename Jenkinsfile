pipeline {
    agent any

    tools {
        jdk 'JDK-21'          // Ensure this matches jenkins tool name
        maven 'Maven-3.9'     // Ensure this matches jenkins tool name
    }

    environment {
        DOCKER_REGISTRY = 'docker.io'                         // Docker Hub registry
        DOCKER_IMAGE = 'user_id/myapp:${BUILD_NUMBER}'       // Use build number for versioning
        SONAR_HOST = 'http://<server_ip>:9000'
        NEXUS_URL = 'http://<server_ip>:8081'
        K8S_NAMESPACE = 'webapps'                           // Kubernetes namespace
        K8S_SERVER = 'https://<server_ip>:6443'            // Kubernetes API server
    }

    stages {
        stage('Git Checkout') { 
            steps {
                git branch: 'main', 
                    url: 'https://github.com/repo/repo_name.git',
                    credentialsId: 'github-token'           // Add if private repo
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
                dependencyCheck additionalArguments: '--scan ./ --format HTML', 
                                odcInstallation: 'DC'
                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }

        stage('Build Application') {
            steps {
                sh "mvn package -DskipTests=true"
            }
        }

        stage('Deploy to Nexus') {
            steps {
                script {
                    withMaven(globalMavenSettingsConfig: 'global-maven', 
                              traceability: true) {
                        sh "mvn deploy -DskipTests=true"
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${DOCKER_IMAGE} -f docker/Dockerfile ."
                    sh "docker tag ${DOCKER_IMAGE} ${DOCKER_IMAGE//BUILD_NUMBER/latest}"
                }
            }
        }

        stage('Trivy Image Scan') {
            steps {
                script {
                    sh """
                        trivy image \
                          --severity HIGH,CRITICAL \
                          --format json \
                          -o trivy-report.json \
                          ${DOCKER_IMAGE}
                    """
                    
                    // Generate HTML report
                    sh """
                        trivy image \
                          --format template \
                          --template '@/usr/local/share/trivy/templates/html.tpl' \
                          -o trivy-image-report.html \
                          ${DOCKER_IMAGE}
                    """
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    withDockerRegistry(credentialsId: 'docker-cred', 
                                       url: "https://${DOCKER_REGISTRY}") {
                        sh "docker push ${DOCKER_IMAGE}"
                        sh "docker push ${DOCKER_IMAGE//BUILD_NUMBER/latest}"
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    withKubeConfig(
                        credentialsId: 'k8s-cred',
                        namespace: "${K8S_NAMESPACE}",
                        serverUrl: "${K8S_SERVER}"
                    ) {
                        // Update image in deployment
                        sh """
                            sed -i 's|image:.*|image: ${DOCKER_IMAGE}|g' deployment-service.yaml
                            kubectl apply -f deployment-service.yaml
                        """
                    }
                }
            }
        }
        
        stage('Verify Deployment') {
            steps {
                script {
                    withKubeConfig(
                        credentialsId: 'k8s-cred',
                        namespace: "${K8S_NAMESPACE}",
                        serverUrl: "${K8S_SERVER}"
                    ) {
                        sh "kubectl get pods -n ${K8S_NAMESPACE}"
                        sh "kubectl get svc -n ${K8S_NAMESPACE}"
                        
                        // Wait for rollout
                        sh "kubectl rollout status deployment/myapp -n ${K8S_NAMESPACE}"
                    }
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully!'
            script {
                def deploymentUrl = "http://your-app-url"
                emailext (
                    subject: "Build Success: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                    body: """
                        Build completed successfully!
                        
                        Job: ${env.JOB_NAME}
                        Build: ${env.BUILD_NUMBER}
                        Docker Image: ${DOCKER_IMAGE}
                        Application URL: ${deploymentUrl}
                        
                        Console Output: ${env.BUILD_URL}console
                    """,
                    to: "team@example.com"
                )
            }
        }

        failure {
            echo 'Pipeline failed!'
            emailext (
                subject: "Build Failed: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: """
                    Build failed!
                    
                    Job: ${env.JOB_NAME}
                    Build: ${env.BUILD_NUMBER}
                    
                    Check console output: ${env.BUILD_URL}console
                """,
                to: "team@example.com"
            )
        }

        always {
            echo 'Cleaning up workspace...'
            
            // Archive reports
            archiveArtifacts artifacts: '**/trivy-*.html, **/dependency-check-report.html', 
                             allowEmptyArchive: true
            
            // Publish test results
            junit allowEmptyResults: true, testResults: '**/target/surefire-reports/*.xml'
            
            // Clean workspace
            cleanWs()
        }
    }
}
