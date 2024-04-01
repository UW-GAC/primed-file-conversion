# primed-file-conversion

PRIMED file conversion workflows

## plink2_bed2vcf

This workflow uses [plink2](https://www.cog-genomics.org/plink/2.0/) to convert a file from binary PLINK format (bed/bim/fam) to VCF.

Default behavior is to output SNPs only, omitting any "I/D" codes for indels, as these are not accepted by downstream workflows such as liftover and imputation. 

Any pseudoautomsomal SNPs ('XY' code) will be merged with the X chromosome using plink2's "merge-x" option. The default is to add 'chr' prefixes to chromosome codes, as this is the standard for hg19 and hg38 and facilitates using UCSC chain files for liftover.

If using a fasta file, run the workflow with [reference disks enabled](https://support.terra.bio/hc/en-us/articles/360056384631).

Inputs:

input | description
--- | ---
bed_file | plink bed file
bim_file | plink bim file
fam_file | plink fam file
snps_only | (optional, default true) boolean for whether to filter output file to SNPs only
chr_prefix | (optional, default true) boolean for whether to add a 'chr' prefix, e.g. chr1, chr2, chrX vs 1, 2, X
fasta_file | (optional) fasta file. If provided, plink2 attempts to assign ref and alt alleles according to the reference genome.
out_prefix | (optional) prefix for output vcf file. If not provided, taken from the input bed filename.

Outputs:

output | description
--- | ---
out_file | VCF file
md5sum | md5 checksum of out_file


## plink2_pgen2bed

This workflow uses [plink2](https://www.cog-genomics.org/plink/2.0/) to convert a file from PLINK2 format (pgen/pvar/psam) to binary PLINK format (bed/bim/fam).

Inputs:

input | description
--- | ---
pgen | plink2 pgen file
pvar | plink2 pvar file
psam | plink2 psam file
out_prefix | (optional) prefix for output bed/bim/fam files. If not provided, taken from the input pgen filename.

Outputs:

output | description
--- | ---
out_bed | bed file
out_bim | bim file
out_fam | fam file
md5sum | md5 checksums of out_bed, out_bim, out_fam


## plink2_pgen2vcf

This workflow uses [plink2](https://www.cog-genomics.org/plink/2.0/) to convert a file from PLINK2 format (pgen/pvar/psam) to VCF.

Inputs:

input | description
--- | ---
pgen | plink2 pgen file
pvar | plink2 pvar file
psam | plink2 psam file
out_prefix | (optional) prefix for output bed/bim/fam files. If not provided, taken from the input pgen filename.

Outputs:

output | description
--- | ---
out_file | VCF file
md5sum | md5 checksum of out_file


## plink2_vcf2bed

This workflow uses [plink2](https://www.cog-genomics.org/plink/2.0/) to convert a file from Variant Call Format (VCF) to binary PLINK format (bed/bim/fam).

Inputs:

input | description
--- | ---
vcf_file | vcf file
out_prefix | (optional) prefix for output bed/bim/fam files. If not provided, taken from the input vcf filename.

Outputs:

output | description
--- | ---
out_bed | bed file
out_bim | bim file
out_fam | fam file
md5sum | md5 checksums of out_bed, out_bim, out_fam


## plink2_vcf2pgen

This workflow uses [plink2](https://www.cog-genomics.org/plink/2.0/) to convert a file from Variant Call Format (VCF) to binary PLINK2 format (pgen/pvar/psam).

Inputs:

input | description
--- | ---
vcf_file | vcf file
out_prefix | (optional) prefix for output bed/bim/fam files. If not provided, taken from the input vcf filename.

Outputs:

output | description
--- | ---
out_pgen | pgen file
out_pvar | pvar file
out_psam | psam file
md5sum | md5 checksums of out_pgen, out_pvar, out_psam


## liftover_vcf

This workflow uses [GATK Picard](https://gatk.broadinstitute.org/hc/en-us/articles/9570440033179-LiftoverVcf-Picard-) to lift over VCF files from one build to another. Run the workflow with [reference disks enabled](https://support.terra.bio/hc/en-us/articles/360056384631).

After Picard is run, a strand flip (using plink v1.9 --flip) will be run on the rejected SNPs and liftover will be re-tried. Any SNPs successfully lifted over after the strand flip will be merged with the prior lifted file.

[Human genome reference builds](https://gatk.broadinstitute.org/hc/en-us/articles/360035890951)

[Build 37 vs hg19 explained](https://gatk.broadinstitute.org/hc/en-us/articles/360035890711-GRCh37-hg19-b37-humanG1Kv37-Human-Reference-Discrepancies)

[Reference fasta files on Google Cloud Storage](https://console.cloud.google.com/storage/browser/genomics-public-data/references)

Chain files:

- [hg17 to hg38](https://hgdownload.soe.ucsc.edu/goldenPath/hg17/liftOver/hg17ToHg38.over.chain.gz)
- [hg18 to hg38](https://hgdownload.cse.ucsc.edu/goldenpath/hg18/liftOver/hg18ToHg38.over.chain.gz)
- [hg19 to hg38](https://hgdownload.cse.ucsc.edu/goldenpath/hg19/liftOver/hg19ToHg38.over.chain.gz)
- [b37 to hg38](https://raw.githubusercontent.com/broadinstitute/gatk/master/scripts/funcotator/data_sources/gnomAD/b37ToHg38.over.chain) - use this file if the input contigs omit the 'chr' prefix


Inputs:

input | description
--- | ---
vcf_file | VCF file
chain_url | URL for chain file
target_fasta | fasta file with referce sequence for target build
out_prefix | prefix for output file (.vcf.gz will be appended)
mem_gb | (optional, default 16 GB) RAM required for liftover. If the job fails due to lack of memory, try setting this to a larger value.

Outputs:

output | description
--- | ---
out_file | VCF file with coordinates in target build
md5sum | md5 checksum of out_file
rejects_file | VCF file with variants that could not be lifted over
num_rejects | number of variants in the rejects file
