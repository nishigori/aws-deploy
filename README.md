# Docker image includes a lot of aws deployment tools

[![CircleCI][circleci-badge]][circleci-link] [![Docker Hub][dockerhub-badge]][dockerhub-link] [![GitHub License][license-badge]][license-link]

[circleci-badge]:  https://circleci.com/gh/nishigori/aws-deploy.svg?style=svg
[circleci-link]:   https://circleci.com/gh/nishigori/aws-deploy
[license-badge]:   https://img.shields.io/badge/license-MIT-blue.svg
[license-link]:    https://raw.githubusercontent.com/nishigori/aws-deploy/master/LICENSE
[dockerhub-badge]: https://img.shields.io/docker/stars/nishigori/aws-deploy.svg
[dockerhub-link]:  https://hub.docker.com/r/nishigori/aws-deploy/

* [aws-cli](https://pypi.org/project/awscli/)
* For AWS Lambda
  * [aws-sam-cli](https://pypi.org/project/aws-sam-cli/)
  * [apex](https://github.com/apex/apex)
* For ECS
  * [Amazon ECS CLI (ecs-cli)](https://github.com/aws/amazon-ecs-cli)
  * [ecspresso](https://github.com/kayac/ecspresso)
  * [silinternational/ecs-deploy](https://github.com/silinternational/ecs-deploy)
* Misc
  * [awslogs](https://pypi.org/project/awslogs/)

The above libraries version is written in *install_versions.txt*

And there image has docker-daemon for ecs/eks, and runs on ci services (e.g. circleci)

## Usage

```sh
$ docker run --rm -t \
    -v $HOME/.aws:/root/.aws:ro \
    nishigori/aws-deploy \
    aws --region us-east-1 health describe-events --max-items 1 | jq ".events[]"

{
  "arn": "arn:aws:health:global::event/AWS_IAM_OPERATIONAL_ISSUE_1529622992",
  "service": "IAM",
  "eventTypeCode": "AWS_IAM_OPERATIONAL_ISSUE",
  "eventTypeCategory": "issue",
  "region": "global",
  "startTime": 1529622992,
  "endTime": 1529623481,
  "lastUpdatedTime": 1529623588.832,
  "statusCode": "closed"
}
```
