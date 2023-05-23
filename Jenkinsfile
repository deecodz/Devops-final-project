import groovy.json.JsonSlurper

pipeline {
    agent any
    environment {
        registry = "derao/webappcal"
        dockerImage = ''
        DEPLOYMENT_NAME = 'webappcal'
        NAMESPACE = 'dev'
        KUBECONFIG_BASE64 = 'LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUMrRENDQWVDZ0F3SUJBZ0lNRjJHYnhOb2F0UGJxaVorNk1BMEdDU3FHU0liM0RRRUJDd1VBTUJneEZqQVUKQmdOVkJBTVREV3QxWW1WeWJtVjBaWE10WTJFd0hoY05Nak13TlRJd01qTTBNekkyV2hjTk16TXdOVEU1TWpNMApNekkyV2pBWU1SWXdGQVlEVlFRREV3MXJkV0psY201bGRHVnpMV05oTUlJQklqQU5CZ2txaGtpRzl3MEJBUUVGCkFBT0NBUThBTUlJQkNnS0NBUUVBbi81Q0VQL0gwVUtQZmx5d2FHZ3o4Q1dMSWxSN2phT0ptT3ZSZ3o0eXFKQkkKMFJDZUQ0Y05BcTlWbEtaNVVsNW1nR1RhY1lacUhwRjJ3RjhoVk14UEkyZ2FYQlIrUTdVc2hBcXdkZE1hSXcvbgpBTGVhS3VrVjZRaUJVVC92aGtHYjdpUnM1ajVkdnhvMHdxY21BVFc3Uk45bmpPQ3R4S3FQbzhQSk9US1hiZ3VRCjdTUDEzMFdtbTNSN0pvbVV1UXVjYU9WcU5FeDhBQ0d6MGRKRzZ6cTRaSEpkakFiOUtIWS8wR0JXcGtvaHJDQ1UKbHprNS9Iam9pSmhYdU80ZlZtZC9kbE0wb2tFd3lqYW5xaFBIMkJ1NldLNXB6QXZmWlVJUmJaY1J3NHpoY281SwozbzFKNmEwZEJEVVFQSlVJUkU4eHJpNEZqWjZGTGV1RDRibGkvdWRWelFJREFRQUJvMEl3UURBT0JnTlZIUThCCkFmOEVCQU1DQVFZd0R3WURWUjBUQVFIL0JBVXdBd0VCL3pBZEJnTlZIUTRFRmdRVXBncVc4eUFQeUpqbmtJTFYKRCtVRGRWWm1vUEF3RFFZSktvWklodmNOQVFFTEJRQURnZ0VCQUFERldDRmRBQnBRUnBnUEdMNTRmb1ZiSjhTbAptRWNOVzZENDJvSnc0aVVCK2lSb3JHL212WlJHazdCbFpVdTJTTHlITnUxRlR2K3kvSnpmZHlqSTZic3RNUWdoCkt0SjRxdDF6NHVhOThMMmo3WFNtNDZEOE52VkJYU2ZJZ2prMnBXRy9IQ3NHc3o1cTVrMWQ3Tm1zSUlpam5RcEgKMTB0MzdaaDd6V3lWQUlueDlROUJhZnRubXEvd2lzRkM5VkVVb3N4QmJpN1pJdjNTL3F3QWRJcnBvVnlramE3WQo0NzhIQ3BQbFRLUW1OMW9IN25pZnFNVnlDbEI3dnhhRG5EaTd5N1dPTkZSMUxXQTZMV1pWRkpXY3ZndzN0SHl5CkxhUlE4T1prSUpaVUNDYnQ2a016cEkrZnkzd2ZjTERMYUNpenRMMTRNT2dVWjZPSDVjc3d0cng0TElzPQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg=='
        DEPLOY_MANIFEST_PATH = '/var/lib/jenkins/k8s-depl-manifest.yml'
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
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'docker', usernameVariable: 'DOCKER_HUB_USERNAME', passwordVariable: 'DOCKER_HUB_PASSWORD')]) {
                        sh "echo $DOCKER_HUB_PASSWORD | docker login --username $DOCKER_HUB_USERNAME --password-stdin"
                    }
                }
            }
        }

        stage('Push Docker image to Docker Hub') {
            steps {
                script {
                    docker.withRegistry('', 'docker') {
                        dockerImage.push("${env.BUILD_NUMBER}")
                    }
                }
            }
        }

        stage('Decode kubeconfig') {
            steps {
                script {
                    def kubeconfig = sh(script: "echo ${KUBECONFIG_BASE64} | base64 --decode", returnStdout: true).trim()
                    writeFile file: '/tmp/kubeconfig', text: kubeconfig
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    sh """
                        kubectl --kubeconfig=/tmp/kubeconfig apply -f ${DEPLOY_MANIFEST_PATH}
                        kubectl --kubeconfig=/tmp/kubeconfig rollout status deployment/${DEPLOYMENT_NAME} -n ${NAMESPACE}
                    """
                }
            }
        }

        stage('Get Service DNS') {
            steps {
                script {
                    def dns = sh(script: "kubectl --kubeconfig=/tmp/kubeconfig get svc ${DEPLOYMENT_NAME} -n ${NAMESPACE} -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'", returnStdout: true).trim()
                    echo "Service DNS: ${dns}"
                }
            }
        }
    }
}
