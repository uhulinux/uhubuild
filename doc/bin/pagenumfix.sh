#!/bin/sh

op2="`echo "$1" | sed -e 's/@/$2/g' -e 's/,/ "," /g'`"
op3="`echo "$1" | sed -e 's/@/$3/g' -e 's/,/ "," /g'`"

shift

for i; do

	awk -F '[^0-9]*' '
		/^%%Title: / { print "%%Title: UHUBUILD"; next }
		/^%%Page: .*,/ { print "%%Page: (" '"$op2"' "," '"$op3"' ") " $4; next }
		/^%%Page: / { print "%%Page: (" '"$op2"' ") " $3; next }
		{ print $0 }
	' <"$i" >"$i.pnf"

	mv "$i.pnf" "$i"

done
