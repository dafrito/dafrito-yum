#!/bin/bash
PATH=/bin:/usr/bin

do_push() {
	rsync -ihavz --delete $* $REPODIR/ $REMOTE/
}

if [ -z "$REPODIR" ] || [ "$#" != 0 ]; then
	REPODIR=${1:-.}
fi

[ -d $REPODIR ] || die "$REPODIR is not a directory"
REPODIR=`abs_path "$REPODIR"`
is_yum_repo $REPODIR || die "$REPODIR does not look like a yum repository"
createrepo -C -v $REPODIR/ # update the repository's metadata first
do_push -n && confirm && do_push || die
