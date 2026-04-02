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

if [ "$REACHABILITY" = "true" ]; then
	REACHABILITY_ARG="--reachability"
else
	REACHABILITY_ARG=""
fi

########################################################
# datadog-sbom-generator
########################################################
mkdir /datadog-sbom-generator
if [ "$(uname -m)" = "aarch64" ]; then
  echo "Installing datadog-sbom-generator for ARM64"
  curl -L -o "/datadog-sbom-generator/datadog-sbom-generator.zip" "https://github.com/DataDog/datadog-sbom-generator/releases/latest/download/datadog-sbom-generator_linux_arm64.zip" >/dev/null 2>&1 || exit 1
else
  echo "Installing datadog-sbom-generator for AMD64"
  curl -L -o "/datadog-sbom-generator/datadog-sbom-generator.zip" "https://github.com/DataDog/datadog-sbom-generator/releases/latest/download/datadog-sbom-generator_linux_amd64.zip" >/dev/null 2>&1 || exit 1
fi

(cd /datadog-sbom-generator && unzip datadog-sbom-generator.zip)
chmod 755 /datadog-sbom-generator/datadog-sbom-generator

########################################################
# datadog-ci stuff
########################################################
DATADOG_CI_VERSION="5.11.0"
DATADOG_CI_PATH="/usr/local/bin/datadog-ci"

echo "Installing 'datadog-ci' v${DATADOG_CI_VERSION}"
if [ "$(uname -m)" = "aarch64" ]; then
  DATADOG_CI_BINARY="datadog-ci_linux-arm64"
  DATADOG_CI_CHECKSUM="fab804583d79f0c5e042f73b3f90fd05336fe409a23ab0bab5219122db13232f"
else
  DATADOG_CI_BINARY="datadog-ci_linux-x64"
  DATADOG_CI_CHECKSUM="f0c002799cb72f6b372c144a753642c99d33e00021054691e865b8076fa624fb"
fi

curl -L -o "$DATADOG_CI_PATH" "https://github.com/DataDog/datadog-ci/releases/download/v${DATADOG_CI_VERSION}/${DATADOG_CI_BINARY}" || exit 1
echo "${DATADOG_CI_CHECKSUM}  ${DATADOG_CI_PATH}" | sha256sum -c - || { echo "datadog-ci checksum verification failed"; exit 1; }
chmod 755 "$DATADOG_CI_PATH"

# Check that datadog-ci was installed
if [ ! -x "$DATADOG_CI_PATH" ]; then
    echo "The datadog-ci was not installed correctly, not found in $DATADOG_CI_PATH."
    exit 1
fi

echo "Done: datadog-ci available $DATADOG_CI_PATH"
echo "Version: $($DATADOG_CI_PATH version)"


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
# execute datadog-sbom-generator and upload the results
########################################################

# navigate to workspace root, so the datadog-ci command can access the git info
cd ${GITHUB_WORKSPACE} || exit 1
git config --global --add safe.directory ${GITHUB_WORKSPACE} || exit 1


echo "Generating SBOM with datadog-sbom-generator"
/datadog-sbom-generator/datadog-sbom-generator scan --verbosity info $REACHABILITY_ARG --output="$OUTPUT_FILE" . || exit 1
echo "Done"


echo "Uploading results to Datadog"
${DATADOG_CLI_PATH} sbom upload --service datadog-sbom-generator --env ci "$OUTPUT_FILE" || exit 1
echo "Done"
