#!/bin/bash
PLATFORMS="aws azure"

for platform in $PLATFORMS ; do 
  echo "Rendering files for $platform"
  ./render.sh $platform
done

echo "Syncing files to S3"
./sync.sh

