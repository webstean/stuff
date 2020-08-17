set DOCKER_BUILDKIT=true
docker build -t baresip .
docker run -it baresip
