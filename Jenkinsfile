pipeline{
    agent{
        any
    }
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
    }

    stages{
        stage("Checkour from Git"){
            steps{
                git branch: 'master', url: 'https://github.com/JoseMokeni/react_todo.git'
            }
        }
    }

}