creating-az-cred:
	cd AKS-IaC/ 
	rm -rf .creds.tfvars
	echo serviceprinciple_id='"'"$AZURE_CLIENT_ID"'"' > .creds.tfvars
	echo serviceprinciple_key='"'"$AZURE_CLIENT_SECRET"'"' >> .creds.tfvars
	echo tenant_id='"'"$AZURE_TENANT_ID"'"' >> .creds.tfvars
	echo subscription_id='"'"$AZURE_SUBSCRIPTION_ID"'"' >> .creds.tfvars
clean:
	# This section is optional, It will delete existing state of terraform
	cd AKS-IaC/ && rm -rf *.plan *.tfstate && rm -rf .terramform
	
validate:
	# Validate the infrastructure 
	cd AKS-IaC/ && terraform init && terraform validate

plan:
	# Creating the terraform plan
	cd AKS-IaC/ && terraform init && terraform plan -var-file=".creds.tfvars" -out="aks.plan"

infra-apply:
	# Get the modules, create the AKS Infrastructure
	cd AKS-IaC/ && terraform init && terraform get && terraform apply -auto-approve -var-file=".creds.tfvars"

destroy:
	# Deleting the AKS service
	cd AKS-IaC/ && terraform destroy -auto-approve -var-file=".creds.tfvars"