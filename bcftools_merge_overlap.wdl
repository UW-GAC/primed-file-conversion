version 1.0

workflow bcftools_merge_overlap {
    input {
        File vcf_file_1
        File vcf_file_2
        String out_prefix = "merged"
    }

    call merge {
        input:
            vcf_file_1 = vcf_file_1,
            vcf_file_2 = vcf_file_2,
            out_prefix = out_prefix
    }

    output {
        File merged_file = merge.merged_file
    }
}

task merge {
    input {
        File vcf_file_1
        File vcf_file_2
        String out_prefix
    }

    command <<<
        set -e -o pipefail
        bcftools annotate --set-id '%CHROM:%POS:%REF:%ALT' ~{vcf_file_1} -O z -o file1.vcf.gz 
        bcftools annotate --set-id '%CHROM:%POS:%REF:%ALT' ~{vcf_file_2} -O z -o file2.vcf.gz 
        bcftools index file1.vcf.gz
        bcftools index file2.vcf.gz
        bcftools isec -p isec -n=2 file1.vcf.gz file2.vcf.gz
        bgzip isec/0000.vcf
        bcftools index isec/0000.vcf.gz
        bgzip isec/0001.vcf
        bcftools index isec/0001.vcf.gz
        bcftools merge -m all isec/0000.vcf.gz isec/0001.vcf.gz -O z -o ~{out_prefix}.vcf.gz
    >>>

    output {
        File merged_file = "~{out_prefix}.vcf.gz"
    }

     runtime {
        docker: "nanozoo/bcftools:1.19--1dccf69"
    }
}
