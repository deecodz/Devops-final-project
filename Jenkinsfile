
pipeline {
    agent any
    environment {
        registry = "derao/webappcal"
        dockerImage = ''
    }
    stages {
        stage('Build Docker image') {
            steps {
                script {
                    dockerImage = docker.build("$registry:${env.BUILD_NUMBER}")
                }
            }
        }

        stage('Login to Docker Hub') {
            steps{
                script {
                    withCredentials([usernamePassword(credentialsId: 'docker', usernameVariable: 'DOCKER_HUB_USERNAME', passwordVariable: 'DOCKER_HUB_PASSWORD')]) {
                        sh "echo $DOCKER_HUB_PASSWORD | docker login --username $DOCKER_HUB_USERNAME --password-stdin"
                    }
                }
            }
        }

        stage('Push Docker image to Docker Hub') {
            steps{
                script {
                    docker.withRegistry( '', 'docker' ) {
                        dockerImage.push("${env.BUILD_NUMBER}")
                    }
                }
            }
        }
    }
}
