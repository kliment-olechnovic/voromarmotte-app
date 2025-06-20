#!/bin/bash

SCRIPTDIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cd "$SCRIPTDIR"

################################################################################

mkdir -p "./output"

[ -s "./output/global_scores_inter_chain.txt" ] || \
find ./input/structures/ -type f -name '*.pdb' \
| shuf \
| ../../voromarmotte --conda-path ~/miniconda3 -i _list --processors 32 --subselect-contacts '[-inter-chain]' --output-table-file "./output/global_scores_inter_chain.txt"

#[ -s "./output/global_scores_full.txt" ] || \
#find ./input/structures/ -type f -name '*.pdb' \
#| shuf \
#| ../../voromarmotte --conda-path ~/miniconda3 -i _list --processors 32 --subselect-contacts '[]' --output-table-file "./output/global_scores_full.txt"

################################################################################

{
cat << 'EOF'
./output/global_scores_inter_chain.txt ./output/summary_of_selections_using_global_scores_inter_chain.txt
EOF
} \
| while read -r INFILE OUTFILE
do
R --vanilla --args "$INFILE" "$OUTFILE" << 'EOF' > /dev/null
args=commandArgs(TRUE);
infile=args[1];
outfile=args[2];

df1=read.table("./output/global_scores_inter_chain.txt", header=TRUE, stringsAsFactors=FALSE);
df1$area_persistence_win=(df1$area_expected_to_persist-df1$area_expected_to_vanish)/df1$area_total;

df2=read.table("./input/table_of_cadscores.tsv", header=TRUE, stringsAsFactors=FALSE);

df=merge(df1, df2, by.x="ID", by.y="input_name");
nrow(df);

df=df[grep("_0.pdb$", df$ID, invert=TRUE),];
nrow(df);

targets_to_exclude=c("2JKI.pdb", "2ZIX.pdb", "3N7P.pdb", "3TX7.pdb", "4BMP.pdb", "4IMI.pdb", "4LSX.pdb", "4P4Q.pdb", "4UIP.pdb", "4V2C.pdb", "5AQB.pdb", "5AYS.pdb", "5WP3.pdb", "6K2D.pdb", "6LOJ.pdb", "6MWQ.pdb", "6N4N.pdb", "6SHX.pdb");

df=df[which(!is.element(df$target, targets_to_exclude)),];
nrow(df);

df_native=df[grep("^.....pdb$", df$ID),];
nrow(df_native);

df_decoy=df[grep("^.....pdb$", df$ID, invert=TRUE),];
nrow(df_decoy);

df_native$max_area_persistence_win=0;
df_native$min_decoy_area_expected_to_persist=0;
df_native$max_decoy_area_expected_to_persist=0;
df_native$min_decoy_area_expected_to_vanish=0;
df_native$max_decoy_area_expected_to_vanish=0;
for(i in 1:nrow(df_native))
{
	sdf_decoy=df_decoy[which(df_decoy$target==df_native$target[i]),];
	df_native$max_area_persistence_win[i]=max(sdf_decoy$area_persistence_win);
	df_native$min_decoy_area_expected_to_persist[i]=min(sdf_decoy$area_expected_to_persist);
	df_native$max_decoy_area_expected_to_persist[i]=max(sdf_decoy$area_expected_to_persist);
	df_native$min_decoy_area_expected_to_vanish[i]=min(sdf_decoy$area_expected_to_vanish);
	df_native$max_decoy_area_expected_to_vanish[i]=max(sdf_decoy$area_expected_to_vanish);
}

num_of_targets=nrow(df_native);

num_of_failed_selections=length(which(df_native$area_persistence_win<df_native$max_area_persistence_win));

fraction_of_succesfull_selections=1-(num_of_failed_selections/num_of_targets);

summary=data.frame(num_of_targets=num_of_targets, num_of_failed_selections=num_of_failed_selections, fraction_of_succesfull_selections=fraction_of_succesfull_selections);
write.table(summary, file=outfile, row.names=FALSE, col.names=TRUE, quote=FALSE, sep="\t");
EOF

	cat "$OUTFILE" | column -t | sponge "$OUTFILE"
	
	echo "${OUTFILE}:"
	cat "$OUTFILE" | sed 's/^/    /'
	echo
done

################################################################################


