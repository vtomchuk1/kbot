
# Git repo: flux/secret-tele-token.yaml (SOPS-encrypted)

# File
* .sops.yaml
* flux/secret-tele-token.yaml
* flux/kustomization.yaml
* flux/kbot-secrets-kustomization.yaml

# List

1. KMS KeyRing + Key: sops-flux/sops-key in global location
2. Secret Manager secret: TELE_TOKEN containing the Telegram bot token
3. Workload Identity Federation configured for GitHub Actions

