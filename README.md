# primed-file-conversion

PRIMED file conversion workflows

## plink2_bed2vcf

This workflow uses [plink2](https://www.cog-genomics.org/plink/2.0/) to convert a file from binary PLINK format (bed/bim/fam) to VCF.

Inputs:

input | description
--- | ---
bed_file | plink bed file
bim_file | plink bim file
fam_file | plink fam file
fasta_file | (optional) fasta file. If provided, plink2 attempts to assign ref and alt alleles according to the reference genome.
out_prefix | (optional) prefix for output vcf file. If not provided, taken from the input bed filename.

Outputs:

output | description
--- | ---
out_file | VCF file
