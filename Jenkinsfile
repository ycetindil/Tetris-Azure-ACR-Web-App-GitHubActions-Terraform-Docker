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
        stage('deploy web appp'){
            steps{
                azCommands('azure_service_principal', 
                        ['az vm create -n MyLinuxVM -g MyResourceGroup --image UbuntuLTS --data-disk-sizes-gb 10 20 && /publicIpAddress|PUBLIC_IP'])
                azureCLI commands: [[exportVariablesString: '', script: 'az login']], principalCredentialId: 'asp'
                sh 'az webapp deployment container config --name oguzhanaydogan --resource-group Tetris-Jenkins --docker-custom-image-name oguzhan.azurecr.io/tetris:latest --sku Free'
            }
        }
    }    
}
