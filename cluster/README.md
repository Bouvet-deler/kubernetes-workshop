# Installing workshop cluster

## Prerequisites

- Azure CLI

`winget install -e --id Microsoft.AzureCLI`

- Kubectl

`az aks install-cli`

- Helm

`winget install helm.helm`

### Nice to have

- k9s

`winget install k9s`

## Install

### Bicep install

`cd cluster`

`az group create --name <resource-group-name> --location norwayeast`

`az deployment group create --resource-group <resource-group-name> --template-file .\main.bicep`

### Install CRDs

`az aks get-credentials -n <cluster-name> -g <resource-group-name>`

`helm repo add external-secrets https://charts.external-secrets.io`

`helm install external-secrets external-secrets/external-secrets -n external-secrets --create-namespace`

## Enable the cluster to read from the key vault

- Get OIDC Issuer URL

`az aks show --resource-group <resource-group-name> --name <cluster-name> --query "oidcIssuerProfile.issuerUrl" -otsv`

- Add federated identity

`az identity federated-credential create --name "kubernetes-federated-credential" --identity-name "k8s-identity" --resource-group "<resource-group-name>" --issuer "<OIDC-issuer-URL>" --subject "system:serviceaccount:workshop:workshop-sa"`

- Controll that the vault URL in `azure-secrets-store.yaml` is correct
- Update client and tenant id in `workshop-sa.yaml`
    - These can be found on k8s-identity properties. Either in Azure portal or through CLI

## Enable Application gateway, exposing services on a public IP

- Deploy application gateway

The publicIp, vnet, and subnet were deployed by `main.bicep` find their names on the Azure portal or throug CLI. The application gateway name can be freely chosen

`az network application-gateway create -n <application-gateway-name> -g <resource-group-name> --sku Standard_v2 --public-ip-address <publicIp-name> --vnet-name <ag-vnet-name> --subnet <subnet-name> --priority 100`

- Get aplication gateway id

`az network application-gateway show -n <application-gateway-name> -g <resource-group-name> -o tsv --query "id"`

- Enable AGIC

`az aks enable-addons -n <cluster-name> -g <resource-group-name> -a ingress-appgw --appgw-id <application-gateway-id>`

- Get node resource group

`az aks show -n <cluster-name> -g <resource-group-name> -o tsv --query "nodeResourceGroup"`

- Get node vnet name

`az network vnet list -g <node-resourceGroup-name> -o tsv --query "[0].name"`

- Get node vnet Id

`az network vnet show -n <node-vnet-name> -g <node-resourceGroup-name> -o tsv --query "id"`

- Peer the vnets

`az network vnet peering create -n AppGWtoAKSVnetPeering -g <resource-group-name> --vnet-name <ag-vnet-name> --remote-vnet <node-vnet-id> --allow-vnet-access`

- Get application gateway vnet id

`az network vnet show -n <ag-vnet-name> -g <resource-group-name> -o tsv --query "id"`

- Peer the other way

`az network vnet peering create -n AKStoAppGWVnetPeering -g <node-resourceGroup-name> --vnet-name <node-vnet-name> --remote-vnet <application-gateway-vnet-id> --allow-vnet-access`


## Build images with ACR

Registry name can be found in azure portal or through CLI 

`cd database`

`az acr build --image sample/postgres:0.1.0 --registry <registry-name> --file Dockerfile .`

`cd frontend`

`az acr build --image sample/frontend:0.1.0 --registry <registry-name> --file Dockerfile .`

- Edit the frontend and postgres deployment with the correct image registry URL

## Apply the manifest files to the cluster

A complete example setup can be found in `/fasit`

This command applies all the manifest files in a directory

`kubectl apply -f .`

## Cleanup

- Delete resource group

Use Azure portal or:

`az group delete --name <resource-group-name>`

- Purge key vault

`az keyvault list-deleted --subscription <subscription-id> --resource-type vault`

`az keyvault purge --subscription <subscription-id> -n <key-vault-name>`