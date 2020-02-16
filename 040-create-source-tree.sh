#!/bin/bash
set -ex

# In principle we should run 'apt-get update' here again, but we are
# no longer root.  The original source repository virtually never
# changes.  Indeed, that's the problem...

  apt-get source s3fs

