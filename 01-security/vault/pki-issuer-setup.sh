#!/bin/bash
# Vault PKI 구성 스크립트

vault secrets enable pki || true
vault secrets tune -max-lease-ttl=87600h pki
vault write pki/root/generate/internal     common_name="example.com"     ttl=87600h
vault write pki/config/urls     issuing_certificates="http://vault.vault.svc:8200/v1/pki/ca"     crl_distribution_points="http://vault.vault.svc:8200/v1/pki/crl"
vault write pki/roles/istio-role     allowed_domains="example.com"     allow_subdomains=true     max_ttl="72h"