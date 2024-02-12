# kubernetes-workshop
Kubernetes workshop for developers

## Build and push image to registry

`az acr build --image sample/hello-world:v1 --registry mycontainerregistry008 --file Dockerfile .`

## Deploy app to Kubernetes

`kubectl apply -f postgres-deployment.yaml`