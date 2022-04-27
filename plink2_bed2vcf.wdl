version 1.0

workflow plink2_bed2vcf {
    input {
        File bed_file
        File bim_file
        File fam_file
        File? fasta_file
        String? out_prefix
    }

    call results {
        input: bed_file = bed_file,
               bim_file = bim_file,
               fam_file = fam_file,
               fasta_file = fasta_file,
               out_prefix = out_prefix
    }

    output {
        File out_file = results.out_file
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
    }

    String fasta_string = if defined(fasta_file) then "--ref-from-fa --fa " + fasta_file else ""
    String out_string = if defined(out_prefix) then out_prefix else basename(bed_file, ".bed")

    command {
        /plink2 \
            --bed ${bed_file} \
            --bim ${bim_file} \
            --fam ${fam_file} \
            --make-pgen --sort-vars \
            --out sorted
        /plink2 \
            --pfile sorted \
            --export vcf id-paste=iid bgz ${fasta_string} \
            --out ${out_string}
        rm sorted.*
    }

    output {
        File out_file = "${out_string}.vcf.gz"
    }

    runtime {
        docker: "quay.io/large-scale-gxe-methods/plink2-workflow:latest"
    }
}
