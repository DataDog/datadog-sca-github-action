# datadog-sca-github-action

**WARNING**: This work is under development and not ready for any production use.

The `datadog-sca-github-action` is a GitHub Action to generate SBOM and upload them to Datadog.

## SBOM Generation

The GitHub action generates the SBOM automatically based on 
dependencies declared in your repository.

The GitHub Action works for the following languages and following files:

 - JavaScript/Typescript: `package-lock.json` and `yarn.lock`
 - Python: `requirements.txt` (with version defined) and `poetry.lock`

## Setup

### Set up keys

Add `DD_APP_KEY` and `DD_API_KEY` in your GitHub actions secrets.

### Workflow


Add the following code snippet in `.github/workflows/datadog-sca.yml`.


```yaml
on:
  push:
    branches:
      - main

jobs:
  check-quality:
    runs-on: ubuntu-latest
    name: Datadog SBOM Generation and Upload
    steps:
    - name: Checkout
      uses: actions/checkout@v3
    - name: Generate SBOM and Upload
      id: tdb-tests
      uses: juli1/tdb-github-action@main
      with:
        dd_api_key: ${{ secrets.DD_API_KEY }}
        dd_app_key: ${{ secrets.DD_APP_KEY }}
        dd_service: <enter-service>
        dd_env: <enter-env>
        dd_site: <enter-site>
```
