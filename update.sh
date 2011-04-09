#!/bin/bash
PATH=/bin:/usr/bin

REPODIR=$*
REPODIR=${REPODIR:-.}
if [ ! -d "$REPODIR/repodata" ]; then
	echo "$REPODIR does not look like a yum repository" 1>&2
	read -p "Create anyway? [y/n]"
	case $REPLY in
		[yY]*) true ;;
		*) die ;;
	esac
fi

unsigned=

sync_package() {
	IFS='	
'
	set - $*
	unset IFS
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

IFS='
'

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
	failures=0
	while true; do
		rpm --addsign $unsigned && break
		let failures++
		if [ $failures -gt 3 ]; then
			die "Failed to sign packages"
		fi
	done
	createrepo -C -v .
else
	echo "No packages were added"
fi
