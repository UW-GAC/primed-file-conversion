version 1.0

workflow convert_build {
    input {
        File vcf_file
        File chain_file
        File fasta_file
        String out_prefix
    }

    call results {
        input: vcf_file = vcf_file,
               chain_file = chain_file,
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
        File vcf_file
        File chain_file
        File fasta_file
        String out_prefix
    }

    command {
        CrossMap.py vcf ${chain_file} ${vcf_file} ${fasta_file} ${out_prefix}.vcf
    }

    output {
        File out_file = "${out_prefix}.vcf"
    }

    runtime {
        docker: "quay.io/shukwong/plinkcrossmap:v1"
    }
}
