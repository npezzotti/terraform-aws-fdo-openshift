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
* Deploy
```
terraform init
terraform apply
```
* Configure the `oc` client
```
terraform output -r kubeconfig > kubeconfig
export KUBECONFIG=kubeconfig
```

## Tear Down

* Destroy the infrastructure
```
terraform destroy
```

## Architectural Overview

### Installer Instance

There are two reasons why an installer instance is needed in this deployment.

1. The personal AWS accounts do not permit creating an user with administrator privileges fo which access keys couold be generated. As a result, the openshift-installer must be configured with `credentialsMode: Manual` and the credentials manifests must be manually created to work with temporary credentials.
2. The AWS personal account role doesn't have administrator privileges required by the installer.

To work around these limitations, the installer instance is created with an instance profile which is assigned the `AdministratorAccess` policy.

The installer instance effectively performs the function of generating "ignition files" which are consumed by the master and worker nodes at startup to provision themselves.
