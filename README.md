# kubernetes-workshop
Kubernetes workshop for developers

## Oppgave 0

### Install the Azure cli

Windows

`winget install -e --id Microsoft.AzureCLI`

MacOS

`brew update && brew install azure-cli`

Linux

`curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash`

There are step-by-step installation instructions if you prefer not to run the script from Microsoft

### Log in to the correct subscription

We will be using a tenant with ID: `fdf88c80-36e9-45ee-a0b2-d7eb687e39eb`

`az login --tenant <Tenant_id>`

### Install kubectl

`az aks install-cli`

### Set kubectl context

`az aks get-credentials --admin --name workshop --resource-group kubernetes-workshop`

### Install k9s (Kubernetes GUI)

Windows

`winget install k9s`

MacOS

`brew install derailed/k9s/k9s`

Linux

Use package manager of choice or build from source: [install k9s](https://k9scli.io/topics/install/)

### Deploy your namespace

- Update the file `manifest/namespace.yaml` with a unique name
- Deploy the namespace by running: `kubectl apply -f namespace.yaml`

## Oppgave 2

### Build and push image to registry

`az acr build --image <uri-prefix>/database:v1 --registry mycontainerregistry008 --file Dockerfile .`


## Deploy app to Kubernetes

`kubectl apply -f postgres-deployment.yaml`