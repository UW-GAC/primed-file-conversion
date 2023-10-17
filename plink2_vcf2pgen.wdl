version 1.0

workflow plink2_vcf2pgen {
    input {
        File vcf_file
        String? out_prefix
    }

    call vcf2pgen {
        input: vcf_file = vcf_file,
               out_prefix = out_prefix
    }

    output {
        File out_pgen = vcf2pgen.out_pgen
        File out_pvar = vcf2pgen.out_pvar
        File out_psam = vcf2pgen.out_psam
        Map[String, String] md5sum = vcf2pgen.md5sum
    }

     meta {
          author: "Stephanie Gogarten"
          email: "sdmorris@uw.edu"
     }
}

task vcf2pgen {
    input {
        File vcf_file
        String? out_prefix
    }

    String out_string = if defined(out_prefix) then out_prefix else basename(vcf_file, ".vcf.gz")

    command {
        plink2 \
            --vcf ${vcf_file} \
            --make-pgen \
            --out ${out_string}
        md5sum ${out_string}.pgen | cut -d " " -f 1 > md5_pgen.txt
        md5sum ${out_string}.pvar | cut -d " " -f 1 > md5_pvar.txt
        md5sum ${out_string}.psam | cut -d " " -f 1 > md5_psam.txt
    }

    output {
        File out_pgen = "${out_string}.pgen"
        File out_pvar = "${out_string}.pvar"
        File out_psam = "${out_string}.psam"
        Map[String, String] md5sum = {
            "pgen": read_string("md5_pgen.txt"), 
            "pvar": read_string("md5_pvar.txt"), 
            "psam": read_string("md5_psam.txt")
        }
    }

    runtime {
        docker: "quay.io/biocontainers/plink2:2.00a3.3--hb2a7ceb_0"
    }
}
