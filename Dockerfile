FROM docker:18.09

# pre-requirements and utilities
RUN apk update \
        && apk upgrade \
        && apk add --no-cache \
            bash bash-completion \
            ca-certificates \
            curl \
            git grep gzip \
            jq \
            make \
            openssh-client \
            python3 py3-pip \
            tar \
        && pip3 install --no-cache-dir yq

ARG AWSCLI_VERSION
ARG AWSLOGS_VERSION
ARG AWS_SAM_CLI_VERSION
ARG DOCKER_COMPOSE_VERSION
ARG ECSPRESSO_VERSION
ARG APEX_VERSION
ARG ECS_DEPLOY_VERSION
ARG ECS_CLI_VERSION

RUN set -ex; \
        pip3 install --no-cache-dir \
            awscli==${AWSCLI_VERSION} \
            awslogs==${AWSLOGS_VERSION} \
            docker-compose==${DOCKER_COMPOSE_VERSION} \
        ; \
# https://pypi.org/project/aws-sam-cli/
        apk add --no-cache gcc musl-dev python3-dev \
            && pip3 install --no-cache-dir aws-sam-cli==${AWS_SAM_CLI_VERSION} \
        ; \
# ecspresso
        curl -L -o /usr/local/bin/ecspresso https://github.com/kayac/ecspresso/releases/download/v${ECSPRESSO_VERSION}/ecspresso-v${ECSPRESSO_VERSION}-linux-amd64 \
            && chmod +x /usr/local/bin/ecspresso \
            && ecspresso version \
        ; \
# https://github.com/apex/apex#installation
        curl -o install.sh https://raw.githubusercontent.com/apex/apex/master/install.sh \
            && sh ./install.sh ${APEX_VERSION} \
            && rm ./install.sh \
            && apex version \
        ; \
# https://github.com/silinternational/ecs-deploy#installation
        curl -o /usr/local/bin/ecs-deploy https://raw.githubusercontent.com/silinternational/ecs-deploy/${ECS_DEPLOY_VERSION}/ecs-deploy \
            && chmod +x /usr/local/bin/ecs-deploy \
            && ecs-deploy --version \
        ; \
# https://github.com/aws/amazon-ecs-cli#installing
        apk add --no-cache gnupg \
            && curl https://raw.githubusercontent.com/aws/amazon-ecs-cli/${ECS_CLI_VERSION}/amazon-ecs-public-key.gpg | gpg --import \
            && curl -o /root/.gnupg/ecs-cli.asc https://s3.amazonaws.com/amazon-ecs-cli/ecs-cli-linux-amd64-v${ECS_CLI_VERSION}.asc \
            && curl -o /usr/local/bin/ecs-cli https://s3.amazonaws.com/amazon-ecs-cli/ecs-cli-linux-amd64-v${ECS_CLI_VERSION} \
            && gpg --verify /root/.gnupg/ecs-cli.asc /usr/local/bin/ecs-cli \
            && chmod +x /usr/local/bin/ecs-cli \
            && ecs-cli --version;

# Inherit https://github.com/docker-library/docker/blob/master/18.05/Dockerfile
# NOTE: If you want do not use docker-daemon, specify run args `--entrypoint="..."`
#ENTRYPOINT []

CMD ["/bin/bash"]
