pipeline{
    agent any
    stages{
        stage('git checkout'){
            steps{
                checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/oguzhanaydogan/tetris-java-azure-devops']])
            }
        }
        stage('build Docker image'){
            steps{
                sh 'docker build -t oguzhan.azurecr.io/tetris .'
            }
        }
        stage('push image'){
            steps{
                withCredentials([usernamePassword(credentialsId: 'acr', passwordVariable: 'password', usernameVariable: 'username')]) {
                sh 'docker login -u ${username} -p ${password} oguzhan.azurecr.io'        
                sh 'docker push oguzhan.azurecr.io/tetris'
                }
            }
        }
        stage('deploy web app'){
            steps{
                azureWebAppPublish appName: 'oguzhanaydogan', azureCredentialsId: 'asp', dockerImageName: 'oguzhan.azurecr.io/tetris', dockerImageTag: 'latest', dockerRegistryEndpoint: ['oguzhan.azurecr.io'], filePath: '', publishType: 'file', resourceGroup: 'Tetris-Jenkins', slotName: '', sourceDirectory: '', targetDirectory: ''
            }
        }
    }    
}
