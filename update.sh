#!/bin/bash
PATH=/bin:/usr/bin

if [ -z "$REPODIR" ] || [ "$#" != 0 ]; then
	REPODIR=${1:-.}
fi

if [ -d "$REPODIR" ]; then
	REPODIR=`abs_path "$REPODIR"`
	if ! is_yum_repo $REPODIR; then
		echo "$REPODIR does not look like a yum repository" 1>&2
		confirm "Create anyway?" || die
	fi
else
	confirm "$REPODIR does not exist. Create?" && mkdir -p $REPODIR || die
	REPODIR=`abs_path "$REPODIR"`
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
			trap 'cd $REPODIR && rm -v $unsigned' EXIT
			cp -v -p $rpmfile $REPODIR || die "Failed to copy package: $rpmfile"
			unsigned="$unsigned $rpm.rpm"
		fi
	done
}

pushd $PACKAGEDIR
for package in `ls`; do
	if [ -d $package ]; then
		echo $package
		sync_package $package
	fi
done
popd

echo
if [ -n "$unsigned" ]; then
	cd $REPODIR
	echo "The following packages have been updated and require a signature:"
	for rpm in $unsigned; do
		basename $rpm .rpm
	done
	attempt 3 rpm --addsign $unsigned || die "Failed after 3 tries"
	createrepo -C -v .
	trap - EXIT
else
	echo "No packages were added"
fi
