#!/bin/bash

REPOSITORY=$(c12h8cl6/aldrin_repo)
ACCESS_TOKEN=$(A6HFKIQLEC3RM5KQDN4447LG4AVMQ)


echo "REPO ${REPOSITORY}"
echo "ACCESS_TOKEN ${ACCESS_TOKEN}"

#REG_TOKEN=$(curl -X POST -H "Authorization: token ${ACCESS_TOKEN}" -H "Accept: application/vnd.github+json" #https://api.github.com/repos/${REPOSITORY}/actions/runners/registration-token | jq .token --raw-output)

cd /home/docker/actions-runner

./config.sh --url https://github.com/c12h8cl6/aldrin_repo --token A6HFKIQLEC3RM5KQDN4447LG4AVMQ

cleanup() {
    echo "Removing runner..."
    ./config.sh remove --unattended --token A6HFKIQLEC3RM5KQDN4447LG4AVMQ
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

./run.sh & wait $!

