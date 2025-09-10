#!/bin/bash

export LANG=C
export LC_ALL=C

INFILE="$1"

if [ -z "$INFILE" ]
then
	exit 1
fi

readonly TMPLDIR=$(mktemp -d)
trap "rm -r $TMPLDIR" EXIT

cat "$INFILE" > "${TMPLDIR}/table"

cd "$TMPLDIR"

awk -F'[[:space:]]+' -v OFS=' ' -v n=3 '
function fmt(x,    s){ s=sprintf("%.*f",n,x); sub(/\.?0+$/,"",s); return s }
{
  for (i=1; i<=NF; i++)
    if ($i ~ /^-?([0-9]+(\.[0-9]*)?|\.[0-9]+)([eE][-+]?[0-9]+)?$/)
      $i = fmt($i)
  print
}' ./table \
> ./reformatted_table

cd - &> /dev/null

cat "${TMPLDIR}/reformatted_table" | column -t > "$INFILE"

