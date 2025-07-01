#!/bin/bash
set -e

echo "[1/8] 네임스페이스 생성..."
kubectl apply -f 00-namespace/namespace.yaml

echo "[2/8] Vault 설치..."
helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update
helm upgrade --install vault hashicorp/vault -f 01-security/vault/values.yaml -n vault

echo "[3/8] Vault PKI 구성..."
bash 01-security/vault/pki-issuer-setup.sh

echo "[4/8] Istio mTLS 정책 적용..."
kubectl apply -f 01-security/istio-mtls/peer-authentication.yaml

echo "[5/8] Jenkins 설치..."
helm repo add jenkinsci https://charts.jenkins.io
helm repo update
helm upgrade --install jenkins jenkinsci/jenkins -f 02-ci-cd/jenkins/values.yaml -n cicd

echo "[6/8] ArgoCD 설치..."
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm upgrade --install argocd argo/argo-cd -f 02-ci-cd/argocd/values.yaml -n cicd

echo "[7/8] 모니터링 스택 설치 (Prometheus + Grafana)..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm upgrade --install kube-prom-stack prometheus-community/kube-prometheus-stack -f 03-observability/monitoring/values.yaml -n observability

echo "[8/8] 로깅 및 트레이싱 설치 (Loki + Promtail + Jaeger)..."
helm repo add grafana https://grafana.github.io/helm-charts
helm upgrade --install loki grafana/loki-stack -f 03-observability/logging/values.yaml -n observability
helm repo add jaegertracing https://jaegertracing.github.io/helm-charts
helm upgrade --install jaeger jaegertracing/jaeger -f 03-observability/tracing/values.yaml -n observability

echo "✅ 모든 컴포넌트가 설치되었습니다."