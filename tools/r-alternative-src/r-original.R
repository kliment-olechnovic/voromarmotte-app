args=commandArgs(TRUE);
idvalue=args[1];
inputmodifications=args[2];

df=read.table("table", header=TRUE, stringsAsFactors=FALSE);
total_area=sum(df$main_rr_contact__area);
df$area_expected_to_vanish=(df$main_rr_contact__area*(1-df$predicted_probability_to_persist));
df$area_expected_to_persist=(df$main_rr_contact__area*(0+df$predicted_probability_to_persist));
df$bounded_probabilities=df$predicted_probability_to_persist;
df$bounded_probabilities[which(df$predicted_probability_to_persist<0.005)]=0.005;
df$bounded_probabilities[which(df$predicted_probability_to_persist>0.995)]=0.995;
df$area_badness=(df$main_rr_contact__area*log(df$bounded_probabilities));
df$area_goodness=(df$main_rr_contact__area*log(1.0-df$bounded_probabilities));
df$area_pseudoenergy=(df$area_goodness-df$area_badness);
df$exposure_value=(df$main_rr_contact__boundary)/sqrt(df$main_rr_contact__area);

total_area=sum(df$main_rr_contact__area);
total_area_expected_to_vanish=sum(df$area_expected_to_vanish);
total_area_expected_to_persist=sum(df$area_expected_to_persist);
total_area_pseudoenergy=sum(df$area_pseudoenergy);
total_area_badness=sum(df$area_badness);
total_area_goodness=sum(df$area_goodness);
ordering_by_exposure_value=order(0-df$exposure_value);
ordered_exposure_values=df$exposure_value[ordering_by_exposure_value];
ordered_area_pseudoenergies=df$area_pseudoenergy[ordering_by_exposure_value];
ordered_areas=df$main_rr_contact__area[ordering_by_exposure_value];
N=length(ordered_exposure_values);
M=max(1, length(which(ordered_exposure_values>0)));
subtotal_area_pseudoenergies=rep(0, M);
subtotal_areas=rep(0, M);
for(i in 1:M)
{
	subtotal_area_pseudoenergies[i]=sum(ordered_area_pseudoenergies[i:N]);
	subtotal_areas[i]=sum(ordered_areas[i:N]);
}
best_core_index=order(subtotal_area_pseudoenergies)[1];
best_core_area_pseudoenergy=subtotal_area_pseudoenergies[best_core_index];
best_core_area=subtotal_areas[best_core_index];
result=data.frame(ID=idvalue, modified=inputmodifications, pseudoenergy=total_area_pseudoenergy, area=total_area, best_core_pseudoenergy=best_core_area_pseudoenergy, best_core_area=best_core_area);

df$area=df$main_rr_contact__area;
df$boundary=df$main_rr_contact__boundary;
sdf1=df[,c("area_pseudoenergy", "area", "area_expected_to_persist", "area_goodness", "boundary")];
sdf2=sdf1;
sdf1$chain=df$chain1;
sdf1$seqnum=df$seqnum1;
sdf1$resname=df$resname1;
sdf2$chain=df$chain2;
sdf2$seqnum=df$seqnum2;
sdf2$resname=df$resname2;
sdf=rbind(sdf1, sdf2);
sdf_summarized=aggregate(. ~ chain + seqnum + resname, data=sdf, FUN=sum);
sdf_summarized=sdf_summarized[order(sdf_summarized$area_pseudoenergy),];
write.table(sdf_summarized, file="table_per_residue", row.names=FALSE, col.names=TRUE, quote=FALSE, sep="\t");

sdf=df[,c("chain1", "seqnum1", "resname1", "chain2", "seqnum2", "resname2", "area_pseudoenergy", "area", "boundary", "predicted_probability_to_persist")]
sdf=sdf[order(sdf$area_pseudoenergy),];
write.table(sdf, file="table_per_contact", row.names=FALSE, col.names=TRUE, quote=FALSE, sep="\t");

interchain_sel=which(df$chain1!=df$chain2);
interchain_sel_size=length(interchain_sel);

if(interchain_sel_size==nrow(df)) {
	result$ic_fraction=1;
} else if(interchain_sel_size>0 && interchain_sel_size<nrow(df)) {
	df=df[interchain_sel,];
	result$ic_fraction=sum(df$main_rr_contact__area)/result$area;
	result$ic_area_pseudoenergy=sum(df$area_pseudoenergy);
	result$ic_area_total=sum(df$main_rr_contact__area);
	ordering_by_exposure_value=order(0-df$exposure_value);
	ordered_exposure_values=df$exposure_value[ordering_by_exposure_value];
	ordered_area_pseudoenergies=df$area_pseudoenergy[ordering_by_exposure_value];
	ordered_areas=df$main_rr_contact__area[ordering_by_exposure_value];
	N=length(ordered_exposure_values);
	M=max(1, length(which(ordered_exposure_values>0)));
	subtotal_area_pseudoenergies=rep(0, M);
	subtotal_areas=rep(0, M);
	for(i in 1:M)
	{
		subtotal_area_pseudoenergies[i]=sum(ordered_area_pseudoenergies[i:N]);
		subtotal_areas[i]=sum(ordered_areas[i:N]);
	}
	best_core_index=order(subtotal_area_pseudoenergies)[1];
	result$ic_best_core_pseudoenergy=subtotal_area_pseudoenergies[best_core_index];
	result$ic_best_core_area=subtotal_areas[best_core_index];
} else {
	result$ic_fraction=0;
}

write.table(result, file="summary", row.names=FALSE, col.names=TRUE, quote=FALSE, sep="\t");


