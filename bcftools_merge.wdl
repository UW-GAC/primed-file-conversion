version 1.0


workflow bcftools_merge {
    input {
        Array[Array[File]] files_to_merge
        Array[String] output_prefixes
        Int mem_gb = 16
    }

    scatter (pair in zip(files_to_merge, output_prefixes)) {
        call merge_vcfs {
            input: vcf_files = pair.left,
                out_prefix = pair.right,
                mem_gb = mem_gb
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
        Int mem_gb = 16
    }

    Int disk_size = ceil(3*(size(vcf_files, "GB"))) + 10

    command <<<
        set -e -o pipefail

        echo "beginning ls"
        ls

        echo "writing input file"
        cat ~{write_lines(vcf_files)} > files.txt
        cat files.txt


        echo "Merging files..."
        echo "outfile: " ~{out_prefix}.vcf.gz
        # Merge files.
        bcftools merge \
            --no-index \
            -l files.txt \
            -o ~{out_prefix}.vcf.gz

        echo "Final debugging ls"
        ls
    >>>

    output {
        File out_file = "~{out_prefix}.vcf.gz"
    }

    runtime {
        docker: "nanozoo/bcftools:1.19--1dccf69"
        disks: "local-disk " + disk_size + " SSD"
        memory: mem_gb + " GB"

    }
}
