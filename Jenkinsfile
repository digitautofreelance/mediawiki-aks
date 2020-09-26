pipeline {
    agent any
    options{
        buildDiscarder(logRotator(numToKeepStr:'10'))
        disableConcurrentBuilds()
       // timeout(time: 1, unit: 'Days')
    }
    parameters{
        string(name:"Repo_URL", defaultValue: "https://marketplace.azurecr.io/helm/v1/repo", description:"Provide Helm Repo to ADD")
        string(name:"Helm_Package_Install", defaultValue: "azure-marketplace/mediawiki", description:"Helm install package")
        booleanParam(name: "Terraform_Plan", defaultValue: true, description: "Dry run the plan")
        booleanParam(name: "AKS_Deployment", defaultValue: false, description: "Are you ready with AKS deployment, if yes please checking")
        booleanParam(name: "AKS_Deployment_Validation", defaultValue: false, description: "Validating the AKS deployment")
        booleanParam(name: "Mediawiki_Deployment", defaultValue: false, description: "Are you ready with Mediawiki deployment, if yes please checking")
        booleanParam(name: "Mediawiki_Deployment_Validation", defaultValue: false, description: "Are you ready with Mediawiki deployment, if yes please checking")
        booleanParam(name: "Destroy_Helm_Deployment", defaultValue: false, description: "Destroy the Helm - Application deployment")
        booleanParam(name: "Destroy_AKS_Deployment", defaultValue: false, description: "Destroy the AKS deployment")
    }
    environment{
        Repo_URL = "${params.Repo_URL}"
        Helm_Package_Install = "${params.Helm_Package_Install}"
        Terraform_Plan = "${params.Terraform_Plan}"
        AKS_Deployment = "${params.AKS_Deployment}"
        AKS_Deployment_Validation = "${params.AKS_Deployment_Validation}"
        Mediawiki_Deployment = "${params.Mediawiki_Deployment}"
        Mediawiki_Deployment_Validation = "${params.Mediawiki_Deployment_Validation}"
        Destroy_Helm_Deployment = "${params.Destroy_Helm_Deployment}"
        Destroy_AKS_Deployment = "${params.Destroy_AKS_Deployment}"
}
    stages {
        stage('Creating creds-file'){
            steps{
                withCredentials([azureServicePrincipal('SERVICE_PRINCIPAL')]){
                script{
                    sh '''
                    cd AKS-IaC/ 
                    rm -rf .creds.tfvars
                    echo serviceprinciple_id='"'"$AZURE_CLIENT_ID"'"' > .creds.tfvars
                    echo serviceprinciple_key='"'"$AZURE_CLIENT_SECRET"'"' >> .creds.tfvars
                    echo tenant_id='"'"$AZURE_TENANT_ID"'"' >> .creds.tfvars
                    echo subscription_id='"'"$AZURE_SUBSCRIPTION_ID"'"' >> .creds.tfvars
                    pwd
                    ls -la
                    cat .creds.tfvars
                    '''
                    }
                }
            } 
        }
        stage('Plan-AKS-cluster'){
            when { environment name: "Terraform_Plan", value: "true"}
            steps{
                script{
                    sh'''
                    echo "Validating the terrafrom scripts"
                    make validate 
                    echo "Dry run using terrafrom plan"
                    make plan
                    '''
                }
            }
        }
        stage('Deployment-AKS-cluster'){
             when { environment name: "AKS_Deployment", value: "true"}
            steps{
                script{
                    sh'''
                    make infra-apply
                    '''
                }
            }
        }
        stage('Validating the AKS cluster'){
            when { environment name: "AKS_Deployment_Validation", value: "true"}
            steps{
                withCredentials([azureServicePrincipal('SERVICE_PRINCIPAL')]){
                script{
                        sh '''
                        az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET -t $AZURE_TENANT_ID
                        az account set -s $AZURE_SUBSCRIPTION_ID
                        AKS_RG=`az group list | grep -i "aks" | grep "name" | head -1 | awk '{print $2}' | sed 's/"//g' | sed 's/,//g'`
                        AKS_NAME=`az aks list | grep $AKS_RG | grep "name" | awk '{print $2}' | sed 's/"//g' | sed 's/,//g'`
                        az aks get-credentials --resource-group $AKS_RG --name $AKS_NAME
                        kubectl get nodes -o wide
                        kubectl get svc 
                        '''
                        }
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
                    sleep 2m
                    echo "Retrieving the SVC, mediawiki & DB credentials"
                    APP_HOST=$(kubectl get svc --namespace default my-release-mediawiki --template "{{ range (index .status.loadBalancer.ingress 0) }}{{ . }}{{ end }}")
                    APP_PASSWORD=$(kubectl get secret --namespace default my-release-mediawiki -o jsonpath="{.data.mediawiki-password}" | base64 --decode)
                    APP_DATABASE_PASSWORD=$(kubectl get secret --namespace default my-release-mariadb -o jsonpath="{.data.mariadb-password}" | base64 --decode)
                    echo "....Upgarding the application.........."
                    helm upgrade my-release azure-marketplace/mediawiki --set mediawikiHost=$APP_HOST,mediawikiPassword=$APP_PASSWORD,mariadb.db.password=$APP_DATABASE_PASSWORD
                    Admin_Passwd=$(kubectl get secret --namespace default my-release-mediawiki -o jsonpath="{.data.mediawiki-password}" | base64 --decode)
                    SERVICE_IP=$(kubectl get svc --namespace default my-release-mediawiki --template "{{ range (index .status.loadBalancer.ingress 0) }}{{.}}{{ end }}")
                    echo "Mediawiki URL: http://$SERVICE_IP/"
                    '''
                }
            }
        }
         stage('Destory Helm Deployment'){
            when { environment name: "Destroy_Helm_Deployment", value: "true"}
            steps{
                script{
                    sh '''
                    echo "checking destroying the deployment"
                    helm delete my-release
                    kubectl delete pvc/$(kubectl get pvc | tail -1 | awk '{print $1}')
                    '''
                }
            }
        }
        stage('Destory AKS Deployment'){
            when { environment name: "Destroy_AKS_Deployment", value: "true"}
            steps{
                withCredentials([azureServicePrincipal('SERVICE_PRINCIPAL')]){
                script{
                    sh '''
                    echo "checking destroying the deployment"
                    cd AKS-IaC/
                    terraform destroy -var serviceprinciple_id=$AZURE_CLIENT_ID -var serviceprinciple_key=$AZURE_CLIENT_SECRET -var tenant_id=$AZURE_TENANT_ID -var subscription_id=$AZURE_SUBSCRIPTION_ID --auto-approve
                    rm -rf /var/jenkins_home/.kube
                    '''
                    }
                }
            }
        }
    }
}