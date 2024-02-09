
# Scan your code with SF Action

## Requirements

To run an analysis on your code, you first need to set up your SoftwareFactory instance. Your instance must be accessible from GitHub, and you will need an access token to run the analysis.

## Usage

The workflow YAML file will usually look something like this:

```yaml
on:
  # Trigger analysis when pushing to your main branches, and when creating a pull request.
  push:
    branches:
      - main
      - master
      - develop
      - 'releases/**'
  pull_request:
    types: [opened, synchronize, reopened]

name: SF Actions - Aqua Trivy Scan
jobs:
  SF-Trivy-Scan:
    runs-on: ubuntu-latest
    steps:
      - name: </> SF Aqua Trivy Scan
        uses: FogChainInc/sf-trivy-scan-action@main
        env:
          SOFTWAREFACTORY_HOST_URL: ${{ secrets.SOFTWAREFACTORY_HOST_URL }}
          SOFTWAREFACTORY_TOKEN: ${{ secrets.SOFTWAREFACTORY_TOKEN }}
          SCAN_PAT: ${{ secrets.SCAN_TARGET_PAT }}
          SCAN_TARGET_URL: ${{ vars.SCAN_TARGET_URL }}
```

## Environment variables

It is best to store sensitive variables as secrets.

- `SOFTWAREFACTORY_HOST_URL` – **Required** - Your SF host instance.
- `SOFTWAREFACTORY_TOKEN` – **Required** - Your SF host's access token.
- `SCAN_PAT` – **Optional** - Private repositories will require a users personal access token(PAT) or service account.
- `SCAN_TARGET_URL` – **Required** - Provide a valid target git repo to scan.
