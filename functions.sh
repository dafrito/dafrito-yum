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
	make -n rpm >/dev/null || $output "Package cannot be built using make"
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
			die "Failed after $times tries"
		fi
	done
}
