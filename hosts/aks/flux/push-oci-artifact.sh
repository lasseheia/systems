#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ACR_LOGIN_SERVER="$(tofu -chdir="${SCRIPT_DIR}/../opentofu" output -raw acr_login_server)"
OCI_REPOSITORY="flux/platform"
ARTIFACT_TAG="latest"

REVISION="local@sha1:$(date +%s)"

echo "Pushing Flux OCI artifact to oci://${ACR_LOGIN_SERVER}/${OCI_REPOSITORY}:${ARTIFACT_TAG}"

flux push artifact "oci://${ACR_LOGIN_SERVER}/${OCI_REPOSITORY}:${ARTIFACT_TAG}" \
  --path="${SCRIPT_DIR}" \
  --source="local" \
  --revision="${REVISION}" \
  --provider=azure \
  --output=json

echo "Done."
