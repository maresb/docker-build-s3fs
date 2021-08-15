# docker-build-s3fs

#### Builds a .deb for Ubuntu 18.04/20.04 based on a specified commit from the s3fs-fuse GitHub repository.

This Dockerfile repackages the Ubuntu 20.04 focal `.deb` file (currently [`s3fs_1.86-1_amd64.deb`](https://packages.ubuntu.com/focal/amd64/s3fs/download)) with updated source code from the [s3fs-fuse GitHub repository](https://github.com/s3fs-fuse/s3fs-fuse).  This is all done at Docker build time.

## Download

### [Download the resulting .deb file](https://media.githubusercontent.com/media/maresb/docker-build-s3fs/master/builds/s3fs_1.90+git-v1.90-3_amd64.deb) (rendered from [v1.90](https://github.com/s3fs-fuse/s3fs-fuse/tree/v1.90) release) and verify [your preferred checksum](#checksums).

## Links

- GitHub: https://github.com/maresb/docker-build-s3fs

- Docker Hub: https://hub.docker.com/repository/docker/maresb/docker-build-s3fs

- s3fs-fuse: https://github.com/s3fs-fuse/s3fs-fuse


## Build s3fs from Docker

Ubuntu 18.04's outdated version of [s3fs-fuse](https://github.com/s3fs-fuse/s3fs-fuse) (resulting from `apt-get install s3fs`) did not seem to work for me on AWS. Thus I started this project with a Dockerfile which compiles s3fs from a specified GitHub commit.

I need to deploy this to several instances, so I much prefer the speed and
convenience of installing from a `.deb` file as opposed to compiling from source.
For security reasons, I avoid downloading software compiled by random people.
If you trust me<sup><a name="trustmesrc">[1](#trustmedest)</a></sup>, you can download the `.deb` from the above link.  Otherwise, follow the instructions below to build it yourself.

## Installation

Once you have the `.deb` file, run

```bash
sudo apt-get install -y fuse mime-support libxml2 libcurl4 libssl1.1
sudo dpkg -i s3fs_….deb
```

### 1. Compile under Docker.

Complete either a) or b) below.

**a) Either compile locally**
    
Download `Dockerfile` and change to the corresponding directory.

```bash
git clone https://github.com/maresb/docker-build-s3fs.git && cd docker-build-s3fs
```

