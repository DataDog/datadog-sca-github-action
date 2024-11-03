#!/bin/sh -l

########################################################
# check variables
########################################################
if [ -z "$DD_API_KEY" ]; then
    echo "DD_API_KEY not set. Please set one and try again."
    exit 1
fi

if [ -z "$DD_APP_KEY" ]; then
    echo "DD_APP_KEY not set. Please set one and try again."
    exit 1
fi

########################################################
# osv-scanner
########################################################
mkdir /osv-scanner
if [ "$(uname -m)" = "aarch64" ]; then
  echo "Installing osv-scanner for ARM64"
  curl -L -o "/osv-scanner/osv-scanner.zip" "https://github.com/DataDog/osv-scanner/releases/download/v0.9.0/osv-scanner_linux_arm64.zip" >/dev/null 2>&1 || exit 1
else
  echo "Installing osv-scanner for AMD64"
  curl -L -o "/osv-scanner/osv-scanner.zip" "https://github.com/DataDog/osv-scanner/releases/download/v0.9.0/osv-scanner_linux_amd64.zip" >/dev/null 2>&1 || exit 1
fi

(cd /osv-scanner && unzip osv-scanner.zip)
chmod 755 /osv-scanner/osv-scanner

########################################################
# datadog-ci stuff
########################################################
echo "Installing 'datadog-ci'"
npm install -g @datadog/datadog-ci || exit 1

DATADOG_CLI_PATH=/usr/bin/datadog-ci

# Check that datadog-ci was installed
if [ ! -x $DATADOG_CLI_PATH ]; then
    echo "The datadog-ci was not installed correctly, not found in $DATADOG_CLI_PATH."
    exit 1
fi

echo "Done: datadog-ci available $DATADOG_CLI_PATH"
echo "Version: $($DATADOG_CLI_PATH version)"


########################################################
# output directory
########################################################
echo "Getting output directory"
OUTPUT_DIRECTORY=$(mktemp -d)

# Check that datadog-ci was installed
if [ ! -d "$OUTPUT_DIRECTORY" ]; then
    echo "Output directory ${OUTPUT_DIRECTORY} does not exist"
    exit 1
fi

OUTPUT_FILE="$OUTPUT_DIRECTORY/sbom.json"

echo "Done: will output results at $OUTPUT_FILE"

########################################################
# execute osv-scanner and upload the results
########################################################

# navigate to workspace root, so the datadog-ci command can access the git info
cd ${GITHUB_WORKSPACE} || exit 1
git config --global --add safe.directory ${GITHUB_WORKSPACE} || exit 1


echo "Generating SBOM with osv-scanner"
/osv-scanner/osv-scanner --skip-git -r --experimental-only-packages --format=cyclonedx-1-5 --paths-relative-to-scan-dir --output="$OUTPUT_FILE" . || exit 1
echo "Done"


echo "Uploading results to Datadog"
${DATADOG_CLI_PATH} sbom upload --service osv-scanner --env ci "$OUTPUT_FILE" || exit 1
echo "Done"
