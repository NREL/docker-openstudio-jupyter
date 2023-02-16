#!/usr/bin/env bash

IMAGETAG="skip"
if [ "${GITHUB_REF}" == "refs/heads/develop" ]; then
    IMAGETAG="develop"
elif [ "${GITHUB_REF}" == "refs/heads/master" ]; then
    VERSION=$( docker run os-jupyter sh -c 'echo $VERSION' )
    OUT=$?

    if [ $OUT -eq 0 ]; then
        # strip off the \r that is in the result of the docker run command
        IMAGETAG=$( echo $VERSION | tr -d '\r' )
        echo "Found Version: $IMAGETAG"
    else
        echo "ERROR Trying to find Version"
        IMAGETAG="skip"
    fi
fi

if [ "${IMAGETAG}" != "skip" ]; then
    echo "Tagging image as $IMAGETAG"

    docker login -u $DOCKER_USER -p $DOCKER_PASS
    docker build --build-arg GITHUB_PAT=$GITHUB_PAT -f Dockerfile -t nrel/openstudio-jupyter:$IMAGETAG -t nrel/openstudio-jupyter:latest .
    docker push nrel/openstudio-jupyter:$IMAGETAG
    docker push nrel/openstudio-jupyter:latest
else
    echo "Not on a deployable branch, this is a pull request or has been explicity skipped"
fi
