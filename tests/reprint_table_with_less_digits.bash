#!/bin/bash

INFILE="$1"

if [ -z "$INFILE" ]
then
	exit 1
fi

readonly TMPLDIR=$(mktemp -d)
trap "rm -r $TMPLDIR" EXIT

cat "$INFILE" > "${TMPLDIR}/table"

cd "$TMPLDIR"

R --vanilla << 'EOF' > /dev/null
df=read.table("table", header=TRUE, stringsAsFactors=FALSE);
df_formatted=data.frame(lapply(df, function(x) { if (is.numeric(x)) format(x, digits = 6, scientific = FALSE) else x }), stringsAsFactors = FALSE);
write.table(df_formatted, file="table", row.names=FALSE, col.names=TRUE, quote=FALSE, sep="\t");
EOF

cd - &> /dev/null

cat "${TMPLDIR}/table" | column -t > "$INFILE"

