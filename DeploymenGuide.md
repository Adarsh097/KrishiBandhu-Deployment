## Setup & Initialization <br/>

### 1. Install Terraform
* Install Terraform<br/>
#### Linux & macOS
```bash
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install terraform
```
### Verify Installation
```bash
terraform -v
```
### Initialize Terraform
```bash
terraform init
```
### 2. Install AWS CLI
AWS CLI (Command Line Interface) allows you to interact with AWS services directly from the command line.

```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt install unzip
unzip awscliv2.zip
sudo ./aws/install
```

 ```aws configure```

> #### This will prompt you to enter:<br/>
- **AWS Access Key ID:**<br/>
- **AWS Secret Access Key:**<br/>
- **Default region name:**<br/>
- **Default output format:**<br/>

> [!NOTE] 
> Make sure the IAM user you're using has the necessary permissions. You’ll need an AWS IAM Role with programmatic access enabled, along with the Access Key and Secret Key.

## Getting Started

> Follow the steps below to get your infrastructure up and running using Terraform:<br/>

1. **Clone the Repository:**
First, clone this repo to your local machine:<br/>
```bash
git clone https://github.com/LondheShubham153/tws-e-commerce-app.git
cd terraform
```
2. **Generate SSH Key Pair:**
Create a new SSH key to access your EC2 instance:
```bash
ssh-keygen -f terra-key
```
This will prompt you to create a new key file named terra-key.

3. **Private key permission:** Change your private key permission:
```bash
chmod 400 terra-key
```

4. **Initialize Terraform:**
Initialize the Terraform working directory to download required providers:
```bash
terraform init
```
5. **Review the Execution Plan:**
Before applying changes, always check the execution plan:
```bash
terraform plan
```
6. **Apply the Configuration:**
Now, apply the changes and create the infrastructure:
```bash
terraform apply
```
> Confirm with `yes` when prompted.

7. **Access Your EC2 Instance;** <br/>
After deployment, grab the public IP of your EC2 instance from the output or AWS Console, then connect using SSH:
```bash
ssh -i terra-key ubuntu@<public-ip>
```
8. **Update your kubeconfig:**
wherever you want to access your eks wheather it is yur local machine or bastion server this command will help you to interact with your eks.
> [!CAUTION]
> you need to configure aws cli first to execute this command:

```bash
aws configure
```

```bash
aws eks --region eu-west-1 update-kubeconfig --name tws-eks-cluster
```
9. **Check your cluster:**
```bash
kubectl get nodes
```

## Jenkins Setup Steps
> [!TIP]
> Check if jenkins service is running:

```bash
sudo systemctl status jenkins
```
## Steps to Access Jenkins & Install Plugins

#### 1. **Open Jenkins in Browser:**
> Use your public IP with port 8080:
>**http://<public_IP>:8080**

#### 2. **Initial Admin password:**
> Start the service and get the Jenkins initial admin password:
> ```bash
> sudo cat /var/lib/jenkins/secrets/initialAdminPassword
> ```

#### 3. **Start Jenkins (*If Not Running*):**
> Get the Jenkins initial admin password:
> ```bash
> sudo systemctl enable jenkins
> sudo systemctl restart jenkins
> ```
#### 4. **Install Essential Plugins:**
> - Navigate to:
> **Manage Jenkins → Plugins → Available Plugins**<br/>
> - Search and install the following:<br/>
>   - **Docker Pipeline**<br/>
>   - **Pipeline View**


#### 5. **Set Up Docker & GitHub Credentials in Jenkins (Global Credentials)**<br/>
>
> - GitHub Credentials:
>   - Go to:
**Jenkins → Manage Jenkins → Credentials → (Global) → Add Credentials**
> - Use:
>   - Kind: **Username with password**
>   - ID: **github-credentials**<br/>


> - DockerHub Credentials:
> Go to the same Global Credentials section
> - Use:
>   - Kind: **Username with password**
>   - ID: **docker-hub-credentials**
> [Notes:]
> Use these IDs in your Jenkins pipeline for secure access to GitHub and DockerHub

#### 6. Jenkins Shared Library Setup:
> - `Configure Trusted Pipeline Library`:
>   - Go to:
> **Jenkins → Manage Jenkins → Configure System**
> Scroll to Global Pipeline Libraries section
>
> - **Add a New Shared Library:** 
> - **Name:** shared
> - **Default Version:** main
> - **Project Repository URL:** `https://github.com/<your user-name/jenkins-shared-libraries`.
>
> [Notes:] 
> Make sure the repo contains a proper directory structure eq: vars/<br/>
	
#### 7. Setup Pipeline<br/>
> - Create New Pipeline Job<br/>
>   - **Name:** EasyShop<br/>
>   - **Type:** Pipeline<br/>
> Press `Okey`<br/>

