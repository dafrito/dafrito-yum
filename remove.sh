#!/bin/bash

package="$*"

if [ -z "$package" ]; then
	package=`pwd`
fi

if [ -d $package ]; then
	package=`basename $package`
fi

cd $PACKAGEDIR
for candidate in `ls`; do
	if [ "$candidate" = "$package" ]; then
		rm -v $candidate
	fi;
done
