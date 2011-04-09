#!/bin/bash
PATH=/bin:/usr/bin

do_pull() {
	rsync -ihavz $* "$REMOTE/*" $REPODIR/
}

REPODIR=${1:-.}
if [ -d "$REPODIR" ]; then
	REPODIR=`abs_path "$REPODIR"`
	is_yum_repo $REPODIR || die "$REPODIR does not look like a yum repository"
else
	mkdir -v $REPODIR || die
	REPODIR=`abs_path "$REPODIR"`
fi
do_pull -n && confirm && do_pull || die "Failed to pull"
