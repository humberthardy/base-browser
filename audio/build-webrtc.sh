#!/bin/bash -

docker run --rm -v $(pwd):/code:rw maxmcd/gstreamer:1.14-buster bash -c "apt-get install -y libjson-glib-dev && cd /code && make"