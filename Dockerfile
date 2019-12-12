FROM python:3.8.0-alpine3.10

ENV AWSCLI_VERSION "1.16.266"
ENV JQ_VERSION "1.6-r0"

# Install jq for JSON parsing

RUN apk add --update \
  jq=1.6-r0 \
  bash \
  && rm -rf /var/cache/apk/*

# Install AWS CLI

RUN pip install --no-cache-dir awscli==${AWSCLI_VERSION}

LABEL alpine="3.10"
LABEL jq="${JQ_VERSION}"
LABEL python="3.8.0"
LABEL aws-cli="${AWSCLI_VERSION}"

VOLUME /root/.aws

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
