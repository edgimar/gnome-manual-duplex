#!/bin/sh

PROGNAME="$0"

usage() {
	cat <<EOF
NAME
    `basename $PROGNAME` - Gnome Manual Duplex backend for CUPS

SYNOPSIS
    `basename $PROGNAME` [options] URI username title copies options [filename]

DESCRIPTION
    Gnome Manual Duplex backend for CUPS.

OPTIONS
    -D lvl	Debug level
EOF

	exit 1
}

#
#       Report an error and exit
#
error() {
	echo "`basename $PROGNAME`: $1" >&2
	exit 1
}

debug() {
	if [ $DEBUG -ge $1 ]; then
	    echo "`basename $PROGNAME`: $2" >&2
	fi
}

#rm -f xxxgmd
#set -x
#exec 2> /tmp/xxxgmd

#
#       Process the options
#
DEBUG=0
infile=
while getopts "D:h?" opt
do
	case $opt in
	D)	DEBUG="$OPTARG";;
	h|\?)	usage;;
	esac
done
shift `expr $OPTIND - 1`

#
#	Main Program
#
if [ $# -lt 5 -o $# -gt 6 ]; then
    usage
fi

uri="$1"
username="$2"
title="$3"
copies="$4"
options="$5"

DIR=/var/tmp
DIR="$DIR/gmd/$username"
[ -d $DIR ] || mkdir -p $DIR
[ -d $DIR/list ] || mkdir -p $DIR/list

outfile="gmd-$$"

if [ $# = 6 ]; then
    infile="$6"
    cp $infile $DIR/${outfile}.ps
else
    cat >$DIR/${outfile}.ps
fi
chmod 666 $DIR/${outfile}.ps

echo -e "${outfile}.ps\n$title\n$copies" > $DIR/${outfile}.txt
chmod 666 $DIR/${outfile}.txt

mv $DIR/${outfile}.txt $DIR/list/
