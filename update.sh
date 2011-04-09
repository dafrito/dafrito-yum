#!/bin/bash
PATH=/bin:/usr/bin

REPODIR=$*
REPODIR=${REPODIR:-.}
if ! is_yum_repo $REPODIR; then
	echo "$REPODIR does not look like a yum repository" 1>&2
	confirm "Create anyway?" || die
fi

unsigned=

sync_package() {
	local name=$1
	pushd $name || die "Failed to change directory to $name"
	make rpm || die "Build failed for $name"
	popd
	for rpm in `rpm --specfile $RPMDIR/SPECS/$name.spec -q`; do
		local arch=`echo $rpm | grep -E -o '[^.]+$'`
		local rpmfile="$RPMDIR/RPMS/$arch/$rpm.rpm"
		if [ ! -f $REPODIR/`basename $rpmfile` ]; then
			cp -v -p $rpmfile $REPODIR || die "Failed to copy package: $rpmfile"
			unsigned="$unsigned $rpm.rpm"
		fi
	done
}

if [ -d "$CONFIGDIR/packages" ]; then
	pushd $CONFIGDIR/packages
	for package in *; do
		echo $package
		sync_package $package
	done
	popd
fi

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
