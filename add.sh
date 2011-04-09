#!/bin/bash

if [ "$#" -eq 0 ]; then
	set - .
fi

for package in $*; do
	echo $package
	is_package_repo $package die

	dest=$CONFIGDIR/packages/`basename $package_dir`
	if [ -h $dest ]; then
		rm $dest
	fi
	if [ ! -e $dest ]; then
		ln -s $package_dir $CONFIGDIR/packages || die "Failed to create symlink to $package_dir"
	else
		echo "Package already added"
	fi
done;
