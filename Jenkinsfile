pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "yourdockerhubusername/nodejs-app"
        DOCKER_TAG = "${BUILD_NUMBER}"
        SONAR_SERVER = "sonarqube-server"
        EMAIL = "yourmail@gmail.com"
    }

    tools {
        nodejs "nodejs-18"
    }

    stages {

        stage('Checkout from GitHub') {
            steps {
                git branch: 'main', url: 'https://github.com/yourusername/your-repo.git'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv("${SONAR_SERVER}") {
                    sh '''
                    sonar-scanner \
                    -Dsonar.projectKey=nodejs-project \
                    -Dsonar.sources=. \
                    -Dsonar.host.url=$SONAR_HOST_URL \
                    -Dsonar.login=$SONAR_AUTH_TOKEN
                    '''
                }
            }
        }

        stage('Install NodeJS') {
            steps {
                sh 'node -v'
                sh 'npm -v'
            }
        }

        stage('Install NPM Dependencies') {
            steps {
                sh 'npm install'
            }
        }

        stage('Trivy File System Scan') {
            steps {
                sh 'trivy fs --exit-code 0 --severity HIGH,CRITICAL .'
            }
        }

        stage('Docker Build Image') {
            steps {
                sh 'docker build -t $DOCKER_IMAGE:$DOCKER_TAG .'
            }
        }

        stage('Trivy Image Scan') {
            steps {
                sh 'trivy image --exit-code 0 --severity HIGH,CRITICAL $DOCKER_IMAGE:$DOCKER_TAG'
            }
        }

        stage('Push Image to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                    sh '''
                    echo $PASS | docker login -u $USER --password-stdin
                    docker push $DOCKER_IMAGE:$DOCKER_TAG
                    '''
                }
            }
        }

        stage('Kubernetes Deployment') {
            steps {
                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                    sh '''
                    kubectl apply -f manifest.yaml
                    '''
                }
            }
        }
    }

    post {

        success {
            mail to: "${EMAIL}",
            subject: "SUCCESS: Jenkins Build #${BUILD_NUMBER}",
            body: "Deployment successful! Docker image pushed and Kubernetes deployment completed."
        }

        failure {
            mail to: "${EMAIL}",
            subject: "FAILED: Jenkins Build #${BUILD_NUMBER}",
            body: "Pipeline failed. Please check Jenkins logs."
        }
    }
}