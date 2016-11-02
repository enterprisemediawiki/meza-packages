#!/bin/bash
#
# Build PHP RPM

if [ "$(whoami)" != "root" ]; then
    echo "Try running this script with sudo: \"sudo bash install.sh\""
    exit 1
fi

echo "Starting script rpm-imagemagick.sh"

# If /usr/local/bin is not in PATH then add it
# Ref enterprisemediawiki/meza#68 "Run install.sh with non-root user"
if [[ $PATH != *"/usr/local/bin"* ]]; then
    PATH="/usr/local/bin:$PATH"
fi

# Directory of this file
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )


# Get yums.sh from meza, use it to initialize server
curl -LO https://raw.githubusercontent.com/enterprisemediawiki/meza/master/scripts/yums.sh
bash yums.sh

# Make sure these other dependencies are in place
yum install -y ruby-devel gcc make rpm-build
gem install fpm



working_dir="/tmp/php-working"
rpm_destdir="/tmp/php-rpm"

mkdir -p "$working_dir"
cd "$working_dir"


phpversion="5.6.14" # this should roll to 5.6.27


#
# Download (for example) PHP 5.6.10, 5.5.26, or 5.4.42 source
#
cd "$working_dir"
tarfile="php-$phpversion.tar.bz2"
wget "http://php.net/get/php-$phpversion.tar.bz2/from/this/mirror" -O "$tarfile"


#
# Check if PHP successfully downloaded, exit if not
#
if [ -f $tarfile ];
then
   echo "PHP v$phpversion downloaded. Unpacking."
else
   echo "PHP v$phpversion not downloaded. Exiting."
   exit 1
fi


#
# Unpack tar.bz2
#
tar jxf "php-$phpversion.tar.bz2"
cd "php-$phpversion"


#
# Configure, make, make install
#
./configure \
    --with-apxs2=/usr/bin/apxs \
    --enable-bcmath \
    --with-bz2 \
    --enable-calendar \
    --with-curl \
    --enable-exif \
    --enable-ftp \
    --with-gd \
    --with-jpeg-dir \
    --with-png-dir \
    --with-freetype-dir \
    --enable-gd-native-ttf \
    --with-kerberos \
    --enable-mbstring \
    --with-mcrypt \
    --with-mhash \
    --with-mysql \
    --with-mysqli \
    --with-openssl \
    --with-pcre-regex \
    --with-pdo-mysql \
    --with-zlib-dir \
    --with-regex \
    --enable-sysvsem \
    --enable-sysvshm \
    --enable-sysvmsg \
    --enable-soap \
    --enable-sockets \
    --with-xmlrpc \
    --enable-zip \
    --with-zlib \
    --enable-inline-optimization \
    --enable-mbregex \
    --enable-opcache \
    --enable-intl \
    --prefix=/usr/local/php

mkdir "$rpm_destdir"
make install DESTDIR="$rpm_destdir"

# create RPM
cd /tmp
fpm -s dir -t rpm -n php -v "$phpversion" -C "$rpm_destdir" \
    -p php_VERSION_ARCH.rpm \
    --after-install "$DIR/after-install.sh" \
    usr/local/php

# if an old RPM is in repository /RPMs directory, remove it
if [ -f "$DIR/../RPMs/php_"* ]; then
    rm -rf "$DIR/../RPMs/php_"*
fi

# move file to repository /RPMs directory
mv "/tmp/php_$phpversion"* "$DIR/../RPMs/"

# remove stuff in /tmp (I don't think we want to do this since most of the
# time this script will be run on a dummy VM and keeping the files won't hurt
# and may help.)
# rm -rf "$working_dir"
# rm -rf "$rpm_destdir"

