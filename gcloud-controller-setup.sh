#!/bin/bash

set -e

PROGNAME=$(basename $0)

export CLOUDSDK_CORE_DISABLE_PROMPTS=1

# Create an environment variable for the correct distribution
export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)"

# Add the Cloud SDK distribution URI as a package source
echo "deb https://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

# Import the Google Cloud Platform public key
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

# Update the package list and install the Cloud SDK
sudo apt-get update && sudo apt-get install --yes google-cloud-sdk=140.0.0-0ubuntu1~16.10 kubectl jq
curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get | sudo bash
wget --directory-prefix=/tmp https://github.com/openshift/source-to-image/releases/download/v1.1.5/source-to-image-v1.1.5-4dd7721-linux-amd64.tar.gz
(cd /usr/local/bin && tar --no-overwrite-dir -zxvf /tmp/source-to-image-v1.1.5-4dd7721-linux-amd64.tar.gz)

## automatically install and enable byobu for the default user
apt-get -y install byobu
DEFAULT_USER=$(getent passwd 1000 | cut -d: -f1)
sudo -u $DEFAULT_USER -i /usr/bin/byobu-launcher-install
SECONDARY_USER=$(getent passwd 1001 | cut -d: -f1)
sudo -u $SECONDARY_USER -i /usr/bin/byobu-launcher-install

project=$(curl --silent "http://metadata.google.internal/computeMetadata/v1/project/project-id" -H "Metadata-Flavor: Google")
zone=$(curl --silent "http://metadata.google.internal/computeMetadata/v1/instance/zone" -H "Metadata-Flavor: Google" | cut -d/ -f4)
repo=$( curl --silent "http://metadata.google.internal/computeMetadata/v1/instance/attributes/?recursive=true" -H "Metadata-Flavor: Google" | jq -r '.repo')
