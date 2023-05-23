pipeline {
    agent any
    environment {
        registry = "derao/webappcal"
        dockerImage = ''
        DEPLOYMENT_NAME = 'webappcal' 
        NAMESPACE = 'dev' 
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

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    kubeconfig(credentialsId: 'k8s') {
                        sh("""
                            kubectl apply -f k8s-depl-manifest.yml
                            kubectl rollout status deployment/${DEPLOYMENT_NAME} -n ${NAMESPACE}
                        """)
                    }
                }
            }
        }

        stage('Get Service DNS') {
            steps {
                script {
                    kubeconfig(credentialsId: 'k8s') {
                        def dns = sh(script: "kubectl get svc ${DEPLOYMENT_NAME} -n ${NAMESPACE} -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'", returnStdout: true).trim()
                        echo "Service DNS: ${dns}"
                    }
                }
            }
        }
    }
}