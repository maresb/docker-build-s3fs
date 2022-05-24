# docker-build-s3fs

#### Builds a .deb for Ubuntu 18.04/20.04 based on a specified commit from the s3fs-fuse GitHub repository.

This Dockerfile repackages the Ubuntu 20.04 focal `.deb` file (currently [`s3fs_1.86-1_amd64.deb`](https://packages.ubuntu.com/focal/amd64/s3fs/download)) with updated source code from the [s3fs-fuse GitHub repository](https://github.com/s3fs-fuse/s3fs-fuse).  This is all done at Docker build time.

## Download

### [Download the resulting .deb file](https://media.githubusercontent.com/media/maresb/docker-build-s3fs/master/builds/s3fs_1.91+git-v1.91-3_amd64.deb) (rendered from [v1.91](https://github.com/s3fs-fuse/s3fs-fuse/tree/v1.91) release) and verify [your preferred checksum](#checksums).

## Links

- GitHub: https://github.com/maresb/docker-build-s3fs

- s3fs-fuse: https://github.com/s3fs-fuse/s3fs-fuse


## Motivation

Ubuntu 18.04's outdated version of [s3fs-fuse](https://github.com/s3fs-fuse/s3fs-fuse) (resulting from `apt-get install s3fs`) did not seem to work for me on AWS. Thus I started this project with a Dockerfile which compiles s3fs from a specified GitHub commit.

I need to deploy this to several instances, so I much prefer the speed and
convenience of installing from a `.deb` file as opposed to compiling from source.
For security reasons, I avoid downloading software compiled by random people.
If you trust me<sup><a name="trustmesrc">[1](#trustmedest)</a></sup>, you can download the `.deb` from the above link.  Otherwise, follow the instructions below to build it yourself.

I no longer use this project myself. Nowadays my preferred installation method is to use conda-forge, which provides open-source infrastructure for package management. In particular, I use [`mamba`](https://github.com/mamba-org/mamba) to install the [`s3fs-fuse`](https://github.com/conda-forge/s3fs-fuse-feedstock) package with the command

```bash
mamba install -c conda-forge s3fs-fuse
```

## Installation

Once you have the `.deb` file, run

```bash
sudo apt-get install -y fuse mime-support libxml2 libcurl4 libssl1.1
sudo dpkg -i s3fs_….deb
```

## Build s3fs from Docker

If you wish to validate my `.deb` file or to generate it yourself, then follow these steps.

### 1. Compile under Docker.

Download `Dockerfile` and change to the corresponding directory.

```bash
git clone https://github.com/maresb/docker-build-s3fs.git && cd docker-build-s3fs
```

To render an untagged commit such as [e0712f4](https://github.com/s3fs-fuse/s3fs-fuse/tree/e0712f4),
```bash
docker build -t build-s3fs --build-arg COMMIT_ID=e0712f4 --build-arg S3FS_VERSION=1.85 .
```

or for a tagged commit such as a release version, for example [v1.91](https://github.com/s3fs-fuse/s3fs-fuse/tree/v1.91),

```bash
docker build -t build-s3fs --build-arg COMMIT_ID=v1.91 --build-arg S3FS_VERSION=1.91 .
```

The argument `S3FS_VERSION` should refer to the latest version number as of the commit specified under `COMMIT_ID`.

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
verified from the download, and/or a build on your own computer.

NOTE: After some time, discrepancies in the checksums could arise due to updated
dependencies. To compare, I provide logs under [`builds/`](builds).

### md5sums FILE CONTENTS

0f511a762f22c0c00d75e40515dca142  usr/bin/s3fs
e225a2dfdaadb1c4c484614df28cdfdf  usr/share/doc/s3fs/changelog.Debian.gz
2c85defc6568bd463d3dc9c5342faab0  usr/share/doc/s3fs/copyright
7ba8239dcc20cbbbe29a0fcb80cc27ed  usr/share/doc/s3fs/examples/passwd-s3fs
0b395c729d822fdfd60bcf0d13169c49  usr/share/man/man1/s3fs.1.gz


### `s3fs_1.91+git-v1.91-3_amd64.deb` size and checksum

    $ stat --printf="%s bytes\n" s3fs_1.91+git-v1.91-3_amd64.deb
    222340 bytes

    $ md5sum s3fs_1.91+git-v1.91-3_amd64.deb
    95192b8c47c931623eb1ce49282338eb  s3fs_1.91+git-v1.91-3_amd64.deb
    
    $ sha256sum s3fs_1.91+git-v1.91-3_amd64.deb
    9eca7cb1e9bb08b8e3ae9b476287712a8293493630c76d9102c5ac0058b098c0  s3fs_1.91+git-v1.91-3_amd64.deb
    
    $ b2sum s3fs_1.91+git-v1.91-3_amd64.deb
    46befabcd4ffce0000db99d71b1d51d6cef2bab8816fc540bc2e7aaaed921ad545f61d661190b96d219648f69688a7ea65ce6142a6524ec3af5a6f7f9f2ea97f  s3fs_1.91+git-v1.91-3_amd64.deb


### `s3fs` size and checksum

    $ stat --printf="%s bytes\n" s3fs
    604608 bytes

    $ md5sum s3fs
    0f511a762f22c0c00d75e40515dca142  s3fs
    
    $ sha256sum s3fs
    9f205d172c8e23dcf1fa1f31d999ad469116d032ef5238e29a0d290edd91ec07  s3fs
    
    $ b2sum s3fs
    c9df12b25a3d577f958b5bb1fd15c406c42344b22fd1e172fb2f1672eca1c0b10b0a3487099f9951ebfaf55a3c81e64ce8a9d2cad1275612d15c5ac1713bae92  s3fs



Originally these files were reproducible by Docker Hub. Unfortunately [Docker Hub Autobuilds have been deactivated](https://www.docker.com/blog/changes-to-docker-hub-autobuilds/), so I can no longer offer this service. I would be interested in autogenerating the checksums/binary through another CI service if someone else puts together a pull request.

# Notes

<a name="trustmedest">[[1]](#trustmesrc)</a> On principle, you should check my Dockerfile and make sure that I'm not doing anything suspicious.
