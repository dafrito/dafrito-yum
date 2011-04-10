#!/bin/bash

die() {
	echo $* 1>&2
	exit 1
}

warn() {
	echo $* 1>&2
}

noop() {
	true # do nothing
}

confirm() {
	local query="$*"
	[ -n "$query" ] || query="Is this acceptable?"
	read -p "$query [y/n]: "
	case "$REPLY" in
		[yY]*) return 0 ;;
		*) return 1 ;;
	esac
}

is_yum_repo() {
	[ -d "$1"/repodata ]
}

is_package_repo() {
	local package=$1
	local output=${2:-echo}
	[ -d $package ] || $output "Not a package directory: $package"
	pushd $package >/dev/null || $output "Package is not accessible: $package"
	make -n spec >/dev/null || $output "Package specfile cannot be built using make"
	make -n rpm >/dev/null || $output "Package RPM cannot be built using make"
	package_dir=`pwd`
	popd >/dev/null
}

get_remote_host() {
	echo $REMOTE | grep -o -E '^[^:]+'
}

get_remote_path() {
	echo $REMOTE | grep -o -E '[^:]+$'
}

test_remote() {
	ssh `get_remote_host` "ls -ld `get_remote_path` >/dev/null"
}

check_remote() {
	if [ -z "$REMOTE" ] || (echo $REMOTE | grep -q example); then
		echo "REMOTE is not valid (currently $REMOTE)"
		read -p "Press any key to edit $CONFIGDIR/config"
		[ -n "$EDITOR" ] || die "\$EDITOR is not set"
		$EDITOR $CONFIGDIR/config
		source $CONFIGDIR/config || die "Failed to read configuration"
		if test_remote; then
			echo "REMOTE is now $REMOTE"
			return
		fi;
		die "Failed to set REMOTE"
	else
		if ! test_remote; then
			die "Failed to access $REMOTE"
		fi
	fi
}

attempt() {
	local times=$1
	shift
	local cmd="$*"
	local failures=0
	while true; do
		$cmd && break
		let failures++
		if [ $failures -gt $times ]; then
			return 1
		fi
	done
	return 0
}

abs_path() {
	[ -d $1 ] || die "$1 is not a directory"
	cd $1 || die "Failed to chdir into $1"
	pwd
}
