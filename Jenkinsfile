pipeline {
    agent any
    parameters{
        string(name:"SERVICE_PRINCIPAL", defaultValue: " ", description:"Give the SERVICE PRINCIPAL ID")
        string(name:"SERVICE_PRINCIPAL_SECRET", defaultValue: " ", description:"Give the service SERVICE_PRINCIPAL_SECRET")
        string(name:"TENTANT_ID", defaultValue: " ", description:"Give the service TENTANT ID")
        string(name:"SUBSCRIPTION", defaultValue: " ", description:"Give the SUBSCRIPTION ID")
        string(name:"Repo_URL", defaultValue: "https://marketplace.azurecr.io/helm/v1/repo", description:"Provide Helm Repo to ADD")
        string(name:"Helm_Package_Install", defaultValue: "azure-marketplace/mediawiki", description:"Helm install package")
        booleanParam(name: "Terraform_Plan", defaultValue: true, description: "Dry run the plan")
        booleanParam(name: "AKS_Deployment", defaultValue: false, description: "Are you ready with AKS deployment, if yes please checking")
        booleanParam(name: "AKS_Deployment_Validation", defaultValue: false, description: "Validating the AKS deployment")
        booleanParam(name: "Mediawiki_Deployment", defaultValue: false, description: "Are you ready with Mediawiki deployment, if yes please checking")
        booleanParam(name: "Mediawiki_Deployment_Validation", defaultValue: false, description: "Are you ready with Mediawiki deployment, if yes please checking")
        booleanParam(name: "Destroy_Deployment", defaultValue: false, description: "Destroy the deployment")
    }
    environment{
        SERVICE_PRINCIPAL = "${params.SERVICE_PRINCIPAL}"
        SERVICE_PRINCIPAL_SECRET = "${params.SERVICE_PRINCIPAL_SECRET}"
        TENTANT_ID = "${params.TENTANT_ID}"
        SUBSCRIPTION = "${params.SUBSCRIPTION}"
        Repo_URL = "${params.Repo_URL}"
        Helm_Package_Install = "${params.Helm_Package_Install}"
        Terraform_Plan = "${params.Terraform_Plan}"
        AKS_Deployment = "${params.AKS_Deployment}"
        AKS_Deployment_Validation = "${params.AKS_Deployment_Validation}"
        Mediawiki_Deployment = "${params.Mediawiki_Deployment}"
        Mediawiki_Deployment_Validation = "${Mediawiki_Deployment_Validation}"
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
                        AKS_RG=`az group list | grep -i "aks" | grep "name" | head -1 | awk '{print $2}' | sed 's/"//g' | sed 's/,//g'`
                        AKS_NAME=`az aks list | grep $AKS_RG | grep "name" | awk '{print $2}' | sed 's/"//g' | sed 's/,//g'`
                        az aks get-credentials --resource-group $AKS_RG --name $AKS_NAME
                        kubectl get nodes -o wide
                        kubectl get svc 
                        '''
                    }
            }
        }
        stage('App-Deployment-Using-Helm'){
            when { environment name: "Mediawiki_Deployment", value: "true"}
            steps{
                script{
                    sh '''
                    helm repo add azure-marketplace "${Repo_URL}"
                    helm install my-release "${Helm_Package_Install}"
                    echo "Updating the application by configuring the DB credentials"
                    export APP_HOST=$(kubectl get svc --namespace default my-release-mediawiki --template "{{ range (index .status.loadBalancer.ingress 0) }}{{ . }}{{ end }}")
                    export APP_PASSWORD=$(kubectl get secret --namespace default my-release-mediawiki -o jsonpath="{.data.mediawiki-password}" | base64 --decode)
                    export APP_DATABASE_PASSWORD=$(kubectl get secret --namespace default my-release-mariadb -o jsonpath="{.data.mariadb-password}" | base64 --decode)
                    '''
                }
            }
        }
        stage('Helm-Deployment-Validation'){
            when { environment name: "Mediawiki_Deployment_Validation", value: "true"}
            steps{
                script{
                    sh '''
                    helm repo update
                    helm repo add azure-marketplace "${Repo_URL}"
                    echo "Updating the application by configuring the DB credentials"
                    export APP_HOST=$(kubectl get svc --namespace default my-release-mediawiki --template "{{ range (index .status.loadBalancer.ingress 0) }}{{ . }}{{ end }}")
                    export APP_PASSWORD=$(kubectl get secret --namespace default my-release-mediawiki -o jsonpath="{.data.mediawiki-password}" | base64 --decode)
                    export APP_DATABASE_PASSWORD=$(kubectl get secret --namespace default my-release-mariadb -o jsonpath="{.data.mariadb-password}" | base64 --decode)
                    helm upgrade my-release bitnami/mediawiki --set mediawikiHost=$APP_HOST,mediawikiPassword=$APP_PASSWORD,mariadb.db.password=$APP_DATABASE_PASSWORD
                    $(kubectl get secret --namespace default my-release-mediawiki -o jsonpath="{.data.mediawiki-password}" | base64 --decode)
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
