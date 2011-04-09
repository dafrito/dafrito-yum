#!/bin/bash

die() {
	echo $* 1>&2
	exit 1
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
