version 1.0

workflow plink2_vcf2bed {
    input {
        File vcf_file
        String? out_prefix
    }

    call vcf2bed {
        input: vcf_file = vcf_file,
               out_prefix = out_prefix
    }

    output {
        File out_bed = vcf2bed.out_bed
        File out_bim = vcf2bed.out_bim
        File out_fam = vcf2bed.out_fam
        Map[String, String] md5sum = vcf2bed.md5sum
    }

     meta {
          author: "Stephanie Gogarten"
          email: "sdmorris@uw.edu"
     }
}

task vcf2bed {
    input {
        File vcf_file
        String? out_prefix
    }

    String out_string = if defined(out_prefix) then out_prefix else basename(vcf_file, ".vcf.gz")

    command {
        plink2 \
            --vcf ${vcf_file} \
            --make-bed \
            --out ${out_string}
        md5sum ${out_string}.bed | cut -d " " -f 1 > md5_bed.txt
        md5sum ${out_string}.bim | cut -d " " -f 1 > md5_bim.txt
        md5sum ${out_string}.fam | cut -d " " -f 1 > md5_fam.txt
    }

    output {
        File out_bed = "${out_string}.bed"
        File out_bim = "${out_string}.bim"
        File out_fam = "${out_string}.fam"
        Map[String, String] md5sum = {
            "bed": read_string("md5_bed.txt"), 
            "bim": read_string("md5_bim.txt"), 
            "fam": read_string("md5_fam.txt")
        }
    }

    runtime {
        docker: "quay.io/biocontainers/plink2:2.00a3.3--hb2a7ceb_0"
    }
}
