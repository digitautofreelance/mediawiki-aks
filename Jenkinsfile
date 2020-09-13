pipeline {
    agent any
    parameters{
        string(name:"SERVICE_PRINCIPAL", defaultValue: " ", description:"Give the SERVICE PRINCIPAL ID")
        string(name:"SERVICE_PRINCIPAL_SECRET", defaultValue: " ", description:"Give the service SERVICE_PRINCIPAL_SECRET")
        string(name:"TENTANT_ID", defaultValue: " ", description:"Give the service TENTANT ID")
        string(name:"SUBSCRIPTION", defaultValue: " ", description:"Give the SUBSCRIPTION ID")
        booleanParam(name: "Terraform_Plan", defaultValue: true, description: "Dry run the plan")
        booleanParam(name: "AKS_Deployment", defaultValue: false, description: "Are you ready with AKS deployment, if yes please checking")
        booleanParam(name: "AKS_Deployment_Validation", defaultValue: false, description: "Validating the AKS deployment")
        booleanParam(name: "Mediawiki_Deployment", defaultValue: false, description: "Are you ready with Mediawiki deployment, if yes please checkin")
        booleanParam(name: "Destroy_Deployment", defaultValue: false, description: "Destroy the deployment")
    }
    environment{
        SERVICE_PRINCIPAL = "${params.SERVICE_PRINCIPAL}"
        SERVICE_PRINCIPAL_SECRET = "${params.SERVICE_PRINCIPAL_SECRET}"
        TENTANT_ID = "${params.TENTANT_ID}"
        SUBSCRIPTION = "${params.SUBSCRIPTION}"
        Terraform_Plan = "${params.Terraform_Plan}"
        AKS_Deployment = "${params.AKS_Deployment}"
        AKS_Deployment_Validation = "${params.AKS_Deployment_Validation}"
        Mediawiki_Deployment = "${params.Mediawiki_Deployment}"
        Destroy_Deployment = "${params.Destroy_Deployment}"

    }
    stages {
        stage('intialising terraform'){
            when { environment name: "Terraform_Plan", value: "true"}
            steps{
                script{
                    sh '''
                    echo "Initilasing the terraform init to deploy AKS"
                    cd AKS-IaC/
                    terraform init
                    '''
                }
            }
        }
        stage('Plan-AKS-cluster'){
            when { environment name: "Terraform_Plan", value: "true"}
            steps{
                script{
                    sh'''
                    cd AKS-IaC/
                    terraform plan -var serviceprinciple_id="${SERVICE_PRINCIPAL}" -var serviceprinciple_key="${SERVICE_PRINCIPAL_SECRET}" -var tenant_id="${TENTANT_ID}" -var subscription_id="${SUBSCRIPTION}"
                    '''
                }
            }
        }
        stage('Deployment-AKS-cluster'){
            when { environment name: "AKS_Deployment", value: "true"}
            steps{
                script{
                    sh'''
                    cd AKS-IaC/
                    echo "----------------------------"
                    terraform apply -var serviceprinciple_id=${SERVICE_PRINCIPAL} -var serviceprinciple_key=${SERVICE_PRINCIPAL_SECRET} -var tenant_id=${TENTANT_ID} -var subscription_id=${SUBSCRIPTION} --auto-approve
                    '''
                }
            }
        }
        stage('Validating the AKS cluster'){
            when { environment name: "AKS_Deployment_Validation", value: "true"}
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
            when { environment name: "Mediawiki_Deployment", value: "true"}
            steps{
                script{
                    sh '''
                    echo "checking above stage"
                    '''
                }
            }
        }
        stage('Destory AKS Deployment'){
            when { environment name: "Destroy_Deployment", value: "true"}
            steps{
                script{
                    sh '''
                    echo "checking destroying the deployment"
                    terraform destroy -var serviceprinciple_id="${SERVICE_PRINCIPAL}" -var serviceprinciple_key="${SERVICE_PRINCIPAL_SECRET}" -var tenant_id="${TENTANT_ID}" -var subscription_id="${SUBSCRIPTION}"
                    '''
                }
            }
        }
    }
}
