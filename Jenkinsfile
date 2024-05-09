pipeline{
    agent any
    tools{
        jdk 'jdk'
        nodejs 'nodejs'
    }
    environment {
        SCANNER_HOME=tool 'sonarqube-server'
    }
    stages {
        stage('Workspace Cleaning'){
            steps{
                cleanWs()
            }
        }
        stage('Checkout from Git'){
            steps{
                git branch: 'master', url: 'https://github.com/JoseMokeni/react_todo.git'
            }
        }
        stage("Sonarqube Analysis"){
            steps{
                withSonarQubeEnv('sonarqube-server') {
                    sh ''' $SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=ReactTODO \
                    -Dsonar.projectKey=ReactTODO \
                    '''
                }
            }
        }
        stage("Quality Gate"){
           steps {
                script {
                    waitForQualityGate abortPipeline: true, credentialsId: 'sonar-token' 
                }
            } 
        }

        stage("Dependencies Installation"){
            steps{
                sh "npm i"
            }
        }

        // OWASP Dependency Check
        stage('OWASP Dependency-Check Vulnerabilities') {
            steps{
                dependencyCheck additionalArguments: ''' 
                    -o './'
                    -s './'
                    -f 'ALL' 
                    --prettyPrint''', odcInstallation: 'OWASP Dependency-Check'
                dependencyCheckPublisher pattern: 'dependency-check-report.xml'
                
            }
        }  

        stage("Trivy file scanning"){
            steps{
                sh "trivy fs --exit-code 0 --severity HIGH --no-progress ."
            }
        }

        stage("Build"){
            steps{
                script{
                    docker.build("josemokeni/react-todo:${env.BUILD_NUMBER}")

                }
            }
        }

        stage("Trivy image scanning"){
            steps{
                sh "trivy image --exit-code 0 --severity HIGH --no-progress josemokeni/react-todo:${env.BUILD_NUMBER}"
            }
        }

        stage("Push"){
            steps{
                script{
                    docker.withRegistry('https://registry.hub.docker.com', 'docker-hub-credentials'){
                        docker.image("josemokeni/react-todo:${env.BUILD_NUMBER}").push()
                    }

                }
            }
        }

        stage("Delete Image"){
            steps{
                script{
                    docker.image("josemokeni/react-todo:${env.BUILD_NUMBER}").remove()
                }
            }
        }
         
    }
}