#!/usr/bin/env bash

IMAGETAG=skip
if [ "${TRAVIS_BRANCH}" == "develop" ]; then
    IMAGETAG=develop
elif [ "${TRAVIS_BRANCH}" == "master" ]; then
    VERSION=$( docker run -it openstudio-jupyter:latest jupyter notebook --version )
    OUT=$?

    # Extended version (independent of $OUT)
    VERSION_EXT=$( docker run -it openstudio-jupyter:latest Rscript version.R | grep -o '".*"' | tr -d '"' )

    if [ $OUT -eq 0 ]; then
        # strip off the \r that is in the result of the docker run command
        IMAGETAG=$( echo $VERSION | tr -d '\r' )$VERSION_EXT
        echo "Found Version: $IMAGETAG"
    else
        echo "ERROR Trying to find Version"
        IMAGETAG=skip
    fi
fi

if [ "${IMAGETAG}" != "skip" ] && [ "${TRAVIS_PULL_REQUEST}" == "false" ]; then
    echo "Tagging image as $IMAGETAG"

    docker login -u $DOCKER_USER -p $DOCKER_PASS
    docker build -f Dockerfile -t nrel/openstudio-jupyter:$IMAGETAG -t nrel/openstudio-jupyter:latest .
    docker push nrel/openstudio-jupyter:$IMAGETAG
    docker push nrel/openstudio-jupyter:latest
else
    echo "Not on a deployable branch, this is a pull request or has been explicity skipped"
fi
