#!/bin/bash

ORGANIZATION=$ORGANIZATION
ACCESS_TOKEN=$ACCESS_TOKEN
REPO=$REPO
ENVIRONMENT=$ENVIRONMENT

REG_TOKEN=$(curl -sX POST -H "Authorization: token ${ACCESS_TOKEN}" https://api.github.com/repos/${ORGANIZATION}/${REPO}/actions/runners/registration-token | jq .token --raw-output)

cd /home/runner

./config.sh --url https://github.com/${ORGANIZATION}/${REPO} --token ${REG_TOKEN} --name runner-${ENVIRONMENT} --work work --labels ${ENVIRONMENT},

cleanup() {
    echo "Removing runner..."
    ./config.sh remove --unattended --token ${REG_TOKEN}
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

./run.sh & wait $!