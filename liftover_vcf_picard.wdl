version 1.0

workflow liftover_vcf {
    input {
        File vcf_file
        String chain_url
        File target_fasta
        String out_prefix
    }

    call results {
        input: vcf_file = vcf_file,
               chain_url = chain_url,
               target_fasta = target_fasta,
               out_prefix = out_prefix
    }

    output {
        File out_file = results.out_file
        File rejects_file = results.rejects_file
    }

     meta {
          author: "Stephanie Gogarten"
          email: "sdmorris@uw.edu"
    }
}

task results {
    input {
        File vcf_file
        String chain_url
        File target_fasta
        String out_prefix
    }

    String chain_file = basename(chain_url)

    command {
        curl ${chain_url} --output ${chain_file}
        java -jar /usr/picard/picard.jar CreateSequenceDictionary \
            --REFERENCE ${target_fasta}
        java -jar /usr/picard/picard.jar LiftoverVcf \
            --CHAIN ${chain_file} \
            --INPUT ${vcf_file} \
            --OUTPUT ${out_prefix}.vcf.gz \
            --REJECT rejected_variants.vcf.gz \
            --REFERENCE_SEQUENCE ${target_fasta} \
            --RECOVER_SWAPPED_REF_ALT true \
            --ALLOW_MISSING_FIELDS_IN_HEADER true
    }

    output {
        File out_file = "${out_prefix}.vcf.gz"
        File rejects_file = "rejected_variants.vcf.gz"
    }

    runtime {
        docker: "broadinstitute/picard:2.27.5"
        memory: "30GB"
    }
}
