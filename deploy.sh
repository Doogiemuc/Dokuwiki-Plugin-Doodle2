#!/bin/sh

#
# General deploy script for Doogies coding projects
# Usage:   deploy <environment>
#   where    environment can be 'test' or 'prod'
#
# This script creates a tarball with the release number from VERSION
# tars & zips it and uploads this to a given FTP server
#

#
# ======= SETTINGS ========
#

# default name of project is name of current directory
CURRENT_DIR=`pwd`
PROJECT=`basename $CURRENT_DIR`
DIST_DIR='dist'

# FTP server
FTP_HOST='ftp.doogie.de'
FTP_DIR='public/projects/dokuwiki'
FTP_USER='45481-doogie'

# version file with release number in it
VERSION_FILE='VERSION'
RELEASE_NO=`egrep '[0-9]+\.[0-9]+' ./$VERSION_FILE`

TARFILE="$DIST_DIR/$PROJECT-$RELEASE_NO.tar.gz"

#
# ===== END OF SETTINGS ====
#


# Usage
if [ "$1" = "-?" ]; then
  echo "USAGE:   deploy <environment>"
  echo "   where <environment> can be 'test' or 'prod'"
  exit 0
fi

# Sanity checks
if [ -z "$1" ]; then
  echo "$0 ERROR: you must provide an environemnt (test|prod)"
  exit 1
fi

# check version
if [ -z $RELEASE_NO ]; then
  echo "$0 ERROR: no release number in $VERSION_FILE"
  exit 1
fi

# start deployment 
echo "Deploying Project $PROJECT-$RELEASE_NO to $TARFILE"

# Ask if file exists alreadyThis overwrite warning is implicit inside the tar command
if [ -w $TARFILE ] ; then
  echo -n "WARNING: $TARFILE already exists. Overwrite (Y/N)? "
  read OVERWRITE
  if [ $OVERWRITE != "Y" ] ; then
    exit 0
  fi
fi


# create .tar.gz (will ask for overwrite if file exists)
tar --exclude '.svn' --exclude "$0" --exclude 'dist' -C ../ -czf $TARFILE $PROJECT

# upload via FTP if env=prod (will ask for password)
if [ "$1" = "prod" ]; then
  echo "uploading to ftp://$FTP_USER@$FTP_HOST/$FTP_DIR/$PROJECT-latest.tar.gz"
  ftp -u ftp://$FTP_USER@$FTP_HOST/$FTP_DIR/$PROJECT-latest.tar.gz $TARFILE
fi

echo


