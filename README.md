# docker-build-s3fs

#### Builds a .deb for Ubuntu 18.04 based on a specified commit from the s3fs-fuse GitHub repository.

This Dockerfile repackages the very old Ubuntu 18.04 bionic `.deb` file (currently [`s3fs_1.82-1_amd64.deb`](https://packages.ubuntu.com/bionic/amd64/s3fs/download)) with updated source code from the [s3fs-fuse GitHub repository](https://github.com/s3fs-fuse/s3fs-fuse).  This is all done at Docker build time.

## Download

### [Download the resulting .deb file](https://media.githubusercontent.com/media/maresb/docker-build-s3fs/master/builds/s3fs_1.87+git-v1.87-2_amd64.deb) (rendered from [v1.87](https://github.com/s3fs-fuse/s3fs-fuse/tree/v1.87) release) and verify [your preferred checksum](#checksums).

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

## Installation

Once you have the `.deb` file, run 

```bash
sudo apt-get install -y fuse mime-support libxml2
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

or for a tagged commit such as a release version, for example [v1.87](https://github.com/s3fs-fuse/s3fs-fuse/tree/v1.87),

```bash
docker build -t build-s3fs --build-arg COMMIT_ID=v1.87 --build-arg S3FS_VERSION=1.87 .
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
docker purge
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

### `s3fs_1.87+git-v1.87-2_amd64.deb` size and checksum

    $ stat --printf="%s bytes\n" s3fs_1.87+git-v1.87-2_amd64.deb
    239628 bytes

    $ md5sum s3fs_1.87+git-v1.87-2_amd64.deb
    68a3dc87490699b730a3b02b6fb80af9  s3fs_1.87+git-v1.87-2_amd64.deb
    
    $ sha256sum s3fs_1.87+git-v1.87-2_amd64.deb
    aeac5a1dbfdbf530d1ab07ca966f53046a79a8319830c1d5a9a5d53447d2588c  s3fs_1.87+git-v1.87-2_amd64.deb
    
    $ b2sum s3fs_1.87+git-v1.87-2_amd64.deb
    b4fe476a584e516e2ff35b4aaedc23ac9bc10c0b761820745a1a8ea4656c581a11bb5634b2dff59685744e33408459c7e8e8695d349d8d4e919e6876f7056b7e  s3fs_1.87+git-v1.87-2_amd64.deb


### `s3fs` size and checksum

    $ stat --printf="%s bytes\n" s3fs
    657704 bytes

    $ md5sum s3fs
    e5e675c6041cb6c7a689877a7df2de61  s3fs
    
    $ sha256sum s3fs
    dc2f8d53f789a36bfb5e4eec430d017a1a5d351412f120253a013fcfc409a034  s3fs
    
    $ b2sum s3fs
    03b9d1362d2fe0fb4532f415e19434885be70cd897878e2039b95bda7398e92753d68559fe777f620c4b366dfb1db7195fd2bd32410f288e1b1d98d72fd35232  s3fs


Originally I wanted to publish these checksums from Docker Hub.  Indeed, they are pasted directly from the output of my `Dockerfile`.  Unfortunately, [Docker Hub does not publish logs from automated builds](https://github.com/docker/hub-feedback/issues/1787), so that's not possible at this time.  Please support [this issue](https://github.com/docker/hub-feedback/issues/1787) to improve the trustworthiness of automated Docker Hub builds.

# Notes

<a name="trustmedest">[[1]](#trustmesrc)</a> On principle, you should check my Dockerfile and make sure that I'm not doing anything suspicious.
