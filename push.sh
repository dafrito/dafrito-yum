#!/bin/bash
PATH=/bin:/usr/bin
. $LIBDIR/functions.sh || exit 1

sync() {
	rsync -ihavz --delete $* $REPODIR/* $REMOTE/
}

REPODIR=$*
REPODIR=${REPODIR:-.}
[ -d "$REPODIR/repodata" ] || die "$REPODIR does not look like a yum repository"
createrepo -C -v $REPODIR/ # update the repository's metadata first
sync -n 
read -p "Is this acceptable? [y/n]: "
case $REPLY in
	[yY]*) sync ;;
	*) die "Exiting on user input" ;;
esac
