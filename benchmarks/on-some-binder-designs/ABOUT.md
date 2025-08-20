# Analyzing binders

Let's analyze three AF2 models of protein-protein complexes with designed dinders in the [input directory](./input/).

We can run VoroMarmotte to get both global and inter-chain (ic_...) scores using a single command.
Let's tell VoroMarmotte to rebuild sidechains using FASPR, and let's consider only contacts involving the binder (chain A).

```bash
voromarmotte \
  --input _list \
  --rebuild-sidechains "true" \
  --subselect-contacts '[-a1 [-chain A]]' \
  --processors 3
```
This produces the following table:

```
ID           modified  pseudoenergy       area        best_core_pseudoenergy  best_core_area  ic_fraction        ic_area_pseudoenergy  ic_area_total  ic_best_core_pseudoenergy  ic_best_core_area
design1.pdb  rebuilt   -11813.9722991064  9349.44412  -12266.8995239934       9044.61393      0.132961795807813  -420.463304133614     1243.11888     -716.134367071212          855.5979
design2.pdb  rebuilt   -9067.31752791254  7375.05497  -9778.55923677698       6420.20767      0.187249405681379  -314.330967450795     1380.97466     -886.625170037865          688.60385
design3.pdb  rebuilt   -233.510567837784  2956.76683  -1397.72679239948       1608.50955      0.426185899143085  609.733732775186      1260.13233     -395.251204376632          490.54953
```

The 'best_core_...' values show what scores can theoretically be achieved if sort the contact areas by their exposure to solvent and start removing them starting from the most exposed ones until we get the minimum pseudoenergy. Such 'best_core_...' values indicate how the 'rim' of contacts affect the overall stability and whether there is any potential for the improvement of pseudoenergy by mutating rim-involved parts.

Now, let us mutate every interface residue in to other 19 residues, rebuild the sidechains and score every mutant:

```bash
find ./input/ -type f -name '*.pdb' \
| voromarmotte \
  --input _list \
  --subselect-contacts '[-a1 [-chain A]]' \
  --mutate-sidechains 'interface-A-every' \
  --output-table-file "./output/global_scores_mutated_to_every.txt" \
  --processors 20
```

We can look at the produces table [here](./output/global_scores_mutated_to_every.txt).
2283 mutants were generated and scored. The first several line of the generated table are shown below:

