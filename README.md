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

## Task 1

### Build and push image to registry
 
 - Navigate to `aspnetapp\aspnetapp\Program.cs` and update line 24 to something unique
 - Build the Dockerfile in `aspnetapp`
 - Choose a prefix so that all of your images get a unique name and run:

`az acr build --image <uri-prefix>/aspnet:v1 --registry workshopacrsqr2klsnuxgxa --file Dockerfile .`

### Update task-1.yaml

 - Update namespace to your own
 - In `Pod` definition at `spec.containers[0].image` update to the correct uri for your image
 - In `Ingress` definition at `spec.rules[0].http.paths[0].path` set the base path chosen in `Program.cs`

### Deploy in Kubernetes

 - Run:

`kubectl apply -f task-1.yaml`

### Check that the service in available

 - Find the IP address using k9s: `:ingress`
 - Navigate to `ip-adresse/subdirectory` in the browser


## Task 2

### Build and push image to registry

 - Navigate to `frontend\svelte.config.js` and update line 16 to a path where you will host the frontend
 - Build the frontend image

`az acr build --image <uri-prefix>/<name>:version --registry workshopacrsqr2klsnuxgxa --file Dockerfile .`

### Update frontend.yaml with your own:

 - namespace
 - subdirectory (base path)
 - image prefix and name

### Deploy the frontend to Kubernetes

`kubectl apply -f frontend.yaml`