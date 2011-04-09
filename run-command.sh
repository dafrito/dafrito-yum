#!/bin/bash
PATH=/bin:/usr/bin

if [ ! "$INSTALLED" ]; then

	# Name of this tool
	NAME=`basename $0 .sh`

	# Internally-used commands
	LIBDIR=`dirname $0`

	# Arch-independent data for this tool
	DATADIR=`dirname $0`

	# User-specific configuration
	CONFIGDIR=$LIBDIR/config
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

CMD=$1
shift

export NAME CONFIGDIR LIBDIR DATADIR SRCDIR RPMDIR CMD REMOTE

command() {
	local cmd=$1
	shift
	bash -c "source $LIBDIR/functions.sh; source $configfile; source $LIBDIR/$cmd.sh $*"
}

case "$CMD" in 
	pull|clone|get) command pull $* ;;
	push|sync) command push $* ;;
	up*|build|make) command update $* ;;
	*) die "Usage: $NAME {push|pull|build}"
esac
