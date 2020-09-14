    Mediawiki Deployment on AKS using Helm chart (Bitnami)
   Mediawiki is an extremely powerful, scalable software and a feature-rich wiki implementation that uses PHP to process and display data stored in a database, such as MySQL.
    
Prerequisites

    Kubernetes 1.12+
    Helm 2.12+ or Helm 3.0-beta3+
    PV provisioner support in the underlying infrastructure
    ReadWriteMany volumes for deployment scaling
   
This deployment configured with Jenkinsfile as a pipeline (pipeline as a code), this build reuired the inputs as mentioned below,
   
SERVICE_PRINCIPAL="xxxx-xxx-xxx-xxx"
SERVICE_PRINCIPAL_SECRET="xxxx-xxx-xxx-xxx"
TENTANT_ID="xxxx-xxx-xxx-xxx"
SUBSCRIPTION="xxxx-xxx-xxx-xxx"

Rolling VS Immutable tags
It is strongly recommended to use immutable tags in a production environment. This ensures your deployment does not change automatically if the same tag is updated with a different image.

Bitnami will release a new chart updating its containers if a new version of the main container, significant changes, or critical vulnerabilities exist.

Note: In this present deployment we haven't use the ingress controller, to enable the ingress controller change the value in values.yaml file nad update the actual to route the traffic. 
