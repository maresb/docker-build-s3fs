#!/bin/bash
set -ex


# Detect the directory name of the package and change into it.

  PACKAGE_DIR=$(find . -maxdepth 1 -name "s3fs-fuse-*" -type d)
  cd $PACKAGE_DIR


# Patch the necessary files to use OpenSSL

  sed -i 's/libcurl4-gnutls-dev/libcurl4-openssl-dev/g' debian/control
  sed -i 's/--with-gnutls/--with-openssl/g' debian/rules


# If there is a specified timestamp, then set it.

  if [ "${BUILD_TIMESTAMP}" != "NONE" ]; then

  # Make sure the timestamp isn't in the future.  Otherwise 'make' will enter
  # an infinite loop.

    if [ $(date -u +%s) -lt $(date -u --date="${BUILD_TIMESTAMP}" +%s) ]; then
      echo "BUILD_TIMESTAMP cannot be in the future!"
      exit 1
    fi


  # Update the timestamp in the changelog

    sed -i "0,/>  / s/>  .*/>  $(date -u -R --date="${BUILD_TIMESTAMP}")/g" debian/changelog


  # Update the timestamps of all files

    find . -exec touch -m -d "${BUILD_TIMESTAMP}" {} +

  fi


# Build the binary package, without signing the .changes file or source package.

  debuild -b -uc -us

