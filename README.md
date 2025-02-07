# Install an OpenShift Cluster on AWS Personal Accounts

## Overview

This module provides a method of installing an OpenShift cluster on AWS personal accounts for testing Terraform Enterprise Flexible Deployment Options on OpenShift. At this time, the module only creates the OpenShift cluster and the Terraform Enterprise deployment in separate Terraform configurations. This may change at a future time. A couple manual steps are required to bring the OpenShift cluster online before creating the Terraform Enterpise deployment. 

## Usage

* Deploy the personal base infrastructure: https://app.terraform.io/app/hashicorp-support-eng/registry/modules/private/hashicorp-support-eng/base-infrastructure-aws-personal/team/
* Create a RedHat account or log in to existing account: https://www.redhat.com/
* Navigate to https://console.redhat.com/openshift/install/aws/user-provisioned and, under **Pull secret**, click *Copy pull secret*.
* Stringify the pull secret using a tool like JSON Formatter: https://jsonformatter.org/json-stringify-online
* Set the `pull_secret` variable to the stringified JSON.
* Set the `base_infra_workspace_name` variable to the name of the HCP Terraform workspace containing the personal base infrastructure
* Authenticate with doormat and prepare credentials in your local environment for your personal AWS account
* Change into the `openshift-cluster` directory and apply the configuration.
```
terraform init
terraform apply
```
* Once complete, start a session on the installer node by running the following command.
```
doormat session -a <ACCOUNT_NAME> -r us-east-1 
```
* Configure the `oc` client
```
export KUBECONFIG=/opt/openshift-installer/clusterconfig/auth/kubeconfig
```
* Run the following command to monitor the bootsrapping process.
```
/opt/openshift-installer/openshift-install wait-for bootstrap-complete --dir /opt/openshift-installer/clusterconfig --log-level info
```
* Wait until the command indicates the bootstrapping process is complete.
* Run `oc get nodes` to confirm the three master nodes are in a `Ready` status.
* Each of the two worker nodes will create a pairs of certificate signing requests when they come online (a client request and a server request). Approve the client requests with the following command. It should print the IDs of two CSRs- monitor the output of `oc get csr` until the CSRs are both created and run it again.
```
oc get csr -o go-template='{{range .items}}{{if not .status}}{{.metadata.name}}{{"\n"}}{{end}}{{end}}' | xargs --no-run-if-empty oc adm certificate approve
```
* Run the command again to approve the pair of server CSRs.
* Run the following command to monitor the OpenShift installation until completion.
```
/opt/openshift-installer/openshift-install wait-for install-complete --dir /opt/openshift-installer/clusterconfig --log-level info
```
* The command will print the OpenShift console URL and login credentials upon complete. Use these to access and explore the OpenShift console.
* Change into the `terraform-enterprise` directory
* Run the following commands to apply the configuration.
```
terraform init
terraform apply
```

## Tear Down

The OpenShift Installer program creates some AWS resources outside of Terraform so, 

* Start a session on the installer node and run the following command
```
/opt/openshift-installer/openshift-install destroy cluster --dir /opt/openshift-installer/clusterconfig --log-level info
```

* Destroy the infrastructure
```

```

## Architectural Overview

### Installer Instance

There are two reasons why an installer instance is needed in this deployment.

1. The personal AWS accounts do not permit creating an user with administrator privileges fo which access keys couold be generated. As a result, the openshift-installer must be configured with `credentialsMode: Manual` and the credentials manifests must be manually created to work with temporary credentials.
2. The AWS personal account role doesn't have administrator privileges required by the installer.

To work around these limitations, the installer instance is created with an instance profile which is assigned the `AdministratorAccess` policy.

The installer instance effectively performs the function of generating "ignition files" which are consumed by the master and worker nodes at startup to provision themselves.
