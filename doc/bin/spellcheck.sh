#!/bin/bash

export LC_ALL=hu_HU.UTF-8

cat "$@" |
  sed -e 's@<bf/\(.\)/@\1@g' |
  awk '{ print toupper($LINE) }' |
  hunspell -l |
  awk '{ print tolower($LINE) }' |
  egrep -vx '(abstract|descrip|doctype|itemize|linuxdoc|sect)' |
  sort -u > spell.txt
