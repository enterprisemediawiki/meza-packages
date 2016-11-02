#!/bin/sh
#
# Perform these steps after ImageMagick install

# Directory of this file
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# add symlink to php binary in location already in path
sudo ln -s /usr/local/php/bin/php /usr/bin/php

