# Ubuntu container image to run our static analyzer
FROM ubuntu:22.04

RUN apt-get update
RUN apt-get install -y curl

# Install node 20
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
RUN apt-get install -y nodejs

# Copy files from our repository location to the filesystem path `/` of the container
COPY entrypoint.sh /entrypoint.sh

# The code file to execute when the docker container run
ENTRYPOINT [ "/entrypoint.sh" ]
