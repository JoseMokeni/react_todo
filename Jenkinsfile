pipeline {
    agent any
    tools {
        nodejs 'nodejs'
    }
    environment {
        SCANNER_HOME = tool 'sonarqube-server'
    }
    stages {
        stage('Workspace Cleaning') {
            steps {
                cleanWs()
            }
        }
        stage('Checkout from Git') {
            steps {
                git branch: 'master', url: 'https://github.com/JoseMokeni/react_todo.git'
            }
        }
        stage("Sonarqube Analysis") {
            steps {
                withSonarQubeEnv('sonarqube-server') {
                    sh ''' 
                    $SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=ReactTODO -Dsonar.projectKey=ReactTODO
                    '''
                }
            }
        }
        stage("Quality Gate") {
            steps {
                script {
                    waitForQualityGate abortPipeline: true, credentialsId: 'sonar-token'
                }
            }
        }
        stage("Dependencies Installation") {
            steps {
                sh "npm i"
            }
        }
        stage('OWASP Dependency-Check Vulnerabilities') {
            steps {
                dependencyCheck additionalArguments: ''' 
                -o './'
                -s './'
                -f 'ALL' 
                --prettyPrint''', odcInstallation: 'OWASP Dependency-Check'
                dependencyCheckPublisher pattern: 'dependency-check-report.xml'
            }
        }
        stage("Trivy file scanning") {
            steps {
                sh "trivy fs --exit-code 0 --severity HIGH --no-progress ."
            }
        }
        stage("Build") {
            steps {
                script {
                    docker.build("josemokeni/react-todo:${env.BUILD_NUMBER}")
                }
            }
        }
        stage("Trivy image scanning") {
            steps {
                sh "trivy image --exit-code 0 --severity HIGH --no-progress josemokeni/react-todo:${env.BUILD_NUMBER}"
            }
        }
        stage("Push") {
            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com', 'docker-hub-credentials') {
                        docker.image("josemokeni/react-todo:${env.BUILD_NUMBER}").push()
                        docker.image("josemokeni/react-todo:${env.BUILD_NUMBER}").push("latest")
                    }
                }
            }
        }
        stage("Prune") {
            steps {
                sh "docker system prune -f"
            }
        }
        // stage("Start minikube") {
        //     steps {
        //         script {
        //             def status = sh(script: "minikube status --format '{{.Host}}'", returnStdout: true).trim()
        //             if (status == "Running") {
        //                 echo "Minikube is already running."
        //             } else {
        //                 echo "Minikube is not running. Starting Minikube..."
        //                 sh "minikube start --driver=docker"
        //             }
        //         }
        //     }
        // }
        stage("Deploy to miniKube") {
            steps {
                sh "kubectl apply -f k8s/Deployment.yaml"
            }
        }
        stage("Map deployment port to vm localhost") {
            steps {
                script {
                    sh "chmod +x portForward.sh"
                    def ip = sh(script: 'minikube ip', returnStdout: true).trim()
                    sh "./portForward.sh $ip 30036"
                }
            }
        }
    }
}