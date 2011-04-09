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
	[ -d "$*"/repodata ]
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
