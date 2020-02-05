# docker-build-s3fs

Project page: https://github.com/maresb/docker-build-s3fs

[Resulting .deb file](https://github.com/maresb/docker-build-s3fs/blob/deb-e0712f4/s3fs_1.85+git-e0712f4_amd64.deb?raw=true) rendered from [e0712f4](https://github.com/s3fs-fuse/s3fs-fuse/tree/e0712f4)

## Build s3fs from Docker

For some reason, the released version of [s3fs-fuse](https://github.com/s3fs-fuse/s3fs-fuse) doesn't work for me.
Thus I built this Dockerfile to compile it from a specified GitHub hash.

### Compile under Docker.
```
docker build -t build-s3fs --build-arg COMMIT_HASH=e0712f4 --build-arg VERSION_STRING=1.85+git-e0712f4 .
```

### Copy the package from the image via a temporary container.
```
debfile=$(docker run --rm build-s3fs sh -c "ls *.deb")
id=$(docker create build-s3fs)
docker cp $id:$debfile .
docker rm -v $id 
```

### Clean up.
```
docker rmi build-s3fs
docker purge
```

### For debugging,
```
docker run --rm -it build-s3fs /bin/bash
```
