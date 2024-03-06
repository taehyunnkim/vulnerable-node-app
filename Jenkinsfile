pipeline {
    agent any

    environment { 
        APP_NAME = 'my-node-app'
        EXPOSE_PORT = 2222
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
                    -Dsonar.projectKey=${APP_NAME} \
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
                sh "docker build . -t $AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/${APP_NAME}"
            }
        }
        stage('Trivy Vulnerability Scan') {
            steps {
                sh "trivy image --format template --template '@/usr/local/share/trivy/templates/html.tpl' --output trivy-report.html --severity HIGH,CRITICAL $AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/${APP_NAME}"
            }
        }
        stage('Push Image') {
            steps {
                sh 'aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com'
                sh "aws ecr describe-repositories --repository-names ${APP_NAME} || aws ecr create-repository --repository-name ${APP_NAME}"
                sh "docker push $AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/${APP_NAME}"
            }
        }
        stage('Deploy') {
            steps {
                sh "docker pull $AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/${APP_NAME}"
                sh "docker rm -f ${APP_NAME} || true"
                sh "docker run -d -p '${EXPOSE_PORT}:3000' --name ${APP_NAME} $AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/${APP_NAME}"
            }
        }
    }
}