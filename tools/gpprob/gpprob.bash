#!/bin/bash

if [ "$#" -ne 3 ]
then
cat << 'EOF' >&2
This script needs exactly three parameters: "input_table" "inter_correlation_coef" "min_persistence"

Usage example:
  gprob.bash "table.tsv" 0.8 0.7

EOF
	exit 1
fi

TABLEFILE="$1"
INTERCORCOEF="$2"
THRESHOLD="$3"

if [ ! -s "$TABLEFILE" ]
then
	echo >&2 "Error: input file '${TABLEFILE}'"
	exit 1
fi

readonly TMPLDIR=$(mktemp -d)
trap "rm -r $TMPLDIR" EXIT

R --vanilla --args "$TABLEFILE" "$INTERCORCOEF" "$THRESHOLD" "${TMPLDIR}/summary" << 'EOF' > /dev/null
args=commandArgs(TRUE);
infile=args[1];
intercorcoef=as.numeric(args[2]);
threshold=as.numeric(args[3]);
outfile=args[4];

df=read.table(infile, header=TRUE, stringsAsFactors=FALSE);
per_contact_probabilies=df$predicted_probability_to_persist;
per_contact_areas=df$area/sum(df$area);

dist_mean=sum(per_contact_areas*per_contact_probabilies);
dist_var=sum((per_contact_areas^2)*per_contact_probabilies*(1-per_contact_probabilies));
dist_var=(1-intercorcoef)*dist_var+intercorcoef*dist_mean*(1-dist_mean);

dist_alpha_plus_beta=dist_mean*(1-dist_mean)/dist_var-1;
dist_alpha=dist_mean*dist_alpha_plus_beta;
dist_beta=(1-dist_mean)*dist_alpha_plus_beta;
prob_beta=(1-pbeta(threshold, shape1=dist_alpha, shape2=dist_beta));

summary=data.frame(
	name=c("probability_to_persist_globally", "expected_global_persistence", "global_persistence_threshold", "approx_var", "approx_alpha", "approx_beta"),
	value=c(prob_beta, dist_mean, threshold, dist_var, dist_alpha, dist_beta));

write.table(summary, file=outfile, sep="\t", quote=FALSE, row.names=FALSE, col.names=FALSE);
EOF

if [ ! -s "${TMPLDIR}/summary" ]
then
	echo >&2 "Error: failed to produce summary"
	exit 1
fi

cat "${TMPLDIR}/summary" | column -t