> > In **General**<br/>
> > - **Description:** EasyShop<br/>
> > - **Check the box:** `GitHub project`<br/>
> > - **GitHub Repo URL:** `https://github.com/<your user-name/tws-e-commerce-app`<br/>
>
> > In **Trigger**<br/>
> > - **Check the box:**`GitHub hook trigger for GITScm polling`<br/>
>
> > In **Pipeline**<br/>
> > - **Definition:** `Pipeline script from SCM`<br/>
> > - **SCM:** `Git`<br/>
> > - **Repository URL:** `https://github.com/<your user-name/tws-e-commerce-app`<br/>
> > - **Credentials:** `github-credentials`<br/>
> > - **Branch:** master<br/>
> > - **Script Path:** `Jenkinsfile`<br/>

#### **Fork Required Repos**<br/>
> > Fork App Repo:<br/>
> > * Open the `Jenkinsfile`<br/>
> > * Change the DockerHub username to yours<br/>
>
> > **Fork Shared Library Repo:**<br/>
> > * Edit `vars/update_k8s_manifest.groovy`<br/>
> > * Update with your `DockerHub username`<br/>
> 
> > **Setup Webhook**<br/>
> > In GitHub:<br/>
> >  * Go to **`Settings` → `Webhooks`**<br/>
> >  * Add a new webhook pointing to your Jenkins URL<br/>
> >  * Select: **`GitHub hook trigger for GITScm polling`** in Jenkins job<br/>
>
> > **Trigger the Pipeline**<br/>
> > Click **`Build Now`** in Jenkins


# Continuous Deployment Using ArgoCD on EKS-cluster

## STEP 1: Connect to EKS

```
aws eks update-kubeconfig --region ap-south-1 --name ad-eks-cluster
kubectl get nodes


kubectl create namespace argocd

kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

kubectl get all -n argocd

# Change argocd-server service from ClusterIP -> NodePort
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}'

kubectl port-forward svc/argocd-server -n argocd <your-port>:443 --address=0.0.0.0 &

# Get argocd password

kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo

```
- ArgoCD monitors the github repo where kubernetes manifest are kept. As soon as it detects any change, it deploys the latest manifests on the eks cluster.

- Settings -> Repositories -> connect repo : to connect your github repository


# Settings -> Repositories -> connect repo : to connect your github repository

```
helm repo add external-secrets https://charts.external-secrets.io
helm repo update

helm install external-secrets external-secrets/external-secrets \
  -n external-secrets --create-namespace

# verify
kubectl get pods -n external-secrets

```

# kubectl get pods -n external-secrets

```
aws secretsmanager create-secret \
  --name backend-secret \
  --region ap-south-1 \
  --secret-string '{
    "MONGODB_URI":"NEW_URI",
    "JWT_SECRET":"NEW",
    "JWT_REFRESH_SECRET":"NEW",
    "EMAIL_PASSWORD":"NEW",
    "GEMINI_API_KEY":"NEW",
    "WEATHER_API_KEY":"NEW",
    "MARKET_PRICE_API_KEY":"NEW",
    "GOV_SCHEME_API_KEY":"NEW"
  }'

  ```

  # Step-5 IRSA

  This connects: Kubernetes -> AWS securely (no credentials in cluster)

  ## 5.1 Enable OIDC

  ```
    curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" \
| tar xz -C /tmp

sudo mv /tmp/eksctl /usr/local/bin

eksctl version



  eksctl utils associate-iam-oidc-provider \
  --cluster ad-eks-cluster \
  --approve

  ```

  ## 5.2 Create IAM Policy

```
aws iam create-policy \
  --policy-name ExternalSecretsPolicy \
  --policy-document '{
    "Version":"2012-10-17",
    "Statement":[
      {
        "Effect":"Allow",
        "Action":"secretsmanager:GetSecretValue",
        "Resource":"*"
      }
    ]
  }'

```

## 5.3 Create IAM Role using eksctl

```
 aws iam list-policies \
  --scope Local \
  --query "Policies[?PolicyName=='ExternalSecretsPolicy'].Arn" \
  --output text
arn:aws:iam::520827482778:policy/ExternalSecretsPolicy





eksctl create iamserviceaccount \
  --name external-secrets-sa \
  --namespace krishibandhu \
  --cluster ad-eks-cluster \
  --attach-policy-arn arn:aws:iam::<ACCOUNT_ID>:policy/ExternalSecretsPolicy \
  --approve
```

- This automatically: creates IAM role, attaches policy attaches policy, links to service account

```

kubectl get externalsecret -n krishibandhu
kubectl get secret backend-secret -n krishibandhu

kubectl describe externalsecret backend-secret -n krishibandhu
kubectl logs -n external-secrets deploy/external-secrets

```

# Login to argocd via cli

