#!/bin/bash

# For more information, see:
# * https://hub.docker.com/_/python 
# * https://docs.streamlit.io/knowledge-base/tutorials/deploy/docker
# * https://stackoverflow.com/questions/30494050/how-do-i-pass-environment-variables-to-docker-containers

# Variables
source ./00-variables.sh

# Run the docker container
docker run -it \
  --rm \
  -p 8501:8501 \
  -e TEMPERATURE=$temperature \
  -e AZURE_OPENAI_BASE=$AZURE_OPENAI_BASE \
  -e AZURE_OPENAI_KEY=$AZURE_OPENAI_KEY \
  -e AZURE_OPENAI_MODEL=$AZURE_OPENAI_MODEL \
  -e AZURE_OPENAI_DEPLOYMENT=$AZURE_OPENAI_DEPLOYMENT \
  --name $containerName \
  $imageName:$tag