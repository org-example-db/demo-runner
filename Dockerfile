FROM google/cloud-sdk:310.0.0

# set the github runner version
ARG RUNNER_VERSION="2.273.4"
ARG HELM="3.3.3"

# update the base packages and add a non-sudo user
#RUN apt-get update -y && apt-get upgrade -y && useradd -m dockeruser
RUN useradd -m dockeruser

# add additional packages as necessary
RUN apt-get install -y curl jq  wget

# add helm 
RUN cd /home && mkdir /helm && cd /helm \
    && wget https://get.helm.sh/helm-v${HELM}-linux-amd64.tar.gz \
    && tar xvf helm-v${HELM}-linux-amd64.tar.gz \
    && mv linux-amd64/helm /usr/local/bin/ \
    && rm helm-v${HELM}-linux-amd64.tar.gz \
    && rm -rf linux-amd64

# jo JSON builder
RUN apt-get install jo

# cd into the user directory, download and unzip the github actions runner
RUN echo ${RUNNER_VERSION} \
    && cd /home && mkdir runner && cd runner \
    && curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

# install some additional dependencies
RUN chown -R dockeruser /home/runner && /home/runner/bin/installdependencies.sh

# copy over the start.sh script
COPY start.sh start.sh

# make the script executable
RUN chmod +x start.sh

# remove installation files to make image smaller
RUN rm /home/runner/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

# since the config and run script for actions are not allowed to be run by root,
# set the user to "dockeruser" so all subsequent commands are run as the docker user
USER dockeruser

# add helm diff plugin, needs to be executed as dockeruser
RUN helm plugin install https://github.com/databus23/helm-diff

# set the entrypoint to the start.sh script
ENTRYPOINT ["./start.sh"] 