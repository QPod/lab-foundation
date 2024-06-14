# DockerKit

In this docker image (DockerKit), the following tools are included:

- [docker-compose](https://github.com/docker/compose): tool for running multi-container applications on Docker.

- [image-syncer](https://github.com/AliyunContainerService/image-syncer): along with some Python scripts used to sync docker images between docker registries.

## Image Syncer

With the help of `image-sync`, you can easily have your docker images copied from one registry to another, or run in batch mode.

Below is an example of sync one docker image:

```shell
docker run --rm \
  -e DOCKER_REGISTRY_PASSWORD='' \
  -e DOCKER_REGISTRY_USERNAME='' \
  -e DOCKER_MIRROR_REGISTRY_USERNAME='' \
  -e DOCKER_MIRROR_REGISTRY_PASSWORD='' \
  qpod/docker-kit python /opt/utils/image-syncer/run_sync.py library/ubuntu --source-registry='docker.io' --target-registry='quay.io'  
```

Fill the environment variables above, and more details can be found in code: `./work/image-syncer/run_sync.py`.
