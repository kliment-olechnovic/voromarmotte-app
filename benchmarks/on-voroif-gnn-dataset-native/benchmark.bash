#!/bin/bash

SCRIPTDIR="$( cd -- "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cd "$SCRIPTDIR"

################################################################################

mkdir -p "./output"

[ -s "./output/global_scores_inter_chain.txt" ] || \
find ./input/structures/ -type f -name '????.pdb' \
| sort \
| ../../voromarmotte --input _list --rebuild-sidechains 'false' --processors 12 --subselect-contacts '[-inter-chain]' --output-table-file "./output/global_scores_inter_chain.txt"

################################################################################

R --vanilla << 'EOF'
df=read.table("./output/global_scores_inter_chain.txt", header=TRUE, stringsAsFactors=FALSE);
pdf("./output/plots.pdf");

plot(df$pseudoenergy, df$pseudoenergy/df$area);
plot(df$pseudoenergy, df$best_core_pseudoenergy);
plot(df$pseudoenergy/df$area, df$best_core_pseudoenergy/df$best_core_area);
plot(df$pseudoenergy/df$area, df$best_core_area/df$area);

hist(df$pseudoenergy/df$area);
hist(df$best_core_pseudoenergy/df$best_core_area);

x=sort(c(-3, -2.5, -2, df$pseudoenergy/df$area, 2, 2.5, 3));
y=(tanh(0-x-0.6)+1)/2;
plot(x, y);
lines(x, y);
abline(v=-1);
abline(v=0);
EOF

################################################################################


