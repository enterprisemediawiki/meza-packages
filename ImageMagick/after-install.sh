#!/bin/sh
#
# Perform these steps after ImageMagick install

# Directory of this file
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# According to http://www.imagemagick.org/script/install-source.php:
# "You may need to configure the dynamic linker run-time bindings"
echo "Configure dynamic linker"
ldconfig /usr/local/lib

# Add to policy.xml to prevent remote code execution. See
# policy-map.xml for more details
sed -i -e "/<policymap>/r $DIR/policy-map.xml" /usr/local/etc/ImageMagick-*/policy.xml


