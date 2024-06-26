# Ubuntu container image to run our static analyzer
FROM ubuntu:22.04

# Install dependencies
RUN apt-get update
RUN apt-get install -y git unzip curl
RUN apt-get install -y wget apt-transport-https gnupg lsb-release
RUN curl -L -o /tmp/trivy.deb https://github.com/aquasecurity/trivy/releases/download/v0.48.3/trivy_0.48.3_Linux-64bit.deb  >/dev/null 2>&1 || exit 1
RUN dpkg -i /tmp/trivy.deb
RUN rm -f /tmp/trivy.deb

# Install OSV-Scanner from Datadog
RUN mkdir /osv-scanner
RUN curl -L -o /osv-scanner/osv-scanner.zip https://github.com/DataDog/osv-scanner/releases/download/v0.6.3/osv-scanner_linux_amd64.zip >/dev/null 2>&1 || exit 1
RUN (cd /osv-scanner && unzip osv-scanner.zip)
RUN chmod 755 /osv-scanner/osv-scanner

# Install node 20
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
RUN apt-get install -y nodejs

# Copy files from our repository location to the filesystem path `/` of the container
COPY entrypoint.sh /entrypoint.sh

# The code file to execute when the docker container run
ENTRYPOINT [ "/entrypoint.sh" ]
