version 1.0

workflow plink2_bed2vcf {
    input {
        File bed_file
        File bim_file
        File fam_file
        File? fasta_file
        String? out_prefix
        Boolean snps_only
        Boolean chr_prefix
    }

    call results {
        input: bed_file = bed_file,
               bim_file = bim_file,
               fam_file = fam_file,
               fasta_file = fasta_file,
               out_prefix = out_prefix,
               snps_only = snps_only,
               chr_prefix = chr_prefix
    }

    output {
        File out_file = results.out_file
        String md5sum = results.md5sum
    }

     meta {
          author: "Stephanie Gogarten"
          email: "sdmorris@uw.edu"
     }
}

task results {
    input {
        File bed_file
        File bim_file
        File fam_file
        File? fasta_file
        String? out_prefix
        Boolean snps_only
        Boolean chr_prefix
    }

    String out_string = if defined(out_prefix) then out_prefix else basename(bed_file, ".bed")

    command {
        plink2 \
            --bed ${bed_file} \
            --bim ${bim_file} \
            --fam ${fam_file} \
            --make-pgen \
	    --merge-x \
	    --sort-vars ${true="--snps-only 'just-acgt'" false="" snps_only} \
            --out sorted
        plink2 \
            --pfile sorted \
            --export vcf id-paste=iid bgz ${"--ref-from-fa --fa " + fasta_file} \
            --out ${out_string} ${true="--output-chr chrM" false="" chr_prefix}
        rm sorted.*
        md5sum ${out_string}.vcf.gz | cut -d " " -f 1 > md5.txt
    }

    output {
        File out_file = "${out_string}.vcf.gz"
        String md5sum = read_string("md5.txt")
    }

    runtime {
        docker: "uwgac/plink2:20220814"
    }
}
