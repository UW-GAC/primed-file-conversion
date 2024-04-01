version 1.0

workflow plink2_pgen2vcf {
    input {
		File pgen
		File pvar
		File psam
        String? out_prefix
    }

    call pgen2vcf {
        input: pgen = pgen,
               pvar = pvar,
               psam = psam,
               out_prefix = out_prefix
    }

    output {
        File out_file = pgen2vcf.out_file
        String md5sum = pgen2vcf.md5sum
    }

     meta {
          author: "Stephanie Gogarten"
          email: "sdmorris@uw.edu"
     }
}

task pgen2vcf {
    input {
		File pgen
		File pvar
		File psam
        String? out_prefix
    }

    String out_string = if defined(out_prefix) then out_prefix else basename(pgen, ".pgen")

    command {
        plink2 \
            --pgen ~{pgen} --pvar ~{pvar} --psam ~{psam} \
            --export vcf id-paste=iid bgz \
            --out ${out_string}
        md5sum ${out_string}.vcf.gz | cut -d " " -f 1 > md5.txt
    }

    output {
        File out_file = "${out_string}.vcf.gz"
        String md5sum = read_string("md5.txt")
    }

    runtime {
        docker: "quay.io/biocontainers/plink2:2.00a3.3--hb2a7ceb_0"
    }
}
