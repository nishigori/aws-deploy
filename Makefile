include install_versions.txt

DOCKER_IMAGE   := nishigori/aws-deploy
ARCHIVE_NUMBER := $(shell date +%Y%m%d)

.PHONY: check image push* archive

check:
	docker version

image: check pull
	docker build -t $(DOCKER_IMAGE) \
		--build-arg AWSCLI_VERSION=$(AWSCLI_VERSION) \
		--build-arg AWS_SAM_CLI_VERSION=$(AWS_SAM_CLI_VERSION) \
		--build-arg ECS_CLI_VERSION=$(ECS_CLI_VERSION) \
		--build-arg ECS_DEPLOY_VERSION=$(ECS_DEPLOY_VERSION) \
		--build-arg ECSPRESSO_VERSION=$(ECSPRESSO_VERSION) \
		--build-arg AWSLOGS_VERSION=$(AWSLOGS_VERSION) \
		.

pull:
	-docker pull $(DOCKER_IMAGE)

push: push_latest

push_latest:
	docker login -u $$DOCKER_USER -p $$DOCKER_PASS
	docker push $(DOCKER_IMAGE)

push_archive:
	docker login -u $$DOCKER_USER -p $$DOCKER_PASS
	docker push $(DOCKER_IMAGE):$(ARCHIVE_NUMBER)

archive:
	docker tag $(DOCKER_IMAGE):latest $(DOCKER_IMAGE):$(ARCHIVE_NUMBER)
	docker save -o docker-image-$(ARCHIVE_NUMBER).tar $(DOCKER_IMAGE):$(ARCHIVE_NUMBER)
