#!/bin/sh
#
# Build ImageMagick RPM

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


working_dir="/tmp/imagemagick-working"
rpm_destdir="/tmp/imagemagick-rpm"

mkdir -p "$working_dir"
cd "$working_dir"

# Get yums.sh from meza, use it to initialize server
curl -LO https://raw.githubusercontent.com/enterprisemediawiki/meza/master/scripts/yums.sh
bash yums.sh

# Make sure these other dependencies are in place
yum install ruby-devel gcc make rpm-build
gem install fpm

# Get ImageMagick
echo "Downloading ImageMagick"
cd "$working_dir"
wget http://www.imagemagick.org/download/ImageMagick.tar.gz
tar xvzf ImageMagick.tar.gz
imagick_version=$( ls ./ | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+')

# Different versions may be downloaded, * to catch whatever version
cd ImageMagick-*

# cmd_profile "START build ImageMagick"
echo "Configure ImageMagick"

./configure --prefix=/usr/local

echo "Make ImageMagick"
make
echo "Make install ImageMagick"
mkdir "$rpm_destdir"
make install DESTDIR="$rpm_destdir"
# cmd_profile "END build ImageMagick"

# create RPM
cd /tmp
fpm -s dir -t rpm -n imagemagick -v "$imagick_version" -C "$rpm_destdir" \
	-p imagemagick_VERSION_ARCH.rpm \
	--after-install "$DIR/after-install.sh"
	usr/local/bin usr/local/etc usr/local/include usr/local/lib usr/local/share

# if an old RPM is in repository /RPMs directory, remove it
if [ -f "$DIR/../RPMs/imagemagick_*" ]; then
	rm -rf "$DIR/../RPMs/imagemagick_*"
fi

# move file to repository /RPMs directory
mv "/tmp/imagemagick_$imagick_version*" "$DIR/../RPMs/"

# remove stuff in /tmp (I don't think we want to do this since most of the
# time this script will be run on a dummy VM and keeping the files won't hurt
# and may help.)
# rm -rf "$working_dir"
# rm -rf "$rpm_destdir"
