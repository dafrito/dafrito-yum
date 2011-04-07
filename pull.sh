#!/bin/bash
PATH=/bin:/usr/bin
. $LIBDIR/functions.sh

sync() {
	rsync -ihavz $* $REMOTE/* $REPODIR/
}

REPODIR=$*
REPODIR=${REPODIR:-.}
if [ -d "$REPODIR" ]; then
	[ -d "$REPODIR/repodata" ] || die "$REPODIR does not look like a yum repository"
	sync -n
	read -p "Is this acceptable? [y/n]: "
	case $REPLY in
		[yY]*) sync ;;
		*) die "Exited on user input"
	esac
else
	mkdir -v $REPODIR || die "Target directory could not be accessed"
	sync
fi