```
ID           modified                   pseudoenergy       area        best_core_pseudoenergy  best_core_area  ic_fraction        ic_area_pseudoenergy  ic_area_total  ic_best_core_pseudoenergy  ic_best_core_area
design1.pdb  rebuilt_mutated_A_27_GLY   -12532.544176569   9367.67309  -12985.2028334516       9062.8429       0.133084328202149  -540.005816817273     1246.69048     -824.878094680257          859.1695
design1.pdb  rebuilt_mutated_A_27_ARG   -12448.6172465226  9297.47381  -12908.8653621068       8988.81033      0.133514850954982  -491.960887336692     1241.35083     -780.605581814033          869.48066
design1.pdb  rebuilt_mutated_A_27_ALA   -12428.673593631   9366.84161  -12881.3322505135       9062.01142      0.133096141891525  -530.230263921967     1246.69048     -816.691134365796          859.1695
design1.pdb  rebuilt_mutated_A_27_PRO   -12426.0230765351  9369.46373  -12878.6817334176       9064.63354      0.133090649148604  -515.298160375183     1246.98801     -811.230200543186          859.46703
design1.pdb  rebuilt_mutated_A_27_CYS   -12322.5990235994  9364.44278  -12775.2576804819       9059.61259      0.133130236287268  -493.932377099462     1246.69048     -791.134114847541          859.1695
design1.pdb  rebuilt_mutated_A_27_LEU   -12319.7033316581  9365.61485  -12772.3619885406       9060.78466      0.133032677507553  -492.479868192099     1245.93282     -777.120511795507          858.41184
design1.pdb  rebuilt_mutated_A_27_GLN   -12303.9917653754  9351.51406  -12755.4799568548       9046.68387      0.132901264118936  -531.686845657497     1242.82804     -807.702003922186          855.30706
design1.pdb  rebuilt_mutated_A_230_ARG  -12264.3747575616  9345.28512  -12718.28394953         9040.45493      0.133277717480705  -411.600803055038     1245.51827     -717.29330615377           857.99729
design1.pdb  rebuilt_mutated_A_27_GLU   -12253.8821521805  9350.03239  -12705.3703436599       9045.2022       0.132930967311868  -526.256445001715     1242.90885     -803.843027627608          855.38787
design1.pdb  rebuilt_mutated_A_27_ILE   -12192.1209773653  9366.95925  -12645.1842736404       9062.12906      0.132983983035904  -465.200339758337     1245.65555     -750.779403334788          858.13457
design1.pdb  rebuilt_mutated_A_161_PHE  -12188.3466741662  9346.75507  -12576.451219694        9052.99577      0.131885829977141  -531.963967549193     1232.70455     -759.518574966276          855.16251
````

On a single machine this "mutational scanning" can take several hours, so using a CPU cluster may be a good idea.
Instead of specifying `--mutate-sidechains 'interface-A-every'`,
we can mutate and score just one residue, e.g. `--mutate-sidechains 'A 74 TYR'` means that residue number 74 in chain A will be change.
We can also specify multiple mutations one after another, e.g. `--mutate-sidechains 'A 74 TYR A 108 PHE'`.
We can also mutate every chain A interface residue to a specific residue, e.g. `--mutate-sidechains 'interface-A-PHE'`.
So, to run on a cluster, we can list all the mutations we need and consider them in parallel.

When we have the `global_scores_mutated_to_every.txt` table, we can use the [suggest-mutations-to-increase-binding-stability](../../meta/suggest-mutations-to-increase-binding-stability) script to generate priority-ranked multi-point mutations for every input structure file, for example:

```bash
suggest-mutations-to-increase-binding-stability \
  --input-table "./output/global_scores_mutated_to_every.txt" \
  --file-id "./input/desing2.pdb" \
  --output-dir "./output/suggested_mutations_to_increase_binding_stability/design2"
```

This command generates multiple files in the provided directory path.
Firstly, the priority-sorted table of single-point mutations (e.g. [here](./output/suggested_mutations_to_increase_binding_stability/design2/mutations_table.tsv)). Secondly, the plot based on that table:

![](./output/suggested_mutations_to_increase_binding_stability/design2/plot_of_ordered_mutations.png)

Most importantly, `suggest-mutations-to-increase-binding-stability` generates ordered list of multi-point mutations that involve the best-scored single-point mutations.
The generated "mutation requests" file can be viewed [here](./output/suggested_mutations_to_increase_binding_stability/design2/multiple_mutation_requests.txt), its several lines are presented below:

```
./input/design2.pdb A_76_LEU_A_123_ALA
./input/design2.pdb A_136_TRP_A_63_ARG
./input/design2.pdb A_123_GLN_A_63_ARG
./input/design2.pdb A_76_LYS_A_63_ARG
./input/design2.pdb A_76_LEU_A_63_ARG
./input/design2.pdb A_123_ALA_A_63_ARG
./input/design2.pdb A_76_TYR_A_104_ARG_A_63_ASP
./input/design2.pdb A_76_TYR_A_104_ARG_A_71_TYR
./input/design2.pdb A_76_TYR_A_104_ARG_A_136_TRP
./input/design2.pdb A_76_TYR_A_104_ARG_A_123_GLN
./input/design2.pdb A_76_TYR_A_63_ASP_A_71_TYR
./input/design2.pdb A_76_TYR_A_63_ASP_A_136_TRP
```

This file can be directly submitted to the VoroMarmotte application:

```bash
cat "./output/suggested_mutations_to_increase_binding_stability/design2/multiple_mutation_requests.txt" \
| ../../voromarmotte \
  --input _list \
  --mutate-sidechains '_list' \
  --subselect-contacts '[-a1 [-chain A]]' \
  --processors 20
