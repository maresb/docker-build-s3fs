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

- v1.86
  - md5sums
      ```
      fd58e267ebf1356c51944e25077585a0  usr/bin/s3fs
      2b3c4daeb209a56f0eca76e446747dfd  usr/share/doc/s3fs/changelog.Debian.gz
      77f9561b63b1d6d232ecddbc2f3aeb28  usr/share/doc/s3fs/copyright
      7ba8239dcc20cbbbe29a0fcb80cc27ed  usr/share/doc/s3fs/examples/passwd-s3fs
      17656b1dfe362471065acff564abc0c0  usr/share/man/man1/s3fs.1.gz
      ```
  - /usr/bin/s3fs
      ```
      $ md5sum /usr/bin/s3fs
      fd58e267ebf1356c51944e25077585a0  /usr/bin/s3fs
      
      $ sha256sum /usr/bin/s3fs
      7fa01b0c85bbfb86d392fd979c527f7443eb31ad0c55a0ac6b00d059c456bc7b  /usr/bin/s3fs
      
      $ b2sum /usr/bin/s3fs
       39ca9f034e3c7dbd6a38e9b5a04a4ca7176a825305ac5cb55d2346005a8bc6eac2ab3676e04aaab580f95cc289a6b45728a9e0200dd4f0aefde6e8921d4575b8  /usr/bin/s3fs
      ```

# Notes

<a name="trustmedest">[[1]](#trustmesrc)</a> On principle, you should not trust me (unless you know me personally).  It is much better to check my Dockerfile and make sure that there is nothing nefarious.
