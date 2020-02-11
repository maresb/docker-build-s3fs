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
docker build -t build-s3fs --build-arg COMMIT_ID=e0712f4 --build-arg PACKAGE_VERSION_STRING=1.85+git-e0712f4 .
```

or for a tagged commit such as a release version,

```
docker build -t build-s3fs --build-arg COMMIT_ID=v1.86 --build-arg PACKAGE_VERSION_STRING=1.86+git .
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
docker cp $id:$debfile .
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
      0ff7ecdeae0befad2bc8ebad843807cd  usr/bin/s3fs
      [varies depending on build time]  usr/share/doc/s3fs/changelog.gz
      77f9561b63b1d6d232ecddbc2f3aeb28  usr/share/doc/s3fs/copyright
      7ba8239dcc20cbbbe29a0fcb80cc27ed  usr/share/doc/s3fs/examples/passwd-s3fs
      17656b1dfe362471065acff564abc0c0  usr/share/man/man1/s3fs.1.gz
      ```
  - /usr/bin/s3fs
      ```
      $ md5sum /usr/bin/s3fs
      0ff7ecdeae0befad2bc8ebad843807cd  /usr/bin/s3fs
      
      $ sha256sum /usr/bin/s3fs
      7efadd2b670bc984a973935a1823d8f23f9bf99e48713db260383d3b5b286ba9  /usr/bin/s3fs
      
      $ b2sum /usr/bin/s3fs
       6f68a6697f94a5adaf28e82ddbb0039443d2f91490020c04954e15feaf8a704a824f1701e6581e2bf232a51384db57d7a4b7717744506bc45f4e9beaf07f5ad5  /usr/bin/s3fs
      ```

# Notes

<a name="trustmedest">[[1]](#trustmesrc)</a> On principle, you should not trust me (unless you know me personally).  You should glance at my Dockerfile and make sure nothing nefarious is going on.  For convenience, I originally wanted to provide a certifiable `.deb` built automatically on Docker Hub. The `Dockerfile` prints the checksum<sup><a name="checksumsrc">[2](#checksumdest)</a></sup> of the `.deb`.  However, [Docker Hub does not publish logs from automated builds](https://github.com/docker/hub-feedback/issues/1787), so unfortunately only I can verify the checksum at this time.  Please support [this issue](https://github.com/docker/hub-feedback/issues/1787) to improve the trustworthiness of automated Docker Hub builds.

<a name="checksumdest">[[2]](#checksumsrc)</a> There is not even a unique checksum of the resulting `.deb` for a given commit, since the archived files have a last-modified time according to the build time, and since the changelog contains a timestamp of the build time.
