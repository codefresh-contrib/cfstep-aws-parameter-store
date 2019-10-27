# cfstep-aws-parameter-store
Step to retrieve parameter values from AWS Parameter Store

<img src="icon.svg" width="100" height="100">

https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-parameter-store.html

Requires AWS CLI Keys or AWS Credentials file

https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html

`AWS_ACCESS_KEY_ID` – Specifies an AWS access key associated with an IAM user or role.

`AWS_SECRET_ACCESS_KEY` – Specifies the secret key associated with the access key. This is essentially the "password" for the access key

`AWS_DEFAULT_REGION` – Specifies the AWS Region to send the request to.

OR

`AWS_CREDENTIALS_FILE` - You must base64 encode the file and add to the variable `AWS_CREDENTIALS_FILE` to use this step.

`AWS_PROFILE` – Specifies the name of the CLI profile with the credentials and options to use. This can be the name of a profile stored in a credentials or config file, or the value default to use the default profile. If you specify this environment variable, it overrides the behavior of using the profile named [default] in the configuration file.

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
| AWS_ACCESS_KEY_ID | null | string | For CLI | AWS Access Key |
| AWS_CREDENTIALS_FILE | null | base64 | For Profile | base64 encoded credentials file |
| AWS_DEFAULT_REGION | null | string | For CLI | AWS Region |
| AWS_PROFILE | null | string | For Profile | AWS Profile |
| AWS_SECRET_ACCESS_KEY | null | string | For CLI | AWS Secret Access Key |
| AWS_SHARED_CREDENTIALS_FILE | null | string | For Profile | Path to AWS Credentials file |
| PARAMETERS | null | string | Yes | Space delimited list of parameter names |

Freestyle Usage:

```
  GetAWSParameters:
    image: codefreshplugins/cfstep-aws-parameter-store:alpha
    title: Gather AWS Parameters...
    environment:
    - 'PARAMETERS=${{PARAMETERS}}'
    commands:
    - >-
      aws ssm get-parameters --names ${PARAMETERS} --with-decryption --query "Parameters[*].{Name:Name,Value:Value}" | jq '.[] | {"key": .Name, "value": .Value} | "\(.key)=\(.value)"' | tr -d '"' >> /codefresh/volume/env_vars_to_export
```