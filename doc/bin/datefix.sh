#!/bin/sh

export TZ=Europe/Budapest
export LC_ALL=hu_HU.UTF-8

for i; do
	cat <"$i" >/dev/null || continue
	date="`date -r "$i" '+%Y. %B %-d. %A %H.%M.%S (%Z)'`"
	grep -q "<date>$date" "$i" && continue

	echo "$i"
	mv "$i" "$i".dfx
	sed -e 's@^<date>.*$@<date>'"$date"@ <"$i".dfx >"$i"
	touch -r "$i".dfx "$i"
	rm "$i".dfx
done
