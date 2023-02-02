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
        stage('Install Azure CLI') {
            steps {
                script {
                    echo "Installing Azure CLI..."
                    sh 'rpm --import https://packages.microsoft.com/keys/microsoft.asc'
                    sh 'sh -c \'echo -e "[azure-cli]\nname=Azure CLI\nbaseurl=https://packages.microsoft.com/yumrepos/azure-cli\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/azure-cli.repo\''
                    sh 'yum install azure-cli'
                }
            }
        }
        stage('deploy web appp'){
            agent {
                label 'azure-cli'
            }
            steps{
                azureCLI commands: [[exportVariablesString: '', script: 'az login']], principalCredentialId: 'azure_service_principal'
                sh 'az webapp deployment container config --name oguzhanaydogan --resource-group Tetris-Jenkins --docker-custom-image-name oguzhan.azurecr.io/tetris:latest --sku Free'
            }
        }
    }    
}
