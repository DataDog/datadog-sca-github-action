# Ubuntu container image to run our static analyzer
FROM ubuntu:22.04


# Install OSV-Scanner from Datadog
RUN mkdir /osv-scanner
RUN curl -L -o /osv-scanner/osv-scanner.zip https://github.com/DataDog/osv-scanner/releases/download/v0.7.1/osv-scanner_linux_$(uname -m).zip >/dev/null 2>&1 || exit 1
RUN (cd /osv-scanner && unzip osv-scanner.zip)
RUN chmod 755 /osv-scanner/osv-scanner

# Install node 20
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
RUN apt-get install -y nodejs

# Copy files from our repository location to the filesystem path `/` of the container
COPY entrypoint.sh /entrypoint.sh

# The code file to execute when the docker container run
ENTRYPOINT [ "/entrypoint.sh" ]
