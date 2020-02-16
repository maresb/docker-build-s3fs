# docker-build-s3fs

#### Builds a .deb for Ubuntu 18.04 based on a specified commit from the s3fs-fuse GitHub repository.

Links:

- **[Download the resulting .deb file](https://raw.githubusercontent.com/maresb/docker-build-s3fs/deb-v1.86/s3fs_1.86+git_amd64.deb) (rendered from [v1.86](https://github.com/s3fs-fuse/s3fs-fuse/tree/v1.86) release)**

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

### 1. Compile under Docker.

Complete either a) or b) below.

**a) Either compile locally**
    
Download `Dockerfile` and change to the corresponding directory.

To render an untagged commit,
```
docker build -t build-s3fs --build-arg COMMIT_ID=e0712f4 --build-arg S3FS_VERSION=1.85 .
```

or for a tagged commit such as a release version,

```
docker build -t build-s3fs --build-arg COMMIT_ID=v1.86 --build-arg S3FS_VERSION=1.86 .
```
**b) Or grab a premade image from Docker Hub**

Pull the image from Docker Hub and retag:
```
docker pull maresb/docker-build-s3fs
docker image tag maresb/docker-build-s3fs build-s3fs
docker rmi maresb/docker-build-s3fs
```

### 2. Copy the package from the image via a temporary container.
```
debfile=$(docker run --rm build-s3fs sh -c "ls *.deb")
id=$(docker create build-s3fs)
docker cp $id:/home/deb/$debfile .
docker rm -v $id 
```

### 3. Clean up.
```
docker rmi build-s3fs
docker purge
```

### For debugging,
```
docker run --rm -it build-s3fs /bin/bash
```

# Checksums

`s3fs_1.86+git-v1.86-2_amd64.deb` CHECKSUM AND SIZE
------------------------------------------------------------

    $ md5sum s3fs_1.86+git-v1.86-2_amd64.deb
    7a3cf63bc18437926a1b686dfacf9c83  s3fs_1.86+git-v1.86-2_amd64.deb
    
    $ sha256sum s3fs_1.86+git-v1.86-2_amd64.deb
    3291d3ee880b29848516d93d76d080fed5e8c5f471d8527e181964577a50dd80  s3fs_1.86+git-v1.86-2_amd64.deb
    
    $ b2sum s3fs_1.86+git-v1.86-2_amd64.deb
    18f49400731e708ec8fff3170f0eeeef7bedc00995337f93f3575ba0773847d061215c47bf1d05fd6591928584172a8b49cee22a306b1ced7eff744c75a759ae  s3fs_1.86+git-v1.86-2_amd64.deb


# Notes

<a name="trustmedest">[[1]](#trustmesrc)</a> On principle, you should not trust me (unless you know me personally).  It is much better to check my Dockerfile and make sure that there is nothing nefarious.
