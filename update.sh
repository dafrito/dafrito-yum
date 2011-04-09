#!/bin/bash
PATH=/bin:/usr/bin

REPODIR=$*
REPODIR=${REPODIR:-.}
if is_yum_repo $REPODIR; then
	echo "$REPODIR does not look like a yum repository" 1>&2
	confirm "Create anyway?" || die
fi

unsigned=

sync_package() {
	local name=$1
	local path=$SRCDIR/$name
	pushd $path || die "Failed to change directory to $path"
	make rpm || die "Build failed for $name"
	popd
	for rpm in `rpm --specfile $RPMDIR/SPECS/$name.spec -q`; do
		rpmfile="$RPMDIR/RPMS/`echo $rpm | sed -nre 's%^.*\.([^.]+)$%\1%p'`/$rpm.rpm"
		if [ ! -f $REPODIR/`basename $rpmfile` ]; then
			cp -v -p $rpmfile $REPODIR || die "Failed to copy package: $rpmfile"
			unsigned="$unsigned $rpm.rpm"
		fi
	done
}

for package in $(<$CONFIGDIR/packages); do
	echo $package
	sync_package $package
done

echo
if [ -n "$unsigned" ]; then
	cd $REPODIR
	echo "The following packages have been updated and require a signature:"
	for rpm in $unsigned; do
		basename $rpm .rpm
	done
	attempt 3 rpm --addsign $unsigned
	createrepo -C -v .
else
	echo "No packages were added"
fi
