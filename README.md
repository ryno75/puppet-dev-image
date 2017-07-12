# Puppet Development Docker Image
This repo stores a Dockerfile and accompanying config files for building a nice Puppet Development environment Docker image.

## Instructions
* Edit the Dockerfile as needed/desired
* Run `docker build` to create the image providing any desired override arguments
```
$ docker build username="Your Name Here" --build-arg email_address=EMAIL_ADDR -t IMAGE_NAME .
```
* Create and start a container from the new image you just created
```
$ docker run -ti IMAGE_NAME
```
* Get busy
