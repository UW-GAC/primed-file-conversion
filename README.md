# primed-file-conversion

PRIMED file conversion workflows

## plink2_bed2vcf

This workflow uses [plink2](https://www.cog-genomics.org/plink/2.0/) to convert a file from binary PLINK format (bed/bim/fam) to VCF.

If using a fasta file, run the workflow with [reference disks enabled](https://support.terra.bio/hc/en-us/articles/360056384631).

Inputs:

input | description
--- | ---
bed_file | plink bed file
bim_file | plink bim file
fam_file | plink fam file
snps_only | boolean for whether to filter output file to SNPs only
chr_prefix | boolean for whether to add a 'chr' prefix, e.g. chr1, chr2, chrX vs 1, 2, X
fasta_file | (optional) fasta file. If provided, plink2 attempts to assign ref and alt alleles according to the reference genome.
out_prefix | (optional) prefix for output vcf file. If not provided, taken from the input bed filename.

Outputs:

output | description
--- | ---
out_file | VCF file


## liftover_vcf

This workflow uses [GATK Picard](https://gatk.broadinstitute.org/hc/en-us/articles/9570440033179-LiftoverVcf-Picard-) to lift over VCF files from one build to another. Run the workflow with [reference disks enabled](https://support.terra.bio/hc/en-us/articles/360056384631).

[Human genome reference builds](https://gatk.broadinstitute.org/hc/en-us/articles/360035890951)

[Build 37 vs hg19 explained](https://gatk.broadinstitute.org/hc/en-us/articles/360035890711-GRCh37-hg19-b37-humanG1Kv37-Human-Reference-Discrepancies)

[Reference fasta files on Google Cloud Storage](https://console.cloud.google.com/storage/browser/genomics-public-data/references)

Chain files:

- [hg17 to hg38](https://hgdownload.soe.ucsc.edu/goldenPath/hg17/liftOver/hg17ToHg38.over.chain.gz)
- [hg18 to hg38](https://hgdownload.cse.ucsc.edu/goldenpath/hg18/liftOver/hg18ToHg38.over.chain.gz)
- [hg19 to hg38](https://hgdownload.cse.ucsc.edu/goldenpath/hg19/liftOver/hg19ToHg38.over.chain.gz)
- [b37 to hg38](https://raw.githubusercontent.com/broadinstitute/gatk/master/scripts/funcotator/data_sources/gnomAD/b37ToHg38.over.chain)


Inputs:

input | description
--- | ---
vcf_file | VCF file
chain_url | URL for chain file
target_fasta | fasta file with referce sequence for target build
out_prefix | prefix for output file (.vcf.gz will be appended)

Outputs:

output | description
--- | ---
out_file | VCF file with coordinates in target build
rejects_file | VCF file with variants that could not be lifted over
