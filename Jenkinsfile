pipeline {
    agent any
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        stage('SonarQube Analysis') {
            steps {
                sh "ls /opt"
                sh "ls /opt/sonar-scanner"
                sh "ls /opt/sonar-scanner/bin"
                withSonarQubeEnv('sonarqube') {
                    sh "/opt/sonar-scanner/bin/sonar-scanner \
                    -Dsonar.projectKey=my-node-app \
                    -Dsonar.sources=. \
                    -Dsonar.host.url=${env.SONAR_HOST_URL} \
                    -Dsonar.login=${env.SONAR_AUTH_TOKEN} \
                    -Dsonar.qualitygate.wait=true \
                    -Dsonar.qualitygate.timeout=300"
                }
            }
        }
        stage('Build') {
            steps {
                sh 'docker build . -t $AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/my-node-app'
            }
        }
        stage('Push Image') {
            steps {
                sh 'aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com'
                sh 'aws ecr describe-repositories --repository-names my-node-app || aws ecr create-repository --repository-name my-node-app'
                sh 'docker push $AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/my-node-app'
            }
        }
        stage('Deploy') {
            steps {
                sh 'docker pull $AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/my-node-app'
                sh 'docker rm -f my-node-app || true'
                sh 'docker run -d -p "2222:3000" --name my-node-app $AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/my-node-app'
            }
        }
    }
}