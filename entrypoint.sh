#!/bin/sh

# Exit immediately if a command exits with a non-zero status.
set -e
EP=/aquasec/trivy/scan/private_git

# Check environment variables
if [[ -z "${SOFTWAREFACTORY_TOKEN}" ]]; then
  echo "============================ WARNING ============================"
  echo "Running this GitHub Action without SOFTWAREFACTORY_TOKEN is not recommended"
  exit 1
fi

if [[ -z "${SOFTWAREFACTORY_HOST_URL}" ]]; then
  echo "============================ WARNING ============================"
  echo "Running this GitHub Action without SOFTWAREFACTORY_TARGET_URL is not recommended"
  exit 1
fi

if [[ -z "${SCAN_TARGET_URL}" ]]; then
  echo "============================ WARNING ============================"
  echo "Running this GitHub Action without SCAN_TARGET_URL is not recommended"
  exit 1
fi

if [[ -z "${SCAN_PAT}" ]]; then
  echo "============================ WARNING ============================"
  echo "Running this GitHub Action without SCAN_PAT is not recommended"
  EP=/aquasec/trivy/scan/git
fi

echo "SoftwareFactory: Trivy Git Repository Scanner
░█████╗░░██████╗░██╗░░░██╗░█████╗░  ████████╗██████╗░██╗██╗░░░██╗██╗░░░██╗
██╔══██╗██╔═══██╗██║░░░██║██╔══██╗  ╚══██╔══╝██╔══██╗██║██║░░░██║╚██╗░██╔╝
███████║██║██╗██║██║░░░██║███████║  ░░░██║░░░██████╔╝██║╚██╗░██╔╝░╚████╔╝░
██╔══██║╚██████╔╝██║░░░██║██╔══██║  ░░░██║░░░██╔══██╗██║░╚████╔╝░░░╚██╔╝░░
██║░░██║░╚═██╔═╝░╚██████╔╝██║░░██║  ░░░██║░░░██║░░██║██║░░╚██╔╝░░░░░██║░░░
╚═╝░░╚═╝░░░╚═╝░░░░╚═════╝░╚═╝░░╚═╝  ░░░╚═╝░░░╚═╝░░╚═╝╚═╝░░░╚═╝░░░░░░╚═╝░░░"

# Check softwarefactory host is available
if curl -s -i -f -l -o /dev/null --connect-timeout 10 "$SOFTWAREFACTORY_HOST_URL:5999" 2>/dev/null; then
  echo "Scan Target:  $SCAN_TARGET_URL" && \
  echo "Software Factory Host:  $SOFTWAREFACTORY_HOST_URL" && \
  continue
else
  echo "Scan Target:  $SCAN_TARGET_URL"
  echo "Software Factory Host:  $SOFTWAREFACTORY_HOST_URL"
  echo "  Error: host offline or unvailable"
  unset SOFTWAREFACTORY_TOKEN
  unset SCAN_PAT
  exit 1
fi
# Prepare data
JSON_DATA_STRING="
{
  \"apiKey\": \"$SOFTWAREFACTORY_TOKEN\",
  \"url\": \"$SCAN_TARGET_URL\",
  \"token\": \"$SCAN_PAT\"
}"
# Send post request
response=$(curl --request POST -s \
  --header "Accept: application/json" \
  --header "Content-Type: application/json" \
  --url "$SOFTWAREFACTORY_HOST_URL:5999$EP" \
  --data "$(echo $JSON_DATA_STRING)"
)
# Error process exit
isError=$(echo $response | jq -r '.error')
if $isError; then
  unset SOFTWAREFACTORY_TOKEN
  unset SCAN_PAT
  exit 1
fi
# Success process data
reportHtml=$(echo $response | jq -r '.reportUrl')
reportXml=$(echo $response | jq -r '.reportXml')
reportJson=$(echo $response | jq -r '.reportJson')
# Console out generated report urls
echo "Report available at the following links:"
echo "[html]:  $reportHtml"
echo " [xml]:  $reportXml"
echo "[json]:  $reportJson"
# Exit clean up
unset SOFTWAREFACTORY_TOKEN
unset SCAN_PAT
exit 0
