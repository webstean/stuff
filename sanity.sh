#!/bin/sh

# Check to make sure git is configured with your name, email and custom settings.
git config --list

# Sanity check to see if you can run some of the tools we installed.
ruby --version
node --version
ansible --version
aws --version
terraform --version

# If you're using Docker Desktop with WSL 2, these should be accessible too.
docker info
docker-compose --version
