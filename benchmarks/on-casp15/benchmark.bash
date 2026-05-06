#!/bin/bash

SCRIPTDIR="$( cd -- "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cd "$SCRIPTDIR"

################################################################################

mkdir -p "./output"

[ -s "./output/used_input_files.txt"  ] || \
cat ./input_files.txt \
| egrep -v 'T1132|T1170|T1192|T1115|H1185|H1171|H1172|H1135|H1111|H1166|H1167|H1168|T1173|H1114|H1114|T1176|T1174|T1181|H1137' \
| sort \
> "./output/used_input_files.txt"

[ -s "./output/global_scores.txt" ] || \
cat "./output/used_input_files.txt" \
| ../../voromarmotte --input _list --rebuild-sidechains 'false' --processors 12 --output-table-file "./output/global_scores.txt"

[ -s "./output/global_scores_vorochipmunk.txt" ] || \
cat "./output/used_input_files.txt" \
| ${HOME}/git/vorochipmunk-app/vorochipmunk -i _list --processors 4 --output-table-file "./output/global_scores_vorochipmunk.txt"

if [ ! -s "./output/global_scores_voroif-gnn-v2.txt" ]
then
	NUM_OF_INPUTS="$(cat "./output/used_input_files.txt" | wc -l)"
	
	seq 1 24 "$NUM_OF_INPUTS" \
	| while read -r STARTPOS
	do
		cat "./output/used_input_files.txt" | tail -n "+${STARTPOS}" | head -n 24 \
		| ${HOME}/git/voroif-gnn-v2-app/voronota-js-voroif-gnn-v2 --conda-path "${HOME}/miniconda3" --conda-env 'voroif-gnn-v2-env' --processors 12
	done \
	| awk '{if($1!="ID" || NR==1){print $0}}' \
	> "./output/global_scores_voroif-gnn-v2.txt"
fi

################################################################################

cd "./output"

R --vanilla << 'EOF' > "./analysis_log.txt"
df1=read.table("global_scores.txt", header=TRUE, stringsAsFactors=FALSE);
df1=df1[which(df1$ic_fraction>0.0),];

df1$score0=0-df1$ic_area_total;

df1$score1=0-df1$ic_area_pseudoenergy/df1$ic_area_total;

df1$score2=0-df1$pseudoenergy/df1$area;

df1$score3=df1$ic_best_core_area/df1$ic_area_total;

df1$score4=0-df1$ic_area_pseudoenergy;

df1$score5=0-df1$pseudoenergy;

df1$score12=(0-df1$pseudoenergy/df1$area)*(1-df1$ic_fraction^2);

df2=read.table("cadscores.tsv", header=TRUE, stringsAsFactors=FALSE);

df3=read.table("global_scores_vorochipmunk.txt", header=TRUE, stringsAsFactors=FALSE);

df3$score6=0-df3$iface_pseudoenergy;

df3$score7=0-df3$iface_pseudoenergy/df3$iface_area;

df4=read.table("global_scores_voroif-gnn-v2.txt", header=TRUE, stringsAsFactors=FALSE);

df4$score8=df4$pgoodness;

df4$score9=df4$pgoodness_average;

df4$score10=df4$residue_pcadscore;


nrow(df1);
nrow(df2);
nrow(df3);
nrow(df4);
df=merge(df1, df2, by.x="ID", by.y="input_name");
df=merge(df, df3, by.x="ID", by.y="input_name");
df=merge(df, df4, by.x="ID", by.y="ID");
nrow(df);

df$score11=0-df$pseudoenergy/df$input_atoms;

targets=sort(union(df$target, df$target));

per_target_max_cadscores=c();
for(target in targets)
{
	per_target_max_cadscores=c(per_target_max_cadscores, max(df$iface_cadscore[which(df$target==target)]));
}
targets=targets[which(per_target_max_cadscores>0.5)];

df$completeness=1;
for(target in targets)
{
	sel=which(df$target==target);
	df$completeness[sel]=df$input_atoms[sel]/median(df$input_atoms[sel]);
}
df=df[which(df$completeness>0.9),];
nrow(df);

