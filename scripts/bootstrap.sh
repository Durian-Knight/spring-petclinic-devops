#!/usr/bin/env bash
# One-command local environment bootstrap:
#   minikube (cluster) -> ingress addon -> terraform (namespaces, monitoring) -> app via helm
set -euo pipefail
cd "$(dirname "$0")/.."

echo "==> Starting minikube"
minikube start

echo "==> Enabling ingress addon"
minikube addons enable ingress

echo "==> Waiting for ingress-nginx controller"
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=180s

echo "==> Terraform: monitoring stack + dashboards"
cd terraform
terraform init -input=false
terraform apply -input=false -auto-approve
cd ..

echo "==> Deploying petclinic via Helm"
kubectl create namespace petclinic --dry-run=client -o yaml | kubectl apply -f -
helm upgrade --install petclinic helm/petclinic -n petclinic --wait --timeout 5m

echo
echo "==> Done. Useful commands:"
echo "  App:      kubectl port-forward svc/petclinic 8080:80 -n petclinic"
echo "  Grafana:  kubectl port-forward svc/prometheus-grafana 3000:80 -n monitoring"
echo "  Prometheus: kubectl port-forward svc/prometheus-kube-prometheus-prometheus 9090:9090 -n monitoring"
