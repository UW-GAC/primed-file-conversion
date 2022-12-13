version 1.0

workflow liftover_vcf {
    input {
        File vcf_file
        String chain_url
        File target_fasta
        String out_prefix
        Int? mem_gb
    }

    call picard {
        input: vcf_file = vcf_file,
               chain_url = chain_url,
               target_fasta = target_fasta,
               out_prefix = out_prefix,
               mem_gb = mem_gb
    }

    call strand_flip {
        input: vcf_file = picard.out_file,
               rejects_file = picard.rejects_file,
               out_prefix = out_prefix
    }

    call picard as picard2 {
        input: vcf_file = strand_flip.out_file,
               chain_url = chain_url,
               target_fasta = target_fasta,
               out_prefix = out_prefix,
               mem_gb = mem_gb
    }

    if (picard2.num_rejects < picard.num_rejects) {
        call merge_vcf {
            input: vcf_files = [picard.out_file, picard2.out_file],
                   out_prefix = out_prefix
        }
    }

    output {
        File out_file = select_first([merge_vcf.out_file, picard.out_file])
        File rejects_file = picard2.rejects_file
        Int num_rejects = picard2.num_rejects
    }

     meta {
          author: "Stephanie Gogarten"
          email: "sdmorris@uw.edu"
    }
}


task picard {
    input {
        File vcf_file
        String chain_url
        File target_fasta
        String out_prefix
        Int mem_gb = 16
    }

    String chain_file = basename(chain_url)

    command <<<
        curl ~{chain_url} --output ~{chain_file}
        java -Xmx~{mem_gb}g -jar /usr/picard/picard.jar CreateSequenceDictionary \
            --REFERENCE ~{target_fasta}
        java -Xmx~{mem_gb}g -jar /usr/picard/picard.jar LiftoverVcf \
            --CHAIN ~{chain_file} \
            --INPUT ~{vcf_file} \
            --OUTPUT ~{out_prefix}.vcf.gz \
            --REJECT rejected_variants.vcf.gz \
            --REFERENCE_SEQUENCE ~{target_fasta} \
            --RECOVER_SWAPPED_REF_ALT true \
            --ALLOW_MISSING_FIELDS_IN_HEADER true \
            --MAX_RECORDS_IN_RAM 10000
        zcat rejected_variants.vcf.gz | grep -v "^#" | wc -l > num_rejects.txt
    >>>

    output {
        File out_file = "~{out_prefix}.vcf.gz"
        File rejects_file = "rejected_variants.vcf.gz"
        Int num_rejects = read_int("num_rejects.txt")
    }

    runtime {
        docker: "broadinstitute/picard:2.27.5"
        memory: "~{mem_gb}GB"
    }
}


task strand_flip {
    input {
        File vcf_file
        File rejects_file
        String out_prefix
    }

    command <<<
        has_chr=$(zcat ~{vcf_file} | grep -F 'contig=<ID=chr' -c -m 1)
        if [ "$has_chr" -gt 0 ]
        then
            chr_prefix='chrM'
        else
            chr_prefix='M'
        fi
        zcat ~{rejects_file} | cut -f3 > flip.txt
        plink --vcf ~{vcf_file} --double-id \
            --extract flip.txt --flip flip.txt \
            --output-chr $chr_prefix \
            --recode vcf-iid bgz --out ~{out_prefix}_flipped
    >>>

    output {
        File out_file = "~{out_prefix}_flipped.vcf.gz"
    }

    runtime {
        docker: "quay.io/biocontainers/plink:1.90b6.21--hec16e2b_2"
    }
}


task merge_vcf {
    input {
        Array[File] vcf_files
        String out_prefix
    }

    command <<<
        bcftools concat --allow-overlaps ~{sep=' ' vcf_files}
    >>>

    output {
        File out_file = "~{out_prefix}.vcf.gz"
    }

     runtime {
        docker: "staphb/bcftools:1.16"
    }
}
