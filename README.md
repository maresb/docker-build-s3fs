# docker-build-s3fs

##### Updates the Ubuntu 18.04 bionic .deb (currently s3fs_1.82-1_amd64.deb) with a specified commit from the s3fs-fuse GitHub repository.

Project page: https://github.com/maresb/docker-build-s3fs

[Resulting .deb file](https://github.com/maresb/docker-build-s3fs/blob/deb-v1.86/s3fs_1.86+git_amd64.deb?raw=true) rendered from [v1.86](https://github.com/s3fs-fuse/s3fs-fuse/tree/v1.86)

## Build s3fs from Docker

For some reason, the neither the default `apt-get install s3fs` version nor the released version of
[s3fs-fuse](https://github.com/s3fs-fuse/s3fs-fuse) work for me.
(I am running Ubuntu 18.04 on AWS.)
Thus I built this Dockerfile to compile s3fs from a specified GitHub hash.

I need to deploy this to several instances, so I much prefer the speed and
convenience of installing from a `.deb` file as opposed to compiling from source.
For security reasons, I avoid downloading software compiled by random people.
If you trust me, you can download from the above link.  Otherwise, simply follow the
instructions below to build it yourself.

Finally,  `dpkg -i s3fs_….deb` to install.

### Compile under Docker.
```
docker build -t build-s3fs --build-arg COMMIT_ID=e0712f4 --build-arg PACKAGE_VERSION_STRING=1.85+git-e0712f4 .
```

Or, for a release version,

```
docker build -t build-s3fs --build-arg COMMIT_ID=v1.86 --build-arg PACKAGE_VERSION_STRING=1.86+git .
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
