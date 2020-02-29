# Reference: https://github.com/s3fs-fuse/s3fs-fuse/wiki/Installation-Notes

# SET COMMIT ID BELOW!!!

FROM ubuntu:18.04 AS build

LABEL maintainer="Ben Mares <services-docker-build-s3fs@tensorial.com>" \
      name="docker-build-s3fs" \
      url="https://github.com/maresb/docker-build-s3fs" \
      vcs-url="https://github.com/maresb/docker-build-s3fs"

ARG SCRIPT_SOURCE_DIR=dockerfile_scripts
ARG SCRIPT_DEST_DIR=/usr/local/bin

# Install general build tools

  COPY ${SCRIPT_SOURCE_DIR}/010-install-build-tools.sh ${SCRIPT_DEST_DIR}
  RUN 010-install-build-tools.sh


# Enable source repositories, download package-specific build dependencies.

  COPY ${SCRIPT_SOURCE_DIR}/020-install-build-dependencies.sh ${SCRIPT_DEST_DIR}
  RUN 020-install-build-dependencies.sh


# Download additional dependencies recommended in Wiki installation notes.
# (This is for OpenSSL support.)

  COPY ${SCRIPT_SOURCE_DIR}/030-install-recommended-dependencies.sh ${SCRIPT_DEST_DIR}
  RUN 030-install-recommended-dependencies.sh


# Make user named 'deb'

  RUN useradd -m deb
  USER deb
  WORKDIR /home/deb

# Create source tree.

  COPY ${SCRIPT_SOURCE_DIR}/040-create-source-tree.sh ${SCRIPT_DEST_DIR}
  RUN 040-create-source-tree.sh


# Add a mechanism to have Docker abandon the cache at this point, by
# calling docker with the extra arguments
#   --build-arg REBUILD_FROM_HERE=$(date +%s)

  ARG REBUILD_FROM_HERE=NO


# SET COMMIT ID HERE!!!
# (Also, update S3FS_VERSION accordingly)
###################################
###################################

# The id (either hash or alias) of the default commit to build:

  ARG COMMIT_ID=v1.86

#   Another example:
#     ARG COMMIT_ID=e0712f4

# The latest release of s3fs from the time of the above commit

  ARG S3FS_VERSION=1.86

###################################
###################################


# For reproducibility, allow a timestamp of the format "YYYY-MM-DD HH:MM:SS" in UTC
# i.e. the output of:
#   date -u +"%Y-%m-%d %H:%M:%S"

  ARG BUILD_TIMESTAMP="2020-02-16 18:00:00"


# To be increased when there is a change to this Dockerfile which affects the contents
# of the resulting .deb file.  KEEP THIS SYNCHRONIZED WITH ALL BUILD SCRIPTS!!!

  ARG DEBIAN_PACKAGE_REVISION=2


# Build up the version string for the package

  ARG PACKAGE_VERSION_STRING=${S3FS_VERSION}+git-${COMMIT_ID}-${DEBIAN_PACKAGE_REVISION}

# These are variables which should be duplicated in build scripts and passed as arguments. 
# Do the corresponding consistency checks in the next script.

  ARG SCRIPT_DEBIAN_PACKAGE_REVISION=${DEBIAN_PACKAGE_REVISION}
  ARG SCRIPT_PACKAGE_VERSION_STRING=${PACKAGE_VERSION_STRING}


# Verify consistency of any given build script parameters.
# Download the latest GitHub release, overwriting the original source archive. 
# Then re-extract the original source tree, and update the version.

  COPY ${SCRIPT_SOURCE_DIR}/050-update-source-from-git.sh ${SCRIPT_DEST_DIR}
  RUN 050-update-source-from-git.sh


# Build

  COPY ${SCRIPT_SOURCE_DIR}/060-build-package.sh ${SCRIPT_DEST_DIR}
  RUN 060-build-package.sh


# Report info

  COPY ${SCRIPT_SOURCE_DIR}/070-print-checksums.sh ${SCRIPT_DEST_DIR}
  RUN 070-print-checksums.sh


# Tar the .deb and copy it into an empty image

  RUN tar -cvf s3fs-debian-package.tar *.deb
  FROM scratch AS deb-only
  COPY --from=build /home/deb/s3fs-debian-package.tar ./
  # Prevents the error "Error response from daemon: No command specified":
  CMD nothing
