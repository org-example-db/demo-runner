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

# Fill in your labels as appropriate here
LABEL maintainer="GitHub" \
    github_actions_version="${GH_RUNNER_VERSION}"

# Create a user for running actions
RUN useradd -m actions
RUN mkdir -p /home/actions ${AGENT_TOOLS_DIRECTORY}
WORKDIR /home/actions

# add additional packages as necessary
RUN apt-get install -y curl jq wget

# add helm 
RUN cd /home && mkdir /helm && cd /helm \
    && wget https://get.helm.sh/helm-v${HELM}-linux-amd64.tar.gz \
    && tar xvf helm-v${HELM}-linux-amd64.tar.gz \
    && mv linux-amd64/helm /usr/local/bin/ \
    && rm helm-v${HELM}-linux-amd64.tar.gz \
    && rm -rf linux-amd64

# add helm diff plugin, needs to be executed as user "actions"
RUN helm plugin install https://github.com/databus23/helm-diff

# add github runner
RUN curl -L -O https://github.com/actions/runner/releases/download/v${GH_RUNNER_VERSION}/actions-runner-linux-x64-${GH_RUNNER_VERSION}.tar.gz \
    && tar -zxf actions-runner-linux-x64-${GH_RUNNER_VERSION}.tar.gz \
    && rm -f actions-runner-linux-x64-${GH_RUNNER_VERSION}.tar.gz \
    && ./bin/installdependencies.sh 

# Copy out the runsvc.sh script to the root directory for running the service
RUN cp bin/runsvc.sh . && chmod +x ./runsvc.sh

COPY entrypoint.sh .
RUN chmod +x ./entrypoint.sh

# Now that the OS has been updated to include required packages, update ownership and then switch to actions user
RUN chown -R actions:actions /home/actions ${AGENT_TOOLS_DIRECTORY}

USER actions
CMD [ "./entrypoint.sh" ]