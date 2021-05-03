# biPheMap
The biPheMap R shiny app allows the exploration of a phenome-wide network map of colocalized genes and phenotypes from the UK Biobank project in 48 tissues of the GTEx project.
We performed three steps to create the biPheMap: 
1) Identification of colocalization signals of eQTL and GWAS loci for 1,411 phenotypes from UK Biobank across 48 tissues of the GTEX project
2) Construction of a bipartite network using the colocalization signals to establish links between genes and phenotypes in each tissue; and 
3) Identification of co-clusters of specific colocalized genes and phenotypes in each tissue-level bipartite network using the biLouvain clustering algorithm.

The biPheMap R shiny app is accessible at : https://rstudio-connect.hpc.mssm.edu/biPheMap/

<h2>Reference</h2>
G Rocheleau et al. 2021. A tissue-level phenome-wide network map of colocalized genes and phenotypes in the UK Biobank. bioRxiv doi: https://doi.org/10.1101/2021.04.30.441974

<h2>Datasets</h2>
<ul>
  <li>UK Biobank (UKBB) https://www.ukbiobank.ac.uk/</li> 
  The UKBB project is a prospective EHR-linked cohort with deep genetic and rich phenotypic data collected on approximately 500,000 middle-aged individuals (aged between 40 and 69 years old) recruited from across the United Kingdom.
  <li>Genotype-Tissue Expression (GTEx)  https://gtexportal.org/home/ </li>
  The GTEx project is a resource database and associated multi-tissue bank aimed at studying the relationship between genetic variation and gene expression in different human tissues.
</ul>

<h2>Colocalization method</h2>
We integrated multiple association datasets to assess whether two association signals, one from a genome-wide association study (GWAS) on a phenotype, and the other from expression quantitative trait locus (eQTL) analysis in a tissue, overlap in such a matter that they are consistent with a shared causal gene. This approach, referred to as colocalization, was conducted using coloc2 (https://github.com/Stahl-Lab-MSSM).
The coloc2 method is a Bayesian approach which computes the posterior probability that a genetic variant is both associated with the phenotype and the gene expression level in the tissue. We defined a colocalized signal using PPH4 <span>&#8805;</span> 0.80. 


<h2>GWAS and eQTL summary statistics</h2>

coloc2 requires both GWAS summary data and eQTL association summary data. For GWAS data, we used two sets from the UKBB project. The first set of results are GWAS association test statistics publicly available from the Neale lab (Round 1 in 2,419 phenotypes) (http://www.nealelab.is/uk-biobank). We selected variants with minor allele frequency (MAF) > 0.1% and with association p-value < 5x10<sup>-5</sup>. We further used a second set of UKBB GWAS association statistics computed by the SAIGE testing method. In total, 1,403 case-control phenotypes (PheCodes) were available (https://www.leelabsg.org/resources). We selected variants with MAF > 0.1% and with association p-value < 5x10<sup>-3</sup>. For eQTL association signals, we used data from release V7 of the GTEx project. We restricted our study to the list of 48 tissues (from 620 donors) having a sample size of at least 80. eQTLs with MAF > 1% were considered as input for coloc2. Statistically significant cis-eQTLs were selected as detailed on the GTEx project website (https://storage.googleapis.com/gtex-public-data/Portal_Analysis_Methods_v7_09052017.pdf). <br>
After further quality control (see G Rocheleau et al. 2021. A tissue-level phenome-wide network map of colocalized genes and phenotypes in the UK Biobank. bioRxiv doi: https://doi.org/10.1101/2021.04.30.441974 ), we retained coloc2 results for 496 continuous and binary phenotypes with the Neale GWAS data. With SAIGE data, we generated coloc2 results for 915 case-control (PheCode) phenotypes. In total, the biPheMap contains colocalized signals from 9,151 genes and 1,411 phenotypes across 48 tissues.

<h2>Construction of bipartite networks</h2>

We created a bipartite network for each tissue. In brief, a bipartite network, also called a two-mode network, is a network in which nodes of one mode (i.e. type) are only connected to nodes of the other mode. Associations between phenotypes and genes are indicated by links or edges between them. 

<h2>biLouvain clustering algorithm</h2>

For each tissue, it is expected that the bipartite network of coloc2 results will tend to “cluster” in small groups of related phenotypes with their causally associated genes. To uncover clustering within each network, we applied a newly proposed clustering algorithm, called biLouvain, which extends the well-known unipartite Louvain clustering algorithm. This new algorithm efficiently identifies co-clusters, also called communities, of non-overlapping genes and phenotypes by maximizing a bipartite modularity measure (https://github.com/paolapesantez/biLouvain).

<h2>How to explore the biPheMap</h2>
The biPheMap app allows you to explore the colocalization signals and the content of each co-cluster identified by the biLouvain algorithm in each tissue-level set of colocalized genes and phenotypes. For example, you can search for either a specific gene (or phenotype) and biPheMap will indicate in which co-cluster this gene (or phenotype) appears, along with its co-cluster’s “mates”. Remember that a gene can only be directly linked to phenotypes, and indirectly (through shared phenotypes) to other genes. The same applies to phenotypes. Depending on the colocalization signals across the 48 tissues, a specific gene or phenotype may appear in one tissue or in many tissues. Also, note that the co-cluster’s ID number does not mean anything; it only helps to keep track of the co-cluster at the tissue level.

You can also generate a network plot of your selection: for all genes and phenotypes included in your selection, links (or edges) indicate a colocalized signal between a gene and a phenotype in the corresponding tissue (but don’t expect to see all genes and phenotypes linked in your selection). If your selection is a co-cluster, remember that, since the clustering is performed at the tissue level, a gene or a phenotype will only appear in one co-cluster for a given tissue (if that gene or phenotype is colocalized in that specific tissue). 

Prefixes “N_” and “S_” in phenotype names indicate “Neale GWAS phenotypes” and “SAIGE GWAS phenotypes”, respectively. To facilitate the reading of network plots, we added an extra column (hidden, by default) which displays the corresponding abbreviation of some phenotypes.
