pipeline{
    agent any
    tools{
        nodejs "nodejs-16"
        dockerTool "docker"
    }

    environment{
        APP_NAME = "react-todo"
        RELEASE = "1.0.0"
        DOCKER_USER = "josemokeni"
        DOCKER_CREDENTIALS = 'dockerhub'
        IMAGE_NAME = "${DOCKER_USER}/${APP_NAME}"
        IMAGE_TAG = "${RELEASE}-${BUILD_NUMBER}"
    }
    stages{
        stage("Clean workspace"){
            steps{
                cleanWs()
            }
        }

        stage("Checkout from Git"){
            steps{
                git branch: 'master', url: 'https://github.com/JoseMokeni/react_todo.git'
            }
        }

        stage("Build application"){
            steps{
                sh "npm install"
            }
        }

        stage("Test application"){
            steps{
                sh "npm run test"
            }
        }

        stage("Sonarqube analysis"){
            steps{
                withSonarQubeEnv(credentialsId: 'jenkins-sonarqube-token', installationName: 'sonarqube-scanner'){
                    sh "npx sonar-scanner -Dsonar.projectName=react_todo -Dsonar.projectKey=react_todo -Dsonar.sources=src"
                }
            }
        }

        stage("Quality Gate"){
            steps{
                waitForQualityGate abortPipeline: false
            }
        }

        stage("Build & Push Docker image"){
            steps{
                script {
                    docker.withTool("docker"){
                        docker.withRegistry('https://index.docker.io/v1/', DOCKER_CREDENTIALS){
                            def customImage = docker.build("${IMAGE_NAME}:${IMAGE_TAG}")
                            customImage.push()
                            customImage.push("latest")
                        }
                    }
                }
            }
        }

        stage("Deploy to Kubernetes"){
            steps{
                script{
                    kubernetesDeploy(
                        kubeconfigId: 'kubeconfig',
                        configs: 'k8s/Deployment.yaml,k8s/Service.yaml',
                        enableConfigSubstitution: true
                    )
                }
            }
        }
    }

}