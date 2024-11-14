version 1.0


workflow bcftools_merge {
    input {
        Array[Array[File]] files_to_merge
    }

    scatter (x in files_to_merge) {
        call merge_vcfs {
            input: vcf_files = x,
                out_prefix = "output"
        }
    }

    output {
        Array[File] out_files = merge_vcfs.out_file
    }

    meta {
        author: "Adrienne Stilp"
        email: "amstilp@uw.edu"
    }
}

task merge_vcfs {
    input {
        Array[File] vcf_files
        String out_prefix
    }

#    Int disk_size = ceil(3*(size(vcf_files, "GB"))) + 10

    command {
        set -e -o pipefail
        cat ${sep=" " vcf_files}  > ${out_prefix}.vcf.gz
    }

    output {
        File out_file = "${out_prefix}.vcf.gz"
        String md5sum = "${out_prefix}.vcf.gz"
    }

    runtime {
        docker: "biocontainers/bcftools:v1.9-1-deb_cv1"
    }
}
