#!/bin/bash
PATH=/bin:/usr/bin

# Path to the dafrito-yum executable
export FRITOBIN=$0

# Path to the directory containing RPM-making projects
export PROJECTDIR=$HOME/projects

# Path to the RPM building root (SOURCES, SPECS, etc.)
export RPMDIR=$HOME/rpmbuild

# Temporary directory path, will be destroyed on exit.
export TMPDIR=/tmp/dafrito/dafrito-yum.$$

# Location of the remote repository, as accessed by SSH
export REMOTE="dafrito@linode:/srv/dafrito/rpm"

# Path to individual command scripts
export LIBDIR=`dirname $FRITOBIN`

# Path to configuration files
export CONFIGDIR=`dirname $FRITOBIN`

. $LIBDIR/functions.sh

#git diff --exit-code || die "Refusing to build from dirty repo"


mkdir $TMPDIR || die "Could not create temporary directory"
trap 'rm -rf $TMPDIR' INT EXIT

export CMD=$1
shift

command() {
	local cmd=$1
	shift
	bash $LIBDIR/$cmd.sh $*
}

case "$CMD" in 
	pull|clone|get) command pull $* ;;
	push|sync) command push $* ;;
	up*|build|make) command update $* ;;
	*) die "Usage: `basename $FRITOBIN` {push|pull|build}"
esac
