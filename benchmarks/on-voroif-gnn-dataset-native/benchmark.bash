#!/bin/bash

SCRIPTDIR="$( cd -- "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cd "$SCRIPTDIR"

################################################################################

mkdir -p "./output"

[ -s "./output/global_scores.txt" ] || \
find ./input/structures/ -type f -name '????.pdb' \
| sort \
| ../../voromarmotte --input _list --rebuild-sidechains 'false' --processors 12 --output-table-file "./output/global_scores.txt"

################################################################################

R --vanilla << 'EOF'
df=read.table("./output/global_scores.txt", header=TRUE, stringsAsFactors=FALSE);
pdf("./output/plots.pdf");

plot(df$ic_area_pseudoenergy, df$ic_area_pseudoenergy/df$ic_area_total);
plot(df$ic_area_pseudoenergy, df$ic_best_core_pseudoenergy);
plot(df$ic_area_pseudoenergy/df$ic_area_total, df$ic_best_core_pseudoenergy/df$ic_best_core_area);
plot(df$ic_area_pseudoenergy/df$ic_area_total, df$ic_best_core_area/df$ic_area_total);
plot(df$pseudoenergy/df$area, df$ic_area_pseudoenergy/df$ic_area_total);

hist(df$ic_area_pseudoenergy/df$ic_area_total);
hist(df$pseudoenergy/df$area);

hist(df$ic_best_core_pseudoenergy/df$ic_best_core_area);
hist(df$ic_fraction);

x=sort(c(-3, -2.5, -2, df$ic_area_pseudoenergy/df$ic_area_total, 2, 2.5, 3));
y=(tanh(0-x-0.6)+1)/2;
plot(x, y);
lines(x, y);
abline(v=-1);
abline(v=0);

EOF

################################################################################


