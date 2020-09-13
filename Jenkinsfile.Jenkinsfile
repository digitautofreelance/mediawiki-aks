pipeline {
    agent any
    stages {
        stage('intialising terraform'){
            steps{
                script{
                    sh '''
                    echo "Initilasing the terraform init to deploy AKS"
                    cd /pkg && . .az-account
                    terraform init
                    '''
                }
            }
        }
        stage('Deployment-AKS-cluster'){
            steps{
                script{
                    sh'''
                    cd ./AKS-IaC
                    terraform plan -var serviceprinciple_id=$SERVICE_PRINCIPAL -var serviceprinciple_key=$SERVICE_PRINCIPAL_SECRET -var tenant_id=$TENTANT_ID -var subscription_id=$SUBSCRIPTION
                    '''
                }
            }
        }
        stage('Validating the AKS cluster'){
            steps{
                script{
                        sh '''
                        az aks get credentials
                        kubectl get nodes -o wide
                        kubectl get svc 
                        '''
                    }
            }
        }
        stage('Deployment-Helm-wiki'){
            steps{
                script{
                    sh '''
                    echo "checking above stage"
                    '''
                }
            }
        }
    }
}