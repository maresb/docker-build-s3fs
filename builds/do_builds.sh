# Stop on errors
set -e
set -o pipefail

DEBIAN_PACKAGE_REVISION=2

test -f revisions_to_build.txt

while read line; do
  read COMMIT_ID S3FS_VERSION <<<"${line}"
  PACKAGE_VERSION_STRING=${S3FS_VERSION}+git-${COMMIT_ID}-${DEBIAN_PACKAGE_REVISION}

  echo
  echo BUILDING: $PACKAGE_VERSION_STRING
  echo

  docker build -t build-s3fs \
    --build-arg REBUILD_FROM_HERE=$(date +%s) \
    --build-arg COMMIT_ID=${COMMIT_ID} \
    --build-arg S3FS_VERSION=${S3FS_VERSION} \
    --build-arg SCRIPT_DEBIAN_PACKAGE_REVISION=${DEBIAN_PACKAGE_REVISION} \
    --build-arg SCRIPT_PACKAGE_VERSION_STRING=${PACKAGE_VERSION_STRING} \
    ../. \
  | tee s3fs_${PACKAGE_VERSION_STRING}_amd64.log \
  ;

  debfile=$(docker run --rm build-s3fs sh -c "ls *.deb")
  id=$(docker create build-s3fs)
  docker cp $id:/home/deb/$debfile .
  docker rm -v $id

# Filter comments, trim whitespace, filter blank lines.
done < <(cat revisions_to_build.txt | sed -e '/^\s*#/d' | awk '{$1=$1};1' | sed '/^$/d')
