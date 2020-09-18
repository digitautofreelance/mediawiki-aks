clean:
	#Cleanup the existing tfstate 
	cd AKS-IaC/ && rm -rf *.plan *.tfstate && rm -rf .terramform
	
validate:
	# Validate the infrastructure 
	cd AKS-IaC/ && terraform init && terraform validate #-var-file=".creds.tfvars"

plan:
	# Creating the terraform plan
	cd AKS-IaC/ && terraform init && terraform plan -var-file=".creds.tfvars" -out="aks.plan"

infra-apply:
	# Get the modules, create the AKS Infrastructure
	cd AKS-IaC/ && terraform init && terraform get && terraform apply -auto-approve -var-file=".creds.tfvars"

destroy:
	# Deleting the AKS service
	cd AKS-IaC/ && terraform destroy -auto-approve -var-file=".creds.tfvars"