```
argocd login 13.201.73.142:31629 --username admin

WARNING: server certificate had error: error creating connection: tls: failed to verify certificate: x509: cannot validate certificate for 13.201.73.142 because it doesn't contain any IP SANs. Proceed insecurely (y/n)? y

Password: 
'admin:login' logged in successfully
Context '13.201.73.142:31629' updated

```

22. argocd cluster list -> to see the clusters configured on argocd.

23. Get the current cluster context
```
kubectl config current-context
arn:aws:eks:ap-south-1:520827482778:cluster/ad-eks-cluster

```

24. Add cluster to argocd
```
argocd cluster add arn:aws:eks:ap-south-1:520827482778:cluster/ad-eks-cluster --name ad-eks-cluster
```
- kubectl port-forward svc/argocd-server -n argocd 30001:443 --address=0.0.0.0 &
- http://localhost:30001

25. Create a new application -> lowercase

Here it is **exactly in clean formatted steps (as-is)** 👇

---

# 🚀 Deploy Your Application in Argo CD GUI

On the Argo CD homepage, click on the **“New App”** button.

---

## Fill in the following details:

### 🔹 General Section

* **Application Name:** Enter your desired app name
* **Project Name:** Select `default` from the dropdown
* **Sync Policy:** Choose `Automatic`

---

### 🔹 Source Section

* **Repo URL:** Add the Git repository URL that contains your Kubernetes manifests
* **Path:** `kubernetes` *(or the actual path inside the repo where your manifests reside)*

---

### 🔹 Destination Section

* **Cluster URL:** `https://kubernetes.default.svc` *(usually shown as "default")*
* **Namespace:** `tws-e-commerce-app` *(or your desired namespace)*

---

## ✅ Final Step

Click on **“Create”**

---

That’s it 👍


26. Install cert-manager on cluster

```
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.1/cert-manager.yaml

```

![alt text](image-7.png)

27. You can access the website at: NodeIP:port.

## To access the website using domain name.

---

# Nginx Ingress Controller

## Install the Nginx Ingress Controller using Helm

### Step 1: Create Namespace

```bash
kubectl create namespace ingress-nginx
```

---

### Step 2: Add Helm Repository

```bash
sudo snap install helm --classic

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
```

```bash
helm repo update
```

---

### Step 3: Install Nginx Ingress Controller

```bash
helm install nginx-ingress ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --set controller.service.type=LoadBalancer
```

---

### Step 4: Check Pod Status

```bash
kubectl get pods -n ingress-nginx
```

---

### Step 5: Get External IP of LoadBalancer

```bash
kubectl get svc -n ingress-nginx
```

---

![alt text](image-8.png)

## Go to GoDaddy and a new DNS Record

1. Go and access the website using easyshop.adtechs.xyz


## Monitoring

Here it is **cleanly formatted (as-is, structured properly)** 👇

---

# Monitor EKS Cluster using Prometheus & Grafana via Helm

## Install Helm (On Master Machine)

```bash
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
```

```bash
chmod 700 get_helm.sh
```

```bash
./get_helm.sh
```

---

## Add Helm Stable Charts for Your Local Client

```bash
helm repo add stable https://charts.helm.sh/stable
```

---

## Add Prometheus Helm Repository

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
```

---

## Create Prometheus Namespace

```bash
kubectl create namespace prometheus
```

```bash
kubectl get ns
```

---

## Install Prometheus using Helm

```bash
helm install stable prometheus-community/kube-prometheus-stack -n prometheus
```

---

## Verify Prometheus Installation

```bash
kubectl get pods -n prometheus
```

---

## Check Services (SVC)

```bash
kubectl get svc -n prometheus
```

---

## Expose Prometheus via NodePort

Edit Prometheus service:

```bash
kubectl edit svc stable-kube-prometheus-sta-prometheus -n prometheus
```

Change:

```yaml
type: ClusterIP
```

to:

```yaml
type: NodePort
```

Save the file.

---

## Verify Service

```bash
kubectl get svc -n prometheus
```

---

## Expose Grafana via NodePort

Edit Grafana service:

```bash
kubectl edit svc stable-grafana -n prometheus
```

Change:

```yaml
type: ClusterIP
```

to:

```yaml
type: NodePort
```

Save the file.

---

## Check Grafana Service

```bash
kubectl get svc -n prometheus
```

---

## Get Grafana Password

```bash
kubectl get secret --namespace prometheus stable-grafana \
-o jsonpath="{.data.admin-password}" | base64 --decode ; echo
```

---

## Login to Grafana

* Username: `admin`
* Password: (from above command)

---

## Access Dashboards

Open in browser:

```text
http://<NodeIP>:<NodePort>
```

---

## Clean Up

Delete EKS Cluster:

```bash
eksctl delete cluster --name=bankapp --region=us-west-1
```

---

## Project Done!!!
