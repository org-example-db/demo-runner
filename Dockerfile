FROM google/cloud-sdk:310.0.0

# set the github runner version
ARG RUNNER_VERSION="2.273.4"
ARG HELM="3.3.3"

ENV RUNNER_NAME=""
ENV GITHUB_TOKEN=""
ENV RUNNER_LABELS=""
ENV RUNNER_WORK_DIRECTORY="_work"
ENV RUNNER_ALLOW_RUNASROOT=false
ENV AGENT_TOOLS_DIRECTORY=/opt/hostedtoolcache

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
    && tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && rm -f actions-runner-linux-x64-${GH_RUNNER_VERSION}.tar.gz \
    && ./bin/installdependencies.sh 

RUN cp home/runner/bin/runsvc.sh home/runner/runsvc.sh && chmod +x home/runner/runsvc.sh

# install some additional dependencies
RUN chown -R dockeruser /home/runner

# copy over the start.sh script
COPY start.sh .

# make the script executable
RUN chmod +x ./start.sh

# since the config and run script for actions are not allowed to be run by root,
# set the user to "dockeruser" so all subsequent commands are run as the docker user
USER dockeruser

# add helm diff plugin, needs to be executed as dockeruser
RUN helm plugin install https://github.com/databus23/helm-diff

# set the entrypoint to the start.sh script
ENTRYPOINT ["./start.sh"] 