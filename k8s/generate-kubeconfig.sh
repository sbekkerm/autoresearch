#!/bin/bash
set -euo pipefail

NAMESPACE="sbekkerm-autoresearch"
SA_NAME="sbekkerm-autoresearch-sa"
SECRET_NAME="sbekkerm-autoresearch-sa-token"
KUBECONFIG_OUT="${1:-kubeconfig}"

CLUSTER_NAME=$(kubectl config view --minify -o jsonpath='{.clusters[0].name}')
SERVER=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')

echo "Cluster:   ${CLUSTER_NAME}"
echo "Server:    ${SERVER}"
echo "Namespace: ${NAMESPACE}"

CA_DATA=$(kubectl get secret "${SECRET_NAME}" -n "${NAMESPACE}" \
  -o jsonpath='{.data.ca\.crt}')
TOKEN=$(kubectl get secret "${SECRET_NAME}" -n "${NAMESPACE}" \
  -o jsonpath='{.data.token}' | base64 --decode)

if [ -z "${TOKEN}" ]; then
  echo "ERROR: Token not found. Make sure the namespace and SA secret exist:"
  echo "  kubectl apply -f k8s/namespace.yaml"
  echo "  kubectl apply -f k8s/rbac.yaml"
  exit 1
fi

cat > "${KUBECONFIG_OUT}" <<EOF
apiVersion: v1
kind: Config
clusters:
  - name: ${CLUSTER_NAME}
    cluster:
      certificate-authority-data: ${CA_DATA}
      server: ${SERVER}
contexts:
  - name: ${NAMESPACE}
    context:
      cluster: ${CLUSTER_NAME}
      namespace: ${NAMESPACE}
      user: ${SA_NAME}
current-context: ${NAMESPACE}
users:
  - name: ${SA_NAME}
    user:
      token: ${TOKEN}
EOF

chmod 600 "${KUBECONFIG_OUT}"
echo ""
echo "Kubeconfig written to: ${KUBECONFIG_OUT}"
echo ""
echo "Usage:"
echo "  export KUBECONFIG=${KUBECONFIG_OUT}"
echo "  kubectl get pods"
