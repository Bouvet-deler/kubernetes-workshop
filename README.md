# kubernetes-workshop
Kubernetes workshop for developers

## Oppgave 0

### Log in to the correct subscription

`az login --tenant <Tenant_id>`

### Install kubectl

`az aks install-cli`

### Set kubectl context

`az aks get-credentials --admin --name workshop --resource-group kubernetes-workshop`

### Install k9s (Kubernetes GUI)

`winget install k9s`

## Oppgave 2

### Build and push image to registry

`az acr build --image <uri-prefix>/database:v1 --registry mycontainerregistry008 --file Dockerfile .`


## Deploy app to Kubernetes

`kubectl apply -f postgres-deployment.yaml`