To render an untagged commit such as [e0712f4](https://github.com/s3fs-fuse/s3fs-fuse/tree/e0712f4),
```bash
docker build -t build-s3fs --build-arg COMMIT_ID=e0712f4 --build-arg S3FS_VERSION=1.85 .
```

or for a tagged commit such as a release version, for example [v1.90](https://github.com/s3fs-fuse/s3fs-fuse/tree/v1.90),

```bash
docker build -t build-s3fs --build-arg COMMIT_ID=v1.90 --build-arg S3FS_VERSION=1.90 .
```

The argument `S3FS_VERSION` should refer to the latest version number as of the commit specified under `COMMIT_ID`.

**b) Or grab a premade image from Docker Hub**

Pull the image from Docker Hub and retag:
```bash
docker pull maresb/docker-build-s3fs
docker image tag maresb/docker-build-s3fs build-s3fs
docker rmi maresb/docker-build-s3fs
```

### 2. Copy the package from the image via a temporary container.
```bash
id=$(docker create build-s3fs)
docker cp $id:s3fs-debian-package.tar .
docker rm -v $id
tar xvf s3fs-debian-package.tar && rm s3fs-debian-package.tar
```

### 3. Clean up.
```bash
docker rmi build-s3fs
docker system prune
```

### For debugging,

If the image successfully builds, you can tag the build stage and look inside with
```bash
docker build -t build-s3fs:build --target build [ADD BUILD ARGS HERE] .
docker run --rm -it build-s3fs:build /bin/bash
```
Otherwise, in the output of a partial build, look for a line with an arrow directly followed by a hash such as
```bash
 ---> df7f92f1a162
```
Then you can look inside at the corresponding point with
```bash
docker run --rm -it df7f92f1a162 /bin/bash
```

# Checksums

Normally, due to last-modified times of files and the timestamp in the changelog,
no two `.deb` files are expected to be exactly the same, even if they have the
exact same content. However, by fixing a build-time, the `.deb` files produced
by this container are reproducible. Thus I can provide a checksum which can be
verified from the download, Docker Hub, and/or a build on your own computer.

NOTE: After some time, discrepancies in the checksums could arise due to updated
dependencies. To compare, I provide logs under [`builds/`](builds).

### md5sums FILE CONTENTS

4f5959c45a22b076fe29790cfaee461e  usr/bin/s3fs
6d4bca76dd57f89e9d698e716cf42542  usr/share/doc/s3fs/changelog.Debian.gz
2c85defc6568bd463d3dc9c5342faab0  usr/share/doc/s3fs/copyright
7ba8239dcc20cbbbe29a0fcb80cc27ed  usr/share/doc/s3fs/examples/passwd-s3fs
657c91890ce90f8987638167ecb7e9af  usr/share/man/man1/s3fs.1.gz


### `s3fs_1.90+git-v1.90-3_amd64.deb` size and checksum

    $ stat --printf="%s bytes\n" s3fs_1.90+git-v1.90-3_amd64.deb
    287872 bytes

    $ md5sum s3fs_1.90+git-v1.90-3_amd64.deb
    b31515c2019eafa037b080dc450ecd6a  s3fs_1.90+git-v1.90-3_amd64.deb
    
    $ sha256sum s3fs_1.90+git-v1.90-3_amd64.deb
    dbb11d65eb5c58dc0c6a77320710c57e426128c20963823943f58830a7531aa3  s3fs_1.90+git-v1.90-3_amd64.deb
    
    $ b2sum s3fs_1.90+git-v1.90-3_amd64.deb
    f6cba9dcad75c1c066d46869bcae0444a36cfbb89afb23455a409df17b7112db5991e8502930bbb584eb58997ca9b80b2f46de4bcbf9b31320f5ae6891fe730d  s3fs_1.90+git-v1.90-3_amd64.deb


### `s3fs` size and checksum

    $ stat --printf="%s bytes\n" s3fs
    829808 bytes

    $ md5sum s3fs
    4f5959c45a22b076fe29790cfaee461e  s3fs
    
    $ sha256sum s3fs
    7c70e4740071feb4890db432a9a1bec220bd44a51569f7d378bb79c94d296af7  s3fs
    
    $ b2sum s3fs
    1d86df38786d501d84bb2774039a7cdc61c63819409c58fdbfe9cc2baae846a8c87a18f32a800ea31a58a488d0d03ae05fa6f396e5fdd40f2ed9057368e2fc6d  s3fs


### `s3fs` size and checksum

    $ stat --printf="%s bytes\n" s3fs
    842040 bytes

    $ md5sum s3fs
    0e6768276f17bb6de2ab0301e0d9ac39  s3fs
    
    $ sha256sum s3fs
    d3969604359364b48ffe89cb6bc088a99988230904020a03d1c6305b4d6415da  s3fs
    
    $ b2sum s3fs
    93bcb251a97699303d987a9086870f8cfb6d127e06272050585f67e7ff8ea75a50d45f488c5c836746053331b4af0f82502add4b29bfc7a89836f2ba56d75f4c  s3fs


Originally I wanted to publish these checksums from Docker Hub.  Indeed, they are pasted directly from the output of my `Dockerfile`.  Unfortunately, [Docker Hub does not publish logs from automated builds](https://github.com/docker/hub-feedback/issues/1787), so that's not possible at this time.  Please support [this issue](https://github.com/docker/hub-feedback/issues/1787) to improve the trustworthiness of automated Docker Hub builds.

# Notes

<a name="trustmedest">[[1]](#trustmesrc)</a> On principle, you should check my Dockerfile and make sure that I'm not doing anything suspicious.
