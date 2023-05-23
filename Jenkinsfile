pipeline {
    agent any
    environment {
        registry = "derao/webappcal"
        dockerImage = ''
        DEPLOYMENT_NAME = 'webappcal'
        NAMESPACE = 'dev'
        KUBECONFIG_PATH = '/tmp/kubeconfig'
    }
    stages {
        stage('Build Docker image') {
            steps {
                // Build Docker image
                script {
                    dockerImage = docker.build("$registry:${env.BUILD_NUMBER}")
                }
            }
        }

        stage('Login to Docker Hub') {
            steps {
                // Login to Docker Hub
                script {
                    withCredentials([usernamePassword(credentialsId: 'docker', usernameVariable: 'DOCKER_HUB_USERNAME', passwordVariable: 'DOCKER_HUB_PASSWORD')]) {
                        sh "echo $DOCKER_HUB_PASSWORD | docker login --username $DOCKER_HUB_USERNAME --password-stdin"
                    }
                }
            }
        }

        stage('Push Docker image to Docker Hub') {
            steps {
                // Push Docker image to Docker Hub
                script {
                    docker.withRegistry('', 'docker') {
                        dockerImage.push("${env.BUILD_NUMBER}")
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                // Retrieve kubeconfig credential
                withCredentials([file(credentialsId: 'k8s', variable: 'KUBECONFIG_FILE')]) {
                    // Write kubeconfig to file
                    sh "echo \$KUBECONFIG_FILE | base64 --decode > ${env.KUBECONFIG_PATH}"
                    // Apply deployment manifest
                    sh "kubectl --kubeconfig=${env.KUBECONFIG_PATH} apply -f k8s-depl-manifest.yml"
                    // Check deployment status
                    sh "kubectl --kubeconfig=${env.KUBECONFIG_PATH} rollout status deployment/${DEPLOYMENT_NAME} -n ${NAMESPACE}"
                }
            }
        }

        stage('Get Service DNS') {
            steps {
                // Retrieve kubeconfig credential
                withCredentials([file(credentialsId: 'k8s', variable: 'KUBECONFIG_FILE')]) {
                    // Write kubeconfig to file
                    sh "echo \$KUBECONFIG_FILE | base64 --decode > ${env.KUBECONFIG_PATH}"
                    // Get service DNS
                    script {
                        def dns = sh(script: "kubectl --kubeconfig=${env.KUBECONFIG_PATH} get svc ${DEPLOYMENT_NAME} -n ${NAMESPACE} -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'", returnStdout: true).trim()
                        echo "Service DNS: ${dns}"
                    }
                }
            }
        }
    }
}
