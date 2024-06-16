# Kubernetes Workshop
Kubernetes workshop for developers.

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

## Task 3

### Build and push image to registry

 - Navigate to `database` and build and push the Dockerfile
 - After updating all blanked out fields with appropriate values you can deploy `database.yaml`
 - Check the pod with k9s. You should find the pod in a crash loop back off

### Add environment variables

 - Check the `templates` folder to see an example of how one adds envrionment variables to a deployment
 - Add these variables: `POSTGRES_PASSWORD:ඞඞඞ` `POSTGRES_DB: todo` `PG_HOST: postgres`
 - Re-deploy and observe that the pod now starts

### Improve the deployment

In this step we will improve the deployment and get closer to best practices. The two big problems with this deployment are that data is being stored the pod's local storage, which means that if the pod is deleted all the data is lost. Obviously not idael for a database.

The other large issue is that the 'secret' password is in clear text in the yaml file which is commited to version control.

Finally the environment variables are defined directly on the deployment meaning we have to redeploy each time we want to update the config, and if multiple service share some config it has to be duplicated in all services.

We will fix the last problem first.

### Move config to a config map

 - Create a file where you can define your config map. Theres a template to get you started in the template folder
 - Remove the env section from the database deployment and add the same keys to the config map
 - Deploy the config map
 - Add an envFrom section to your database deployemnt, see templates for help
 - Redeploy the database
 - Add the same envFrom section to your frontend and it should now be able to connect to the database

 ### Use a Persistent Volume for the database data

To externalize the storage we need to ask kubernetes for a storage volume using a Persistant Volume Claim. Then we need to configure our database to mount the volume and store data there.

 - Add a `PersistentVolumeClaim` to `database.yaml` See the template file for help
 - Add the volumes section
 - Add the volumeMounts section
 - Update the config map with this entry: `PGDATA: /var/lib/postgresql/data/pgdata`
 - Redploy the resources you have changed

Now you should be able to add todos from the frontend, delete the database with `Ctrl` + `k` in k9s, and see the same todos once the database restarts.

## Task 4

### Configure network policy

Default Kubernetes policy is to allow all traffic. This is not in line with the priciple of least privilege. Therfore a good practice is to deploy a network policy which disallowes all traffic, and explicitly allows only desired connections.

 - Create and deploy a deny all network policy. See the template file `deny-all-policy.yaml` for help
 - Check the frontend to see that it has lost connection to the database
 - Deploy a network policy which only allows the required communication. See the template file
 - Check the frontend again to see that communication is re-established

### Use secrets from Azure Key Vault

To use secrets from azure key vault the cluster uses RBAC to connceted to a managed identity to authenticate with azure. In kubernetes this identity is interacted with through a service account. First create you secrets in azure. The password and username for postgres are good candidates. As you share the key vault with all the workshop participants make sure your secret names are unique in the vault.

- Create you secrets through the azure portal
- Deploy a service account based on the template
- Deploy a secret store based on the templte. This establishes a connection to the key vault
- Deploy an external secret based on the template. This craetes kubernetes secrets based on the key vault secret and keeps these in sync
- Remove the secrets from the config map and re deploy it.
- Get the secret values from the kubernetes secrets. See `deployment-with-secrets.yaml` for help
- If you changed the secret values youm will need to delete the old database. To do that you need to delete the Persistent Volume. In k9s: Navigate to persistent volumes `:pv` delete the volume `Ctrl` + `d` Navigate to persistent volume claims `:pvc` delete the claim `Ctrl` + `d` Navigate to pods `:po` delete the database `Ctrl` + `k`

Once the database restarts it should now be using the new secrets safely stored in Azure Key Vault. Note that by default anyone with acces to the cluster can read the secret. Try yourself! In k9s navigate to secrets `:secret` decode the secret by hitting `x`. Remember that secrets in the cluster are simply base64 encoded by default
