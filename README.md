# docker-build-s3fs

#### Builds a .deb for Ubuntu 18.04 based on a specified commit from the s3fs-fuse GitHub repository.

This Dockerfile repackages the very old Ubuntu 18.04 bionic `.deb` file (currently [`s3fs_1.82-1_amd64.deb`](https://packages.ubuntu.com/bionic/amd64/s3fs/download)) with updated source code from the [s3fs-fuse GitHub repository](https://github.com/s3fs-fuse/s3fs-fuse).  This is all done at Docker build time.

## Download

### [Download the resulting .deb file](https://media.githubusercontent.com/media/maresb/docker-build-s3fs/master/builds/s3fs_1.88+git-v1.88-2_amd64.deb) (rendered from [v1.88](https://github.com/s3fs-fuse/s3fs-fuse/tree/v1.88) release) and verify [your preferred checksum](#checksums).

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

or for a tagged commit such as a release version, for example [v1.88](https://github.com/s3fs-fuse/s3fs-fuse/tree/v1.88),

```bash
docker build -t build-s3fs --build-arg COMMIT_ID=v1.88 --build-arg S3FS_VERSION=1.88 .
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

590abee042233159e306cdfd2fd06024  usr/bin/s3fs
276163e4449305310fb4d234ac923a2a  usr/share/doc/s3fs/changelog.Debian.gz
77f9561b63b1d6d232ecddbc2f3aeb28  usr/share/doc/s3fs/copyright
7ba8239dcc20cbbbe29a0fcb80cc27ed  usr/share/doc/s3fs/examples/passwd-s3fs
f24ecfc73b4b11042a614fc2c079fa9a  usr/share/man/man1/s3fs.1.gz


### `s3fs_1.88+git-v1.88-2_amd64.deb` size and checksum

    $ stat --printf="%s bytes\n" s3fs_1.88+git-v1.88-2_amd64.deb
    260052 bytes

    $ md5sum s3fs_1.88+git-v1.88-2_amd64.deb
    40f1a38de2c370f5415900d8ad5b2dd3  s3fs_1.88+git-v1.88-2_amd64.deb
    
    $ sha256sum s3fs_1.88+git-v1.88-2_amd64.deb
    56c3c6c6c5adc367968e5ea11a171a62fc95eae1a250d8dc79d01f63ff9c3ae5  s3fs_1.88+git-v1.88-2_amd64.deb
    
    $ b2sum s3fs_1.88+git-v1.88-2_amd64.deb
    43d6f1f01d4cc0fc6a41dd887195b47a7ee4916c3ba8bfd7119c708f908a9f71d7393b8b60b85d0ccac6fcc3e1aae8bfb6a33dca99b82f34e4621e9fcfa212ad  s3fs_1.88+git-v1.88-2_amd64.deb


### `s3fs` size and checksum

    $ stat --printf="%s bytes\n" s3fs
    739600 bytes

    $ md5sum s3fs
    590abee042233159e306cdfd2fd06024  s3fs
    
    $ sha256sum s3fs
    2c22289ed1346184db6f010751b715e3dfc4d29345567d93bd7b5ebb7b5a9e43  s3fs
    
    $ b2sum s3fs
    d049bef27d79ad500cd7217e8f4734bed3b51d9cafe0cee8931f41be2f76a697e92fc6dd1643f016dae6d43aa0ffc427477bf24bddc219faf8ee328349fe61e1  s3fs


Originally I wanted to publish these checksums from Docker Hub.  Indeed, they are pasted directly from the output of my `Dockerfile`.  Unfortunately, [Docker Hub does not publish logs from automated builds](https://github.com/docker/hub-feedback/issues/1787), so that's not possible at this time.  Please support [this issue](https://github.com/docker/hub-feedback/issues/1787) to improve the trustworthiness of automated Docker Hub builds.

# Notes

<a name="trustmedest">[[1]](#trustmesrc)</a> On principle, you should check my Dockerfile and make sure that I'm not doing anything suspicious.
