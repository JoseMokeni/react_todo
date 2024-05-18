pipeline{
    agent any
    tools{
        nodejs "nodejs-16"
        dockerTool "docker"
    }
    stages{
        stage("Clean workspace"){
            steps{
                cleanWs()
            }
        }

        stage("Checkour from Git"){
            steps{
                git branch: 'master', url: 'https://github.com/JoseMokeni/react_todo.git'
            }
        }

        stage("Build application"){
            steps{
                sh "npm install"
                sh "npm run build"
            }
        }

        stage("Test application"){
            steps{
                sh "npm run test"
            }
        }
    }

}