pipeline {
    agent any

    environment { 
        APP_NAME = 'my-node-app'
        EXPOSE_PORT = 2000
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonarqube') {
                    sh "/opt/sonar-scanner/bin/sonar-scanner \
                    -Dsonar.projectKey=${env.APP_NAME} \
                    -Dsonar.sources=. \
                    -Dsonar.exclusions=trivy-report.html \
                    -Dsonar.host.url=${env.SONAR_HOST_URL} \
                    -Dsonar.login=${env.SONAR_AUTH_TOKEN} \
                    -Dsonar.qualitygate.wait=true \
                    -Dsonar.qualitygate.timeout=300"
                }
            }
        }
        stage('Build') {
            steps {
                sh "docker build . -t ${AWS_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${env.APP_NAME}"
            }
        }
        stage('Trivy Vulnerability Scan') {
            steps {
                sh "trivy image --exit-code 1 --severity HIGH,CRITICAL ${AWS_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${env.APP_NAME}"    
            }
        }
        stage('Push Image') {
            steps {
                sh 'aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com'
                sh "aws ecr describe-repositories --repository-names ${env.APP_NAME} || aws ecr create-repository --repository-name ${env.APP_NAME}"
                sh "docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${env.APP_NAME}"
            }
        }
        stage('Deploy') {
            steps {
                sh "docker pull ${AWS_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${env.APP_NAME}"
                sh "docker rm -f ${env.APP_NAME} || true"
                sh "docker run -d -p '${env.EXPOSE_PORT}:3000' --name ${env.APP_NAME} ${AWS_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${env.APP_NAME}"
            }
        }
    }
}