# base
FROM ubuntu:18.04

# set the github runner version
ARG RUNNER_VERSION="2.273.1"

# update the base packages and add a non-sudo user
RUN apt-get update -y && apt-get upgrade -y && useradd -m dockeruser

# add additional packages as necessary
# install python and the packages the your code depends on along with jq so we can parse JSON
RUN apt-get install -y curl jq build-essential libssl-dev libffi-dev python3 python3-venv python3-dev 

## Installing docker
RUN apt-get remove docker docker-engine docker.io containerd runc

RUN apt-get install -y \
    apt-transport-https \
    ca-certificates \
    gnupg-agent \
    software-properties-common

RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

RUN apt-key fingerprint 0EBFCD88

RUN add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

RUN apt-get update

RUN apt-get install -y docker-ce docker-ce-cli containerd.io

# Enable Docker-in-Docker
#RUN docker run --privileged -d docker:dind

# cd into the user directory, download and unzip the github actions runner
RUN cd /home && mkdir runner && cd runner \
    && curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

# install some additional dependencies
RUN chown -R dockeruser /home/runner && /home/runner/bin/installdependencies.sh

# copy over the start.sh script
COPY start.sh start.sh

# make the script executable
RUN chmod +x start.sh

# since the config and run script for actions are not allowed to be run by root,
# set the user to "dockeruser" so all subsequent commands are run as the docker user
USER dockeruser

# set the entrypoint to the start.sh script
ENTRYPOINT ["./start.sh"]