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
	grep -E '.*-([0-9.-]+)\.((tar\.)|(t))?(lz|gz|bz2|xz|zip)$' | sed -r 's/.*-([0-9.-]+)\.((tar\.)|(t))?(lz|gz|bz2|xz|zip)/\1/'
}
# paraméterekkel
function _parsever() {
	grep -E "^$filename([0-9.-]+)$tarprefix\.((tar\.)|(t))?(lz|gz|bz2|xz|zip)$" | sed -r "s/$filename([0-9.-]+)$tarprefix\.((tar\.)|(t))?(lz|gz|bz2|xz|zip)/\1/"
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

# general script: all release in one dir (+github projects)
function u2d {
	if [ -z $3 ]; then
		tarprefix=""
	else
	    tarprefix="$3"
	fi
	if [ "$(echo $1 | grep github.com)" ];then
		if [ -z $2 ]; then
	    	filename=""
		else
			filename="$2"
		fi
	else
		if [ -z $2 ]; then
			filename=".*-"
		else
			filename="$2"
		fi
	fi
	urllist $1 | _parsever | sort -V | tail -n 1
}

# general script: release placed under versioned directory
function u2dsubdir {
	project="$1"
    if [ -z $3 ]; then
       tarprefix=""
    else
       tarprefix="$3"
	fi
	if [ -z $2 ]; then
		filename=".*-"
	else
	    filename="$2"
	fi
	for ver in $(urllist $project | grep -E '^[0-9.]+$' | sort -rV);do
        version=$(urllist $project/$ver/$srcdir/ | _parsever | sort -V | tail -n 1)
        if [ "$version" ];then
            echo $version
            exit 0
        fi
    done
}

# u2dsrc script: files under versioned subdir/src 
function u2dsrc {
    urlcim=$1
    filename="$2"-
	for ver in $(urllist $urlcim | grep -E '^[0-9.]+$' | sort -rV);do
        version=$(u2d $urlcim/$ver/src/ $filename)
        if [ "$version" ];then
            echo $version
            exit 0
        fi
    done
}

# kdeapps project
function kdeapp {
    u2dsrc https://download.kde.org/stable/applications/ $1
}

# list sourceforge project files
function sflist() {
	project="$1"
	path="$2"
	 #A grep csak a normál karakteres formájú $sppath stinget eszi, a geturl meg csak a %20 stílusú $path stringet.
	sppath=$(echo -e "${path//%/\x}")
	geturl "http://sourceforge.net/projects/$project/files/$path" | grep -E "$project/files/$sppath(/[^/])?" | while read n; do
		if [[ "$n" =~ /$ ]]; then
			echo $n | sed -r 's/^.*\/([^\/]+)\/$/\1/'
		elif [[ "$n" =~ /download$ ]]; then
			echo "$n" | sed -r 's/^.*\/([^\/]+)\/download$/\1/'
		fi
	done
}

# sourceforge subdirs
function sflistd() {
subdir=$(sflist $1 $2 | splitver '^([0-9.]+)$' | sort -V | tail -n 1)
sflist $1 $2/$subdir | parsever | sort -V | tail -n 1
}

# script for gnome projects
function u2dgnome {
	project="$1"
	unstable="$2"
	reg="02468";
	if [ -n "${unstable:-}" ]; then
		reg="0-9"
	fi
	ver="$(urllist "https://download.gnome.org/sources/$project/" | grep -E '^[0-9]+\.[0-9]*['$reg'](\.[0-9.])?$' | sort -V | tail -n 1)"
	u2dsubdir "https://download.gnome.org/sources/$project/$ver"
}

# script for mate projects
function u2dmate {
	project="$1"
	unstable="$2"
	reg="02468";
	if [ -n "${unstable:-}" ]; then
		reg="0-9"
	fi
	ver="$(urllist "http://pub.mate-desktop.org/releases/" | grep -E '^[0-9]+\.[0-9]*['$reg'](\.[0-9.])?$' | sort -V | tail -n 1)"
	urllist http://pub.mate-desktop.org/releases/"$ver/" | splitver '^'$project'-([0-9.]+).tar.(gz|bz2|xz)$' | sort -V | tail -n 1
}

# script for xfce4
function u2dxfce {
	subdir="$1" #xfce vagy apps
	project="$2"
	unstable="$3"
	reg="02468";
	if [ -n "${unstable:-}" ]; then
		reg="0-9"
	fi
    ver="$(urllist http://archive.xfce.org/src/$subdir/$project | grep -E '^[0-9]+\.[0-9]*['$reg'](\.[0-9.])?$' | sort -V | tail -n 1)"
    urllist http://archive.xfce.org/src/$subdir/$project/"$ver/" | splitver '^'$project'-([0-9.]+).tar.(gz|bz2|xz)$' | sort -V | tail -n 1
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

