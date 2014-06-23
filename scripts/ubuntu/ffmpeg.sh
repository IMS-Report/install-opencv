#!/bin/sh
#
# Created on June, 23 2014
#
# @author: sgoldsmith
# @author: swilla
#
# Install and configure OpenCV for Ubuntu 12.04.3 and 14.04.0 (Desktop/Server 
# x86/x86_64 bit/armv7l). Please note that since some of the operations change
# configurations, etc. I cannot guarantee it will work on future or previous
# versions. All testing was performed on Ubuntu 12.04.3 and 14.04.0 LTS x86_64,
# x86 and armv7l with the latest updates applied.
#
# WARNING: This script has the ability to install/remove Ubuntu packages and it also
# installs some libraries from source. This could potentially screw up your system,
# so use with caution! I suggest using a VM for testing before using it on your
# physical systems.
#
# Steven P. Goldsmith
# sgjava@gmail.com
# 
# Prerequisites:
#
# o Install Ubuntu 12.04.3 or 14.04.0, update (I used VirtualBox for testing) and
#   make sure to select OpenSSH Server during install. Internet connection is
#   required to download libraries, frameworks, etc.
#    o sudo apt-get update
#    o sudo apt-get upgrade
#    o sudo apt-get dist-upgrade
# o Set variables in config.sh before running.
# o sudo ./install.sh
#

# Get start time
dateformat="+%a %b %-eth %Y %I:%M:%S %p %Z"
starttime=$(date "$dateformat")
starttimesec=$(date +%s)

# Get user who ran sudo
if logname &> /dev/null; then
	curuser=$(logname)
else
	if [ -n "$SUDO_USER" ]; then
		curuser=$SUDO_USER
	else
		curuser=$(whoami)
	fi
fi

# Get current directory
curdir=$(cd `dirname $0` && pwd)

# stdout and stderr for commands logged
logfile="$curdir/ffmpeg.log"

# Source config file
. "$curdir"/config.sh

# Hostname and domain
hostname=$(hostname -s)
domain=$(hostname -d)
fqdn=$(hostname -f)
# dc1 and dc2
dc1=$(echo $domain | awk '{split($0,a,".");print a[1]}')
dc2=$(echo $domain | awk '{split($0,a,".");print a[2]}')

# Ubuntu version
ubuntuver=$DISTRIB_RELEASE

# Use shared lib?
if [ "$arch" = "i686" -o "$arch" = "i386" -o "$arch" = "i486" -o "$arch" = "i586" ]; then
	shared=0
else
	shared=1
fi




# Install ffmpeg
echo "\nInstalling ffmpeg...\n"
echo "Installing ffmpeg...\n" >> $logfile 2>&1
cd "$tmpdir"
git clone "$ffmpegurl"
cd ffmpeg
# ARM build without libvpx
if [ "$arch" = "armv7l" ]; then
	./configure --enable-gpl --enable-libass --enable-libfaac --enable-libfdk-aac --enable-libmp3lame --enable-libopencore-amrnb --enable-libopencore-amrwb --enable-librtmp --enable-libtheora --enable-libvorbis --enable-x11grab --enable-libx264 --enable-nonfree --enable-version3 --enable-shared >> $logfile 2>&1
else
	if [ $shared -eq 0 ]; then
		./configure --enable-gpl --enable-libass --enable-libfaac --enable-libfdk-aac --enable-libmp3lame --enable-libopencore-amrnb --enable-libopencore-amrwb --enable-librtmp --enable-libtheora --enable-libvorbis --enable-libvpx --enable-x11grab --enable-libx264 --enable-nonfree --enable-version3 >> $logfile 2>&1
	else
		./configure --enable-gpl --enable-libass --enable-libfaac --enable-libfdk-aac --enable-libmp3lame --enable-libopencore-amrnb --enable-libopencore-amrwb --enable-librtmp --enable-libtheora --enable-libvorbis --enable-libvpx --enable-x11grab --enable-libx264 --enable-nonfree --enable-version3 --enable-shared >> $logfile 2>&1
	fi
fi
make >> $logfile 2>&1
checkinstall --pkgname=ffmpeg --pkgversion="7:$(date +%Y%m%d%H%M)-git" --backup=no --deldoc=yes --fstrans=no --default >> $logfile 2>&1
hash -r >> $logfile 2>&1

