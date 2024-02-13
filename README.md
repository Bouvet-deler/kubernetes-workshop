# kubernetes-workshop
Kubernetes workshop for developers

## Log in to the correct subscription

`az login --tenant <Tenant_id>`

## Build and push image to registry

`az acr build --image sample/hello-world:v1 --registry mycontainerregistry008 --file Dockerfile .`

## Set kubectl context

`az aks get-credentials --admin --name workshop --resource-group kubernetes-workshop`

## Deploy app to Kubernetes

`kubectl apply -f postgres-deployment.yaml`