#!/bin/bash

if [ "$#" -ne 4 ]
then
cat << 'EOF' >&2
This script needs exactly four parameters: "input_table" "variance_scaling" "variance_addition" "min_persistence"

Usage example:
  gprob.bash "table.tsv" 1.0 0.05 0.5

EOF
	exit 1
fi

TABLEFILE="$1"
VARSCALING="$2"
VARADDITION="$3"
THRESHOLD="$4"

if [ ! -s "$TABLEFILE" ]
then
	echo >&2 "Error: input file '${TABLEFILE}'"
	exit 1
fi

readonly TMPLDIR=$(mktemp -d)
trap "rm -r $TMPLDIR" EXIT

R --vanilla --args "$TABLEFILE" "$VARSCALING" "$VARADDITION" "$THRESHOLD" "${TMPLDIR}/summary" << 'EOF' > /dev/null
args=commandArgs(TRUE);
infile=args[1];
varscaling=as.numeric(args[2]);
varaddition=as.numeric(args[3]);
threshold=as.numeric(args[4]);
outfile=args[5];

df=read.table(infile, header=TRUE, stringsAsFactors=FALSE);
per_contact_probabilies=df$predicted_probability_to_persist;
per_contact_areas=df$area/sum(df$area);

dist_mean=sum(per_contact_areas*per_contact_probabilies);
dist_var=sum((per_contact_areas^2)*per_contact_probabilies*(1-per_contact_probabilies));
dist_var=dist_var*varscaling+varaddition;

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



