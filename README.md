# docker-build-s3fs

#### Builds a .deb for Ubuntu 18.04 based on a specified commit from the s3fs-fuse GitHub repository.

Links:

- [Download the resulting .deb file](https://raw.githubusercontent.com/maresb/docker-build-s3fs/deb-v1.86/s3fs_1.86+git_amd64.deb) (rendered from [v1.86](https://github.com/s3fs-fuse/s3fs-fuse/tree/v1.86))

- GitHub: https://github.com/maresb/docker-build-s3fs

- Docker Hub: https://hub.docker.com/repository/docker/maresb/docker-build-s3fs

- s3fs-fuse: https://github.com/s3fs-fuse/s3fs-fuse

This Dockerfile repackages the Ubuntu 18.04 bionic `.deb` file (currently [`s3fs_1.82-1_amd64.deb`](https://packages.ubuntu.com/bionic/amd64/s3fs/download)) with source code updated from the [s3fs-fuse GitHub repository](https://github.com/s3fs-fuse/s3fs-fuse).

## Build s3fs from Docker

Ubuntu 18.04's outdated version of [s3fs-fuse](https://github.com/s3fs-fuse/s3fs-fuse) (resulting from `apt-get install s3fs`) does not seem to work for me on AWS. Thus I built this Dockerfile which compiles s3fs from a specified GitHub commit.

I need to deploy this to several instances, so I much prefer the speed and
convenience of installing from a `.deb` file as opposed to compiling from source.
For security reasons, I avoid downloading software compiled by random people.
If you trust me<sup><a name="trustmesrc">[1](#trustmedest)</a></sup>, you can download the `.deb` from the above link.  Otherwise, follow the instructions below to build it yourself.

Once you have the `.deb` file, run `sudo dpkg -i s3fs_….deb` to install.

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

## Notes

<a name="trustmedest">[[1]](#trustmesrc)</a> On principle, you should not trust me (unless you know me personally).  I originally wanted to provide a certifiable `.deb` built automatically on Docker Hub. The `Dockerfile` prints the checksum<sup><a name="checksumsrc">[2](#checksumdest)</a></sup> of the `.deb`.  Unfortunately, [Docker Hub does not publish logs from automated builds](https://github.com/docker/hub-feedback/issues/1787), so unfortunately only I can see the checksum at the moment.  Please support [this issue](https://github.com/docker/hub-feedback/issues/1787) to improve the trustworthiness of automated Docker Hub builds.

<a name="checksumdest">[[2]](#checksumsrc)</a> There is not even a unique checksum of the resulting `.deb` for a given commit, since the archived files have a last-modified time according to the build time.
