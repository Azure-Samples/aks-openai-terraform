#!/bin/bash

# For more information, see:
# * https://hub.docker.com/_/python 
# * https://docs.streamlit.io/knowledge-base/tutorials/deploy/docker
# * https://stackoverflow.com/questions/30494050/how-do-i-pass-environment-variables-to-docker-containers

# Variables
source ./00-variables.sh

# Build the docker image
docker build -t $imageName:$tag -f Dockerfile .