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

# Add a non-sudo user
RUN useradd -m actions

# add additional packages as necessary
RUN apt-get install -y curl jq  wget

# add helm 
RUN cd /home && mkdir /helm && cd /helm \
    && wget https://get.helm.sh/helm-v${HELM}-linux-amd64.tar.gz \
    && tar xvf helm-v${HELM}-linux-amd64.tar.gz \
    && mv linux-amd64/helm /usr/local/bin/ \
    && rm helm-v${HELM}-linux-amd64.tar.gz \
    && rm -rf linux-amd64

# add github runner
RUN echo ${RUNNER_VERSION} \
    && cd /home && mkdir runner && cd runner \
    && curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && rm -f actions-runner-linux-x64-${GH_RUNNER_VERSION}.tar.gz \
    && ./bin/installdependencies.sh 

# put runsvc on same directory level as dependencies it needs to run
RUN cp home/runner/bin/runsvc.sh home/runner/runsvc.sh && chmod +x home/runner/runsvc.sh

# update permissions
RUN chown -R actions /home/runner

# copy over the entrypoint.sh script
COPY entrypoint.sh .

# make the script executable
RUN chmod +x ./entrypoint.sh 

# since the config and run script for actions are not allowed to be run by root,
# set the user to "actions" so all subsequent commands are run as the "actions" user
USER actions

# add helm diff plugin, needs to be executed as user "actions"
RUN helm plugin install https://github.com/databus23/helm-diff

# set the entrypoint to the entrypoint.sh script
ENTRYPOINT ["./entrypoint.sh"] 