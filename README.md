# cfstep-aws-parameter-store
Step to retrieve parameter values from AWS Parameter Store

![AWS Parameter Store](icon.svg)

https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-parameter-store.html

Requires AWS CLI Keys or AWS Credentials file

https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html

`AWS_ACCESS_KEY_ID` – Specifies an AWS access key associated with an IAM user or role.

`AWS_SECRET_ACCESS_KEY` – Specifies the secret key associated with the access key. This is essentially the "password" for the access key

`AWS_DEFAULT_REGION` – Specifies the AWS Region to send the request to.

OR

`AWS_CREDENTIALS_FILE` - You must base64 encode the file and add to the variable `AWS_CREDENTIALS_FILE` to use this step.

```
  CreateAWSCredentialsFile:
    image: alpine:3.10
    title: Creating AWS Credentials File...
    working_directory: ${{main_clone}}
    commands:
      - mkdir -p ${CF_VOLUME_PATH}/.aws
      - 'echo -n $AWS_CREDENTIALS_FILE | base64 -d > ${CF_VOLUME_PATH}/.aws/credentials'
      - cf_export AWS_SHARED_CREDENTIALS_FILE=${CF_VOLUME_PATH}/.aws/credentials
```

Step Arguments:

| ENVIRONMENT VARIABLE | DEFAULT | TYPE | REQUIRED | DESCRIPTION |
|----------------------------|----------|---------|----------|---------------------------------------------------------------------------------------------------------------------------------|
| PARAMETERS | null | string | Yes | Space delimited list of parameter names |

Freestyle Usage:

```
  GetAWSParameters:
    image: dustinvanbuskirk/cfstep-aws-parameter-store:alpha
    title: Gather AWS Parameters...
    environment:
    - 'PARAMETERS=${{PARAMETERS}}'
    commands:
    - aws ssm get-parameters --names ${PARAMETERS} --with-decryption --query "Parameters[*].{Name:Name,Value:Value}" | jq '.[] | {"key": .Name, "value": .Value} | "\(.key)=\(.value)"' | tr -d '"' >> ${{CF_VOLUME_PATH}}/env_vars_to_export
```