```

which mutates and scores complexes and produces a standard VoroMarmotte output table - see the full file [here](./output/suggested_mutations_to_increase_binding_stability/design2/global_scores_mutated_multiple.txt) and the first several lines below:

```
ID           modified                                      pseudoenergy       area        best_core_pseudoenergy  best_core_area  ic_fraction        ic_area_pseudoenergy  ic_area_total  ic_best_core_pseudoenergy  ic_best_core_area
design2.pdb  rebuilt_mutated_A_76_TYR_A_71_TYR_A_123_GLN   -9906.65455364476  7371.65063  -10480.6217901057       6410.4934       0.185967407953516  -790.263243241097     1370.88676     -1149.81401409809          725.20501
design2.pdb  rebuilt_mutated_A_76_TYR_A_71_TYR_A_136_TRP   -9880.15465854005  7422.9077   -10506.9070354839       6498.73001      0.191811446072541  -805.950747776795     1423.79866     -1212.20238875045          740.06047
design2.pdb  rebuilt_mutated_A_76_TYR_A_123_GLN_A_63_ARG   -9874.4423934453   7390.07824  -10448.0303433313       6426.40861      0.185868684388922  -766.812080428769     1373.58412     -1129.27855018122          723.79085
design2.pdb  rebuilt_mutated_A_76_PHE_A_71_TYR_A_123_GLN   -9856.37393844124  7364.2325   -10434.8023313709       6403.05367      0.184717194901166  -744.509634626522     1360.30037     -1105.04428984827          714.59822
design2.pdb  rebuilt_mutated_A_76_TYR_A_63_ASP_A_123_GLN   -9849.42563733167  7309.20334  -10437.112276623        6349.26664      0.185096990337664  -830.281648699138     1352.91154     -1156.59858912356          909.07515
design2.pdb  rebuilt_mutated_A_76_TYR_A_136_TRP_A_63_ARG   -9847.9947298072   7441.33531  -10474.367820176        6514.64522      0.191698930443708  -782.529668896772     1426.49602     -1191.69700876588          738.64631
design2.pdb  rebuilt_mutated_A_76_TYR_A_71_TYR_A_123_ALA   -9839.68371572134  7349.21623  -10433.2505180718       6376.51617      0.186354813511862  -797.880453479317     1369.56182     -1134.05974109433          913.80431
```

Interestingly, mutations have improved the inter-chain VoroMarmotte scores significantly compared to the non-mutated scoring result shown below:

```
ID           modified                   pseudoenergy       area        best_core_pseudoenergy  best_core_area  ic_fraction        ic_area_pseudoenergy  ic_area_total  ic_best_core_pseudoenergy  ic_best_core_area
design2.pdb  rebuilt                    -9067.31718589444  7375.05497  -9778.55886269862       6420.20767      0.187249405681379  -314.33106087528      1380.97466     -886.625228336165          688.60385
```

Also interestingly, the interface in `design2.pdb` was improved more then the inerface in `design1.pdb` that was initially assessed to be better.
Below are the scores of the best found mutations for those designs:

```
ID           modified                                      pseudoenergy       area        best_core_pseudoenergy  best_core_area  ic_fraction        ic_area_pseudoenergy  ic_area_total  ic_best_core_pseudoenergy  ic_best_core_area
design2.pdb  rebuilt_mutated_A_76_TYR_A_71_TYR_A_123_GLN   -9906.65455364476  7371.65063  -10480.6217901057       6410.4934       0.185967407953516  -790.263243241097     1370.88676     -1149.81401409809          725.20501
design1.pdb  rebuilt_mutated_A_27_GLY_A_161_PHE            -12906.9189975958  9364.98404  -13294.7549612756       9071.22474      0.132010491926049  -651.506606215465     1236.27615     -868.262458962567          858.73411
```

We can also run VoroMarmotte to generate files to visualize the interface the most interesting mutants, for example:

```bash
voromarmotte \
  --input "./input/design2.pdb" \
  --mutate-sidechains "A_76_TYR_A_71_TYR_A_123_GLN" \
  --subselect-contacts '[-inter-chain]' \
  --output-vscript "show.vs" \
  --output-pymol-vscript "show.py" \
  --output-atoms-file "mutant_atoms.pdb" \
> "interface_scores.txt"
```

Below are `design2.pdb` interfaces before and after the mutations, colored by pseudoenergy (blue for negative (good), red for positive (bad):

![](./output/suggested_mutations_to_increase_binding_stability/design2/colored_interfaces.png)

Obviosly, we cannot expect to turn every contact blue with just three mutations - more mutations can help, althoug we probably must be cautious to not break the structure with them.

