pipeline {
    agent {
        docker {
            image 'docker:24.0.1-dind'
            args '--user root -v /var/run/docker.sock:/var/run/docker.sock'
        }
    }

    environment {
        DOCKER_IMAGE = "xalien073/custom-dind-python-sonar-trivy:${env.BUILD_ID}"
        SONAR_URL = 'http://your-sonarqube-server:9000'
    }

    stages {
        stage('Checkout') {
            steps {
                sh 'echo ✅ Checkout passed!'
            }
        }

        stage('Static Code Analysis') {
            steps {
                withCredentials([string(credentialsId: 'sonarqube', variable: 'SONAR_AUTH_TOKEN')]) {
                    sh """
                        apk update && apk add --no-cache openjdk11 curl unzip python3 py3-pip git jq
                        curl -o sonar-scanner.zip -L https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.7.0.2747-linux.zip
                        unzip sonar-scanner.zip -d /opt
                        ln -s /opt/sonar-scanner-4.7.0.2747-linux/bin/sonar-scanner /usr/bin/sonar-scanner
                        sed -i 's/use_embedded_jre=true/use_embedded_jre=false/' /opt/sonar-scanner-4.7.0.2747-linux/bin/sonar-scanner
                        
                        wget -O trivy.tar.gz "https://github.com/aquasecurity/trivy/releases/download/v0.60.0/trivy_0.60.0_Linux-64bit.tar.gz"
                        tar -xvzf trivy.tar.gz -C /opt
                        ln -s /opt/trivy /usr/bin/trivy
                        
                        sonar-scanner --version
                        trivy --version
                    """    
                        // echo "🚀 Running SonarQube Analysis..."
                        // sonar-scanner \
                        // -Dsonar.projectKey=Custom-DinD \
                        // -Dsonar.sources=. \
                        // -Dsonar.host.url=${SONAR_URL} \
                        // -Dsonar.login=${SONAR_AUTH_TOKEN} \
                        // -Dsonar.qualitygate.wait=true
                    
                }
            }
        }

        // stage('Quality Gate') {
        //     steps {
        //         script {
        //             withCredentials([string(credentialsId: 'sonarqube', variable: 'SONAR_AUTH_TOKEN')]) {
        //                 def status = sh(script: """
        //                     curl -s -u ${SONAR_AUTH_TOKEN}: "${SONAR_URL}/api/qualitygates/project_status?projectKey=Custom-DinD" | jq -r .projectStatus.status
        //                 """, returnStdout: true).trim()

        //                 if (status != "OK") {
        //                     error "❌ Quality Gate Failed! Stopping pipeline."
        //                 } else {
        //                     echo "✅ Quality Gate Passed!"
        //                 }
        //             }
        //         }
        //     }
        // }

        stage('Build Docker Image') {
            steps {
                sh """
                    docker --version
                    echo "🐳 Building Docker image..."
                    docker build -t $DOCKER_IMAGE .
                """
            }
        }

        stage('Scan Docker Image') {
            steps {
                sh """
                    echo "🔍 Scanning Docker image with Trivy..."
                    trivy image --exit-code 1 --severity CRITICAL $DOCKER_IMAGE
                """
            }
        }

        stage('Run Container for Testing') {
            steps {
                script {
                    def container_id = sh(script: "docker run -d --privileged --name test-dind-container $DOCKER_IMAGE", returnStdout: true).trim()
                    
                    // Check if the container is running
                    def running = sh(script: "docker ps -q -f id=${container_id}", returnStdout: true).trim()
                    
                    if (running) {
                        echo "✅ Container is running successfully!"
                    } else {
                        error "❌ Container failed to start! Stopping pipeline."
                    }
                }
            }
        }

        stage('Push to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                }
                sh "docker push $DOCKER_IMAGE"
            }
        }

        stage('Cleanup') {
            steps {
                sh 'docker stop test-dind-container || true'
                sh 'docker rm test-dind-container || true'
                sh 'docker rmi $DOCKER_IMAGE || true'
            }
        }
    }
}
