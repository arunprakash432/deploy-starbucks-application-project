pipeline {

agent any

environment {
    DOCKER_IMAGE = "dockervarun432/starbucks-app"
    DOCKER_TAG = "${BUILD_NUMBER}"
    EMAIL = "helloarun@gmail.com"
}

tools {
    nodejs "nodejs-18"
}

stages {

stage('Checkout from GitHub') {
    steps {
        git branch: 'main', url: 'https://github.com/arunprakash432/deploy-starbucks-application-project.git'
    }
}

stage('SonarQube Analysis') {
    steps {
        withSonarQubeEnv('sonarqube') {
            withCredentials([string(credentialsId: 'sonarqube-token', variable: 'SONAR_TOKEN')]) {
                sh """
                ${tool 'sonar-scanner'}/bin/sonar-scanner \
                -Dsonar.projectKey=nodejs-project \
                -Dsonar.sources=app \
                -Dsonar.host.url=http://35.154.143.82:9000 \
                -Dsonar.login=$SONAR_TOKEN
                """
            }
        }
    }
}

stage('Install NPM Dependencies') {
    steps {
        dir('app') {
            sh 'npm install'
        }
    }
}

stage('Trivy File System Scan') {
    steps {
        sh 'trivy fs --exit-code 0 --severity HIGH,CRITICAL .'
    }
}

stage('Docker Build Image') {
    steps {
        dir('app') {
            sh 'docker build -t dockervarun432/starbucks-app:latest .'
        }
    }
}

stage('Trivy Image Scan') {
    steps {
        sh 'trivy image dockervarun432/starbucks-app:latest > trivyimage.txt'
    }
}

stage('Push Image to DockerHub') {
    steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
            sh '''
            echo $PASS | docker login -u $USER --password-stdin
            docker push dockervarun432/starbucks-app:latest
            '''
        }
    }
}

stage('Kubernetes Deployment') {
    steps {
            dir('kubernetes') {
                sh 'aws eks update-kubeconfig --region ap-south-1 --name starbucks-eks-cluster'
                sh 'kubectl apply -f manifest.yml'
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