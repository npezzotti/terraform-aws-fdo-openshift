#!/bin/bash

set -eo pipefail

export KUBECONFIG=/opt/openshift-installer/clusterconfig/auth/kubeconfig

echo "Waiting for OpenShift bootstrapping to complete..."
/opt/openshift-installer/openshift-install wait-for bootstrap-complete --dir /opt/openshift-installer/clusterconfig --log-level info

approved_count=0
target_approvals=4

echo "Waiting for pending CSRs..."
while [ $approved_count -lt $target_approvals ]; do
  pending_csrs=$(oc get csr -o go-template='{{range .items}}{{if not .status}}{{.metadata.name}}{{"\n"}}{{end}}{{end}}')

  for csr in $pending_csrs; do
    echo "Found pending CSR $csr"
    if oc adm certificate approve $csr; then
      ((approved_count++))
    else
      echo "Failed to approve $csr"
    fi
  done

  sleep 5
done

echo "Successfully approved $target_approvals CSRs"

echo "Waiting for OpenShift installation to complete..."
/opt/openshift-installer/openshift-install wait-for install-complete --dir /opt/openshift-installer/clusterconfig --log-level info
