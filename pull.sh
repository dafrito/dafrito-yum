#!/bin/bash
PATH=/bin:/usr/bin

do_pull() {
	rsync -ihavz $* "$REMOTE/*" $REPODIR/
}

REPODIR=$*
REPODIR=${REPODIR:-.}
if [ -d "$REPODIR" ]; then
	is_yum_repo $REPODIR || die "$REPODIR does not look like a yum repository"
	do_pull -n && confirm && do_pull || die "Failed to pull"
else
	mkdir -v $REPODIR && do_pull || die "Repository could not be created"
fi
