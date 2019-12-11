#!/bin/bash

if [ -z "$PARAMETERS" ]; then
    echo "Please provide parameters"
    exit 1
fi

function getParamsWIthCredentials {
    if [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
        echo "Please provide AWS_SECRET_ACCESS_KEY"
        exit 1
    fi
    if [ -z "$AWS_ACCESS_KEY_ID" ]; then
        echo "Please provide AWS_ACCESS_KEY_ID"
        exit 1
    fi
    if [ -z "$AWS_DEFAULT_REGION" ]; then
        echo "Please provide AWS_DEFAULT_REGION"
        exit 1
    fi
    echo "Use provided credentials."
    rm -r ${CF_VOLUME_PATH}/.aws >> /dev/null 2>&1
    aws ssm get-parameters --names ${PARAMETERS} --with-decryption --query "Parameters[*].{Name:Name,Value:Value}" | jq '.[] | {"key": .Name, "value": .Value} | "\(.key)=\(.value)"' | tr -d '"' >> /codefresh/volume/env_vars_to_export
    result=$?
    if [ $result -eq 0 ]; then
        echo "Parameters exported"
    else
        echo "Parameters were not exported"
    fi
}

rm -r ${CF_VOLUME_PATH}/.aws >> /dev/null 2>&1
mkdir -p ${CF_VOLUME_PATH}/.aws >> /dev/null 2>&1
if [ -z "$AWS_CONFIG" ] || [[ "$AWS_CONFIG" =~ "\${{" ]]; then
    echo "AWS_CONFIG not provided"
else
    echo "Use aws config file"
    echo -n $AWS_CONFIG | base64 -d > $AWS_CONFIG_FILE
fi
if [ -z "$AWS_CREDENTIALS" ] || [[ "$AWS_CREDENTIALS" =~ "\${{" ]]; then
    echo "AWS_CREDENTIALS not provided"
    getParamsWIthCredentials
else
    echo "Use aws credentials file"
    echo -n $AWS_CREDENTIALS | base64 -d > $AWS_SHARED_CREDENTIALS_FILE
    if [ "$AWS_PROFILE" == "" ]|| [[ "$AWS_PROFILE" =~ "\${{" ]]; then
        echo "Please provide AWS_PROFILE"
        exit 1
    fi
    aws ssm get-parameters --profile ${AWS_PROFILE} --names ${PARAMETERS} --with-decryption --query "Parameters[*].{Name:Name,Value:Value}" | jq '.[] | {"key": .Name, "value": .Value} | "\(.key)=\(.value)"' | tr -d '"' >> /codefresh/volume/env_vars_to_export
    result=$?
    if [ $result -eq 0 ]; then
        echo "Parameters exported"
    else
        echo "Parameters were not exported"
    fi
fi