df=df[which(df$iface_clash_score<0.4),];
nrow(df);

plot(df$iface_cadscore, df$score1);
plot(df$iface_cadscore, df$score2);
plot(df$iface_cadscore, df$score3);
plot(df$iface_cadscore, df$score4);
plot(df$iface_cadscore, df$score5);
plot(df$iface_cadscore, df$score6);
plot(df$iface_cadscore, df$score7);
plot(df$iface_cadscore, df$score8);
plot(df$iface_cadscore, df$score9);

per_target_sel0_cadscores=c();
per_target_sel1_cadscores=c();
per_target_sel2_cadscores=c();
per_target_sel3_cadscores=c();
per_target_sel4_cadscores=c();
per_target_sel5_cadscores=c();
per_target_sel6_cadscores=c();
per_target_sel7_cadscores=c();
per_target_sel8_cadscores=c();
per_target_sel9_cadscores=c();
per_target_sel10_cadscores=c();
per_target_sel11_cadscores=c();
per_target_sel12_cadscores=c();
for(target in targets)
{
	sdf=df[which(df$target==target),];
	per_target_sel0_cadscores=c(per_target_sel0_cadscores, sdf$iface_cadscore[order(0-sdf$score0)[1]]);
	per_target_sel1_cadscores=c(per_target_sel1_cadscores, sdf$iface_cadscore[order(0-sdf$score1)[1]]);
	per_target_sel2_cadscores=c(per_target_sel2_cadscores, sdf$iface_cadscore[order(0-sdf$score2)[1]]);
	per_target_sel3_cadscores=c(per_target_sel3_cadscores, sdf$iface_cadscore[order(0-sdf$score3)[1]]);
	per_target_sel4_cadscores=c(per_target_sel4_cadscores, sdf$iface_cadscore[order(0-sdf$score4)[1]]);
	per_target_sel5_cadscores=c(per_target_sel5_cadscores, sdf$iface_cadscore[order(0-sdf$score5)[1]]);
	per_target_sel6_cadscores=c(per_target_sel6_cadscores, sdf$iface_cadscore[order(0-sdf$score6)[1]]);
	per_target_sel7_cadscores=c(per_target_sel7_cadscores, sdf$iface_cadscore[order(0-sdf$score7)[1]]);
	per_target_sel8_cadscores=c(per_target_sel8_cadscores, sdf$iface_cadscore[order(0-sdf$score8)[1]]);
	per_target_sel9_cadscores=c(per_target_sel9_cadscores, sdf$iface_cadscore[order(0-sdf$score9)[1]]);
	per_target_sel10_cadscores=c(per_target_sel10_cadscores, sdf$iface_cadscore[order(0-sdf$score10)[1]]);
	per_target_sel11_cadscores=c(per_target_sel11_cadscores, sdf$iface_cadscore[order(0-sdf$score11)[1]]);
	per_target_sel12_cadscores=c(per_target_sel12_cadscores, sdf$iface_cadscore[order(0-sdf$score12)[1]]);
}

median(per_target_sel0_cadscores);
median(per_target_sel1_cadscores);
median(per_target_sel2_cadscores);
median(per_target_sel3_cadscores);
median(per_target_sel4_cadscores);
median(per_target_sel5_cadscores);
median(per_target_sel6_cadscores);
median(per_target_sel7_cadscores);
median(per_target_sel8_cadscores);
median(per_target_sel9_cadscores);
median(per_target_sel10_cadscores);
median(per_target_sel11_cadscores);
median(per_target_sel12_cadscores);

mean(per_target_sel0_cadscores);
mean(per_target_sel1_cadscores);
mean(per_target_sel2_cadscores);
mean(per_target_sel3_cadscores);
mean(per_target_sel4_cadscores);
mean(per_target_sel5_cadscores);
mean(per_target_sel6_cadscores);
mean(per_target_sel7_cadscores);
mean(per_target_sel8_cadscores);
mean(per_target_sel9_cadscores);
mean(per_target_sel10_cadscores);
mean(per_target_sel11_cadscores);
mean(per_target_sel12_cadscores);

EOF

cat "./analysis_log.txt"

################################################################################

