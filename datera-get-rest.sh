#!/bin/bash
################################################################################
## 2020-02-17 Heiko Wuest

## datera-get-rest.sh
VERSION=1.0
SCRIPT="`basename $0`"

## DEFAULT VALUES 
USER=admin
PASSWD="password"

## API Version
RESTVERSION="v2.2"

## Tool pathes
CURLPATH="/usr/bin/curl"
JQPATH="/usr/bin/jq"

################################################################################

if ! [ -x "$(command -v $JQPATH)" ]; then
  echo $JQPATH "not found"
  echo "install via repo or from https://stedolan.github.io/jq/"
  exit 1
fi

version() { echo "$SCRIPT version $VERSION"; }

errexit() { echo "error: $*"; exit 1; }

vout() { [[ $VERBOSE ]] && echo "$SCRIPT: $@"; }

usage() {
	version
	echo "This script will curl to Rest-API and retrieve configuration data
Usage: $SCRIPT  [options]  <data_path>

    Options
    -h	host 	host 
    -u	user 	user (default=$USER)
    -p	pass 	password (default=$PASSWD)
    -t		output login token and quit
    -v		verbose
    -V		version
"
	exit
}

check_vars() {
	[ -z "$USER" ] && errexit "USER not set"
	[ -z "$HOST" ] && errexit "HOST not set"
	[ -z "$PASSWD" ] && errexit "PASSWD not set"
}

set_vars() {
	[[ -z $HOST ]] && errexit "HOST not set"
	
	LOGIN_DATA="-d '{\"name\":\"'$USER'\",\"password\":\"'$PASSWD'\"}'"
	LOGIN_HEADER="Content-Type: application/json"
	LOGIN_URL="http://$HOST:7717/$RESTVERSION/login"
	
	[[ $VERBOSE ]] || LOGIN_OPTS="-s"
	
	CURL_HEADER="-H \"$LOGIN_HEADER\""
	CURL_PUT="-X PUT -k"
	CURL_OPTS="$CURL_HEADER $LOGIN_URL $CURL_PUT $LOGIN_DATA $LOGIN_OPTS"
	
	CURL_COM="$CURLPATH $CURL_OPTS"
	
	vout "HOST:     $HOST"
	vout "USER:     $USER"
	vout "PASSWD:   $PASSWD"
	vout "CURL_COM: $CURL_COM"
	vout ""
}

set_query() {
	[[ -z $TOKEN ]] && errexit "missing TOKEN"
	[[ -z $HOST ]] && errexit "missing HOST"
	[[ -z $DATASTR ]] && errexit "missing DATASTR"
	
	QUERY_HEADER="-H \"auth-token: $TOKEN\""
	QUERY_GET="-X GET -k"
	
	[[ $VERBOSE ]] || QUERY_OPTS="-s"
	
	QUERY_URL="http://$HOST:7717/$RESTVERSION/$DATASTR"
	QUERY_COM="$CURLPATH $QUERY_HEADER $QUERY_URL $QUERY_GET $QUERY_OPTS"
}

get_token() {
	OUTPUT="`eval $CURL_COM`"
	TOKEN="`echo $OUTPUT | $JQPATH -r .key`"
}


################################################################################
## Main

while getopts h:u:p:tvVH name
do
	case $name in
		h) HOST="$OPTARG";;
		u) USER="$OPTARG";;
		p) PASSWD="$OPTARG";;
		t) FLAG_TOKEN=1;;
		v) VERBOSE=1;;
		V) version; exit;;
		H) usage;;
		?) usage;;
	esac
done

shift $(($OPTIND - 1))

DATASTR="$1"

set_vars

get_token

if [[ $FLAG_TOKEN ]]; then
	echo $TOKEN
	exit
fi

set_query

eval $QUERY_COM

################################################################################

