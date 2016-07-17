# get links from url
function _geturl() {
	url="$1"
	listonly="$2"
	cmd=''
	listonly_param=""
	if [ "$listonly" == 1 ]; then
		listonly_param="-listonly"
	fi
	if [[ "$url" =~ ^ftp ]]; then
		timeout 10 lynx -connect_timeout=5 -read_timeout=5 -passive-ftp $listonly_param -dump $url ||
		timeout 10 lynx -connect_timeout=5 -read_timeout=5 $listonly_param -dump $url
	else
		timeout 10 curl -m 10 -sLk $url | lynx -stdin $listonly_param -dump
	fi
}

function geturl() {
	_geturl "$1" 1 | grep -E '^ *[0-9]+\. +' | sed -r 's/^ *[0-9]+\. *(.*)$/\1/'
}

# get files from url
function urllist() {
	geturl "$@" | sed -r 's/^.*\/([^\/]+)\/?$/\1/'
}

# automatically parse version number from file
function parsever() {
	grep -E '.*-([0-9.-]+)\.((tar\.)|(t))?(gz|bz2|xz|zip)$' | sed -r 's/.*-([0-9.-]+)\.((tar\.)|(t))?(gz|bz2|xz|zip)/\1/'
}

# split version number from file
function splitver() {
	num=1
	if [ "$#" -eq 2 ]; then
		num="$2"
	fi
	if [ "$#" -eq 0 ]; then
		pattern='.*-([0-9.]+)\.((tar\.)|(t))?(gz|bz2|xz|zip)$'
	else
		pattern="$1"
	fi

	grep -E "$pattern" | sed -r 's/'"$pattern"'/\'"$num"'/'
}

# general script: all release in one dir
function u2d {
	urllist $1 | parsever | sort -V | tail -n 1
}

# general script: release placed under versioned directory
function u2dsubdir {
	project="$1"
	ver="$(urllist $project | grep -E '^[0-9.]+$' | sort -V | tail -n 1)"
	urllist $project/$ver | parsever | sort -V | tail -n 1
}

# list sourceforge project files
function sflist() {
	project="$1"
	path="$2"
	geturl "http://sourceforge.net/projects/$project/files/$path" | grep -E "$project/files/$path(/[^/])?" | while read n; do
		if [[ "$n" =~ /$ ]]; then
			echo $n | sed -r 's/^.*\/([^\/]+)\/$/\1/'
		elif [[ "$n" =~ /download$ ]]; then
			echo "$n" | sed -r 's/^.*\/([^\/]+)\/download$/\1/'
		fi
	done
}

# script for gnome projects
function u2dgnome {
	project="$1"
	unstable="$2"
	reg="02468";
	if [ -n "${unstable:-}" ]; then
		reg="0-9"
	fi
	ver="$(urllist "ftp://ftp.gnome.org/pub/gnome/sources/$project/" | grep -E '^[0-9]+\.[0-9]*['$reg'](\.[0-9.])?$' | sort -V | tail -n 1)"
	urllist "ftp://ftp.gnome.org/pub/gnome/sources/$project/$ver" | grep LATEST-IS | sed -r 's/LATEST-IS-//' | sort -V | tail -n 1
}

# script for perl modules
function u2dcpan() {
	ver="$(curl -m 10 -s http://cpanmetadb.plackperl.org/v1.0/package/$1)"
	if echo $ver | grep -q 'xml version'; then
		exit 1;
	fi
	ver="$(echo "$ver" | grep ^version:)"
	echo "${ver##*: }"
}

# script for python modules
function u2dpypi() {
	project="$1"
	urllist "https://pypi.python.org/simple/$project/" | sed 's/#.*//' | parsever | sort -V | tail -n 1
}

