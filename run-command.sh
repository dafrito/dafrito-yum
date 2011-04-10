#!/bin/bash
PATH=/bin:/usr/bin

if [ ! "$INSTALLED" ]; then

	# Name of this tool
	NAME=`basename $0 .sh`

	bindir=`dirname $0`
	cd $bindir
	bindir=`pwd`
	cd - >/dev/null

	# Internally-used commands, typically /usr/lib/$NAME
	LIBDIR=$bindir

	# Arch-independent data for this tool, typically /usr/share/$NAME
	DATADIR=$bindir

	# User-specific configuration, typically ~/.$NAME
	CONFIGDIR=$bindir/config
	CONFIGDIR=$bindir/config
fi

if ! source $LIBDIR/functions.sh; then
	echo "$NAME: Failed to load functions.sh" 1>&2
	exit 1
fi


mkdir -p $CONFIGDIR || die "Failed to create configuration directory: $CONFIGDIR"
configfile=$CONFIGDIR/config
if [ ! -f "$configfile" ]; then
	cp $DATADIR/config.default $configfile || die "Failed to create configuration: $configfile"
fi
source $configfile || die "Failed to read configuration: $configfile"

PACKAGEDIR=$CONFIGDIR/packages
mkdir -p $PACKAGEDIR || die "Failed to create package directory: $PACKAGEDIR"

CMD=$1
shift

check_remote || die
export NAME CONFIGDIR LIBDIR DATADIR SRCDIR RPMDIR CMD REMOTE PACKAGEDIR REPODIR

command() {
	local cmd=$1
	shift
	bash -c "source $LIBDIR/functions.sh; source $configfile; source $LIBDIR/$cmd.sh $*"
}

case "$CMD" in 
	a|add) command add $* ;;
	ls|list) ls -l $PACKAGEDIR ;;
	rm|remove|delete) command remove $* ;;
	pull|clone|get) command pull $* ;;
	push|sync) command push $* ;;
	up*|build|make) command update $* ;;
	*) die "Usage: $NAME {add|push|pull|build}"
esac
