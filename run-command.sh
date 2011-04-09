#!/bin/bash
PATH=/bin:/usr/bin

if [ ! "$INSTALLED" ]; then

	# Name of this tool
	NAME=`basename $0 .sh`

	# Internally-used commands, typically /usr/lib/$NAME
	LIBDIR=`dirname $0`

	# Arch-independent data for this tool, typically /usr/share/$NAME
	DATADIR=`dirname $0`

	# User-specific configuration, typically ~/.$NAME
	CONFIGDIR=$LIBDIR/config
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

PACKAGEDIR=$CONFIGDIR/packages
mkdir -p $PACKAGEDIR || die "Failed to create package directory: $PACKAGEDIR"

CMD=$1
shift

export NAME CONFIGDIR LIBDIR DATADIR SRCDIR RPMDIR CMD REMOTE PACKAGEDIR

command() {
	local cmd=$1
	shift
	bash -c "source $LIBDIR/functions.sh; source $configfile; source $LIBDIR/$cmd.sh $*"
}

case "$CMD" in 
	add) command add $* ;;
	pull|clone|get) command pull $* ;;
	push|sync) command push $* ;;
	up*|build|make) command update $* ;;
	*) die "Usage: $NAME {add|push|pull|build}"
esac
