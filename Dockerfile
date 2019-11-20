FROM docker:19.03

# pre-requirements and utilities
ENV LANG=C.UTF-8
RUN set -ex; \
        apk update \
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
        && pip3 install --no-cache-dir yq \
        && : "ecspresso dependencies for alpine glibc differences" \
        && ALPINE_GLIBC_BASE_URL="https://github.com/sgerrand/alpine-pkg-glibc/releases/download" \
        && ALPINE_GLIBC_PACKAGE_VERSION="2.30-r0" \
        && ALPINE_GLIBC_BASE_PACKAGE_FILENAME="glibc-$ALPINE_GLIBC_PACKAGE_VERSION.apk" \
        && ALPINE_GLIBC_BIN_PACKAGE_FILENAME="glibc-bin-$ALPINE_GLIBC_PACKAGE_VERSION.apk" \
        && ALPINE_GLIBC_I18N_PACKAGE_FILENAME="glibc-i18n-$ALPINE_GLIBC_PACKAGE_VERSION.apk" \
        && apk add --no-cache --virtual=.build-dependencies wget ca-certificates \
        && echo \
            "-----BEGIN PUBLIC KEY-----\
            MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEApZ2u1KJKUu/fW4A25y9m\
            y70AGEa/J3Wi5ibNVGNn1gT1r0VfgeWd0pUybS4UmcHdiNzxJPgoWQhV2SSW1JYu\
            tOqKZF5QSN6X937PTUpNBjUvLtTQ1ve1fp39uf/lEXPpFpOPL88LKnDBgbh7wkCp\
            m2KzLVGChf83MS0ShL6G9EQIAUxLm99VpgRjwqTQ/KfzGtpke1wqws4au0Ab4qPY\
            KXvMLSPLUp7cfulWvhmZSegr5AdhNw5KNizPqCJT8ZrGvgHypXyiFvvAH5YRtSsc\
            Zvo9GI2e2MaZyo9/lvb+LbLEJZKEQckqRj4P26gmASrZEPStwc+yqy1ShHLA0j6m\
            1QIDAQAB\
            -----END PUBLIC KEY-----" | sed 's/   */\n/g' > "/etc/apk/keys/sgerrand.rsa.pub" \
        && wget \
            "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
            "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
            "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" \
        && apk add --no-cache \
            "$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
            "$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
            "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" \
        && rm "/etc/apk/keys/sgerrand.rsa.pub" \
        && /usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 "$LANG" || true \
        && echo "export LANG=$LANG" > /etc/profile.d/locale.sh \
        && apk del glibc-i18n \
        && rm "/root/.wget-hsts" \
        && apk del .build-dependencies \
        && rm \
            "$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
            "$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
            "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME"

ARG AWSCLI_VERSION
ARG AWSLOGS_VERSION
ARG AWS_SAM_CLI_VERSION
ARG ECSPRESSO_VERSION
ARG APEX_VERSION
ARG ECS_DEPLOY_VERSION
ARG ECS_CLI_VERSION

RUN set -ex; \
        pip3 install --no-cache-dir \
            awscli==${AWSCLI_VERSION} \
            awslogs==${AWSLOGS_VERSION} \
        ; \
        : "https://pypi.org/project/aws-sam-cli/"; \
        apk add --no-cache gcc musl-dev python3-dev \
            && pip3 install --no-cache-dir aws-sam-cli==${AWS_SAM_CLI_VERSION} \
        ; \
        : "https://github.com/apex/apex#installation"; \
        curl -o install.sh https://raw.githubusercontent.com/apex/apex/master/install.sh \
            && sh ./install.sh ${APEX_VERSION} \
            && rm ./install.sh \
            && apex version \
        ; \
        : "ecspresso"; \
        curl -L -o /usr/local/bin/ecspresso https://github.com/kayac/ecspresso/releases/download/v${ECSPRESSO_VERSION}/ecspresso-v${ECSPRESSO_VERSION}-linux-amd64 \
            && chmod +x /usr/local/bin/ecspresso \
            && ecspresso version \
        ; \
        : "https://github.com/silinternational/ecs-deploy#installation"; \
        curl -o /usr/local/bin/ecs-deploy https://raw.githubusercontent.com/silinternational/ecs-deploy/${ECS_DEPLOY_VERSION}/ecs-deploy \
            && chmod +x /usr/local/bin/ecs-deploy \
            && ecs-deploy --version \
        ; \
        : "https://github.com/aws/amazon-ecs-cli#installing"; \
        apk add --no-cache gnupg \
            && curl https://raw.githubusercontent.com/aws/amazon-ecs-cli/v${ECS_CLI_VERSION}/amazon-ecs-public-key.gpg | gpg --import \
            && curl -o /root/.gnupg/ecs-cli.asc https://s3.amazonaws.com/amazon-ecs-cli/ecs-cli-linux-amd64-v${ECS_CLI_VERSION}.asc \
            && curl -o /usr/local/bin/ecs-cli https://s3.amazonaws.com/amazon-ecs-cli/ecs-cli-linux-amd64-v${ECS_CLI_VERSION} \
            && gpg --verify /root/.gnupg/ecs-cli.asc /usr/local/bin/ecs-cli \
            && chmod +x /usr/local/bin/ecs-cli \
            && ecs-cli --version;

# Inherit https://github.com/docker-library/docker/blob/master/18.05/Dockerfile
# NOTE: If you want do not use docker-daemon, specify run args `--entrypoint="..."`
#ENTRYPOINT []

CMD ["/bin/bash"]
