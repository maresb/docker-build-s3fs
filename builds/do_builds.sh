# Stop on errors
set -e
set -o pipefail

# Print commands as they are executed
set -x

DEBIAN_PACKAGE_REVISION=3

test -f revisions_to_build.txt

while read line; do
  read COMMIT_ID S3FS_VERSION BUILD_DATE BUILD_TIME <<<"${line}"
  PACKAGE_VERSION_STRING=${S3FS_VERSION}+git-${COMMIT_ID}-${DEBIAN_PACKAGE_REVISION}
  BUILD_TIMESTAMP="${BUILD_DATE} ${BUILD_TIME}"

  echo
  echo BUILDING: $PACKAGE_VERSION_STRING
  echo

  # Clear any cache
  docker rmi build-s3fs || true
  docker system prune --force

  LOGFILE=s3fs_${PACKAGE_VERSION_STRING}_amd64.log

  date > ${LOGFILE}

  docker build -t build-s3fs \
    --build-arg REBUILD_FROM_HERE=$(date +%s) \
    --build-arg COMMIT_ID=${COMMIT_ID} \
    --build-arg S3FS_VERSION=${S3FS_VERSION} \
    --build-arg SCRIPT_DEBIAN_PACKAGE_REVISION=${DEBIAN_PACKAGE_REVISION} \
    --build-arg SCRIPT_PACKAGE_VERSION_STRING=${PACKAGE_VERSION_STRING} \
    --build-arg BUILD_TIMESTAMP="${BUILD_TIMESTAMP}" \
    ../. \
  | tee --append ${LOGFILE} \
  ;

  id=$(docker create build-s3fs)
  docker cp $id:s3fs-debian-package.tar .
  tar xvf s3fs-debian-package.tar && rm s3fs-debian-package.tar
  docker rm -v $id

# Filter comments, trim whitespace, filter blank lines.
done < <(cat revisions_to_build.txt | sed -e '/^\s*#/d' | awk '{$1=$1};1' | sed '/^$/d')
