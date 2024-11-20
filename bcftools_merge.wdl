version 1.0


workflow bcftools_merge {
    input {
        Array[Array[File]] files_to_merge
        Array[String] output_prefixes
        Boolean missing_to_ref = false
        Int mem_gb = 16
    }

    scatter (pair in zip(files_to_merge, output_prefixes)) {

        scatter (vcf_file in pair.left) {
            call create_index_file {
                input: vcf_file = vcf_file
            }
        }

        call merge_vcfs {
            input: vcf_files = pair.left,
                out_prefix = pair.right,
                mem_gb = mem_gb,
                missing_to_ref = missing_to_ref,
                index_files = create_index_file.index_file
        }
    }

    output {
        Array[File] out_files = merge_vcfs.out_file
        Array[File] out_index_files = merge_vcfs.out_index_file
    }

    meta {
        author: "Adrienne Stilp"
        email: "amstilp@uw.edu"
    }
}

task create_index_file {

    input {
        File vcf_file
        String? output_prefix = "index"
    }

    Int disk_size = ceil(2 * size(vcf_file, "GB")) + 2

    command <<<

        echo {~vcf_file}

        bcftools index \
            ~{vcf_file} \
            -o ~{output_prefix}.csi
    >>>

    output {
        File index_file = "~{output_prefix}.csi"
    }

    runtime {
        docker: "nanozoo/bcftools:1.19--1dccf69"
        disks: "local-disk " + disk_size + " SSD"
    }
}

task merge_vcfs {
    input {
        Array[File] vcf_files
        Array[File] index_files
        String out_prefix
        Int mem_gb = 16
        Boolean missing_to_ref = false
    }

    Int disk_size = ceil(3*(size(vcf_files, "GB"))) + 10

    command <<<
        set -e -o pipefail

        echo "writing input file"
        VCF_ARRAY=(~{sep=" " vcf_files}) # Load array into bash variable
        INDEX_ARRAY=(~{sep=" " index_files}) # Load array into bash variable
        for idx in ${!VCF_ARRAY[*]}
        do
            echo "${VCF_ARRAY[$idx]}##idx##${INDEX_ARRAY[$idx]}"
        done > files.txt

        echo "printing files to merge"
        cat files.txt


        echo "Merging files..."
        # Merge files.
        bcftools merge \
            -l files.txt \
            ~{if missing_to_ref then "--missing-to-ref" else ""} \
            -o ~{out_prefix}.vcf.gz \
            --write-index
    >>>

    output {
        File out_file = "~{out_prefix}.vcf.gz"
        File out_index_file = "~{out_prefix}.vcf.gz.csi"
    }

    runtime {
        docker: "nanozoo/bcftools:1.19--1dccf69"
        disks: "local-disk " + disk_size + " SSD"
        memory: mem_gb + " GB"

    }
}
