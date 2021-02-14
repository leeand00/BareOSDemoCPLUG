#!/bin/bash 

# 
# define parameter 
# 
 
DIST=Debian_10 
# or 
# DIST=Debian_7.0 
# DIST=xUbuntu_16.04 
# DIST=xUbuntu_14.04 
# DIST=xUbuntu_12.04 
 
DATABASE=postgresql 
# or 
#DATABASE=mysql 
 
URL=http://download.bareos.org/bareos/release/20/$DIST/ 
 
# add the Bareos repository 
printf "deb $URL /\n" > /etc/apt/sources.list.d/bareos.list 
 
# add package key 
wget -q $URL/Release.key -O- | apt-key add - 
 
# install Bareos packages 
apt-get update 
apt-get install bareos bareos-database-$DATABASE
