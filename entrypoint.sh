#!/bin/bash

if [ -z "$PARAMETERS" ]; then
    echo "Please provide parameters"
    exit 1
fi

if [ "$CONFIGS" == true ] ; then
    rm -r ${CF_VOLUME_PATH}/.aws >> /dev/null 2>&1
    if [[ $AWS_CREDENTIALS == "" ]] && [[ $AWS_CREDENTIALS =~ \${{* ]]; then
        echo "Credentials is not provided or not base64 encoded"
        exit 1
    elif [[ $AWS_CONFIG == "" ]] && [[ $AWS_CONFIG =~ \${{* ]]; then
        echo "Config is not provided or not base64 encoded"
        exit 1
    else
        if [ "$PROFILE" == "" ]; then
            echo "AWS_PROFILE not provided. Using default"
            AWS_PROFILE="default"
        else
            AWS_PROFILE=$PROFILE
        fi
        mkdir -p ${CF_VOLUME_PATH}/.aws >> /dev/null 2>&1
        echo -n $AWS_CREDENTIALS | base64 -d > $AWS_SHARED_CREDENTIALS_FILE
        echo -n $AWS_CONFIG | base64 -d > $AWS_CONFIG_FILE
        echo "Use credentials file."
        aws ssm get-parameters --profile ${AWS_PROFILE} --names ${PARAMETERS} --with-decryption --query "Parameters[*].{Name:Name,Value:Value}" | jq '.[] | {"key": .Name, "value": .Value} | "\(.key)=\(.value)"' | tr -d '"' >> /codefresh/volume/env_vars_to_export
    fi
else
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
fi

