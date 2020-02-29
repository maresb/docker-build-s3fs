# docker-build-s3fs

#### Builds a .deb for Ubuntu 18.04 based on a specified commit from the s3fs-fuse GitHub repository.

This Dockerfile repackages the very old Ubuntu 18.04 bionic `.deb` file (currently [`s3fs_1.82-1_amd64.deb`](https://packages.ubuntu.com/bionic/amd64/s3fs/download)) with updated source code from the [s3fs-fuse GitHub repository](https://github.com/s3fs-fuse/s3fs-fuse).  This is all done at Docker build time.

## Download

### [Download the resulting .deb file](https://media.githubusercontent.com/media/maresb/docker-build-s3fs/master/builds/s3fs_1.86+git-v1.86-2_amd64.deb) (rendered from [v1.86](https://github.com/s3fs-fuse/s3fs-fuse/tree/v1.86) release) and verify [your preferred checksum](#checksums).

## Links

- GitHub: https://github.com/maresb/docker-build-s3fs

- Docker Hub: https://hub.docker.com/repository/docker/maresb/docker-build-s3fs

- s3fs-fuse: https://github.com/s3fs-fuse/s3fs-fuse


## Build s3fs from Docker

Ubuntu 18.04's outdated version of [s3fs-fuse](https://github.com/s3fs-fuse/s3fs-fuse) (resulting from `apt-get install s3fs`) does not seem to work for me on AWS. Thus I built this Dockerfile which compiles s3fs from a specified GitHub commit.

I need to deploy this to several instances, so I much prefer the speed and
convenience of installing from a `.deb` file as opposed to compiling from source.
For security reasons, I avoid downloading software compiled by random people.
If you trust me<sup><a name="trustmesrc">[1](#trustmedest)</a></sup>, you can download the `.deb` from the above link.  Otherwise, follow the instructions below to build it yourself.

Once you have the `.deb` file, run `sudo dpkg -i s3fs_….deb` to install.

### 1. Compile under Docker.

Complete either a) or b) below.

**a) Either compile locally**
    
Download `Dockerfile` and change to the corresponding directory.

```
git clone https://github.com/maresb/docker-build-s3fs.git && cd docker-build-s3fs
```

To render an untagged commit such as [e0712f4](https://github.com/s3fs-fuse/s3fs-fuse/tree/e0712f4),
```
docker build -t build-s3fs --build-arg COMMIT_ID=e0712f4 --build-arg S3FS_VERSION=1.85 .
```

or for a tagged commit such as a release version, for example [v1.86](https://github.com/s3fs-fuse/s3fs-fuse/tree/v1.86),

```
docker build -t build-s3fs --build-arg COMMIT_ID=v1.86 --build-arg S3FS_VERSION=1.86 .
```

The argument `S3FS_VERSION` should refer to the latest version number as of the commit specified under `COMMIT_ID`.

**b) Or grab a premade image from Docker Hub**

Pull the image from Docker Hub and retag:
```
docker pull maresb/docker-build-s3fs
docker image tag maresb/docker-build-s3fs build-s3fs
docker rmi maresb/docker-build-s3fs
```

### 2. Copy the package from the image via a temporary container.
```
id=$(docker create build-s3fs)
docker cp $id:s3fs-debian-package.tar .
docker rm -v $id
tar xvf s3fs-debian-package.tar && rm s3fs-debian-package.tar
```

### 3. Clean up.
```
docker rmi build-s3fs
docker purge
```

### For debugging,

If the image successfully builds, you can tag the build stage and look inside with
```
docker build -t build-s3fs:build --target build [ADD BUILD ARGS HERE] .
docker run --rm -it build-s3fs:build /bin/bash
```
Otherwise, in the output of a partial build, look for a line with an arrow directly followed by a hash such as
```
 ---> df7f92f1a162
```
Then you can look inside at the corresponding point with
```
docker run --rm -it df7f92f1a162 /bin/bash
```

# Checksums

Normally, due to last-modified times of files and the timestamp in the changelog,
no two `.deb` files are expected to be exactly the same, even if they have the
exact same content. However, by fixing a build-time, the `.deb` files produced
by this container are reproducible. Thus I can provide a checksum which can be
verified from the download, Docker Hub, and/or a build on your own computer.

### `s3fs_1.86+git-v1.86-2_amd64.deb` size and checksum

    $ stat --printf="%s bytes\n" s3fs_1.86+git-v1.86-2_amd64.deb
    225252 bytes

    $ md5sum s3fs_1.86+git-v1.86-2_amd64.deb
    7a3cf63bc18437926a1b686dfacf9c83  s3fs_1.86+git-v1.86-2_amd64.deb
    
    $ sha256sum s3fs_1.86+git-v1.86-2_amd64.deb
    3291d3ee880b29848516d93d76d080fed5e8c5f471d8527e181964577a50dd80  s3fs_1.86+git-v1.86-2_amd64.deb
    
    $ b2sum s3fs_1.86+git-v1.86-2_amd64.deb
    18f49400731e708ec8fff3170f0eeeef7bedc00995337f93f3575ba0773847d061215c47bf1d05fd6591928584172a8b49cee22a306b1ced7eff744c75a759ae  s3fs_1.86+git-v1.86-2_amd64.deb

Originally I wanted to publish these checksums from Docker Hub.  Indeed, they are pasted directly from the output of my `Dockerfile`.  Unfortunately, [Docker Hub does not publish logs from automated builds](https://github.com/docker/hub-feedback/issues/1787), so that's not possible at this time.  Please support [this issue](https://github.com/docker/hub-feedback/issues/1787) to improve the trustworthiness of automated Docker Hub builds.

# Notes

<a name="trustmedest">[[1]](#trustmesrc)</a> On principle, you should check my Dockerfile and make sure that I'm not doing anything suspicious.
