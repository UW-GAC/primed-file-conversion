version 1.0

workflow plink2_pgen2bed {
    input {
        File pgen
        File pvar
        File psam
        String? out_prefix
    }

    call pgen2bed {
        input: pgen = pgen,
               pvar = pvar,
               psam = psam,
               out_prefix = out_prefix
    }

    output {
        File out_bed = pgen2bed.out_bed
        File out_bim = pgen2bed.out_bim
        File out_fam = pgen2bed.out_fam
        Map[String, String] md5sum = pgen2bed.md5sum
    }

     meta {
          author: "Stephanie Gogarten"
          email: "sdmorris@uw.edu"
     }
}

task pgen2bed {
    input {
        File pgen
        File pvar
        File psam
        String? out_prefix
        Int mem_gb = 16
    }

    Int disk_size = ceil(3*(size(pgen, "GB") + size(pvar, "GB") + size(psam, "GB"))) + 10
    String out_string = if defined(out_prefix) then out_prefix else basename(pgen, ".pgen")

    command {
        plink2 \
            --pgen ~{pgen} --pvar ~{pvar} --psam ~{psam} \
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
        docker: "quay.io/biocontainers/plink2:2.00a5.10--h4ac6f70_0"
        disks: "local-disk " + disk_size + " SSD"
        memory: mem_gb + " GB"
    }
}
