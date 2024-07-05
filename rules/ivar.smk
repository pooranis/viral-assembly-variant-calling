shell.prefix("set -eo pipefail; ")


rule ivar:
  input:
    ref="data/{sample}/{sample}.consensus.fa",
    bam="data/{sample}/{sample}.bt2.rmdup.bam"
  output:
    tsv="data/{sample}/ivar/{sample}.ivar.tsv",
    vcf="data/{sample}/ivar/{sample}.ivar.vcf"
  params:
      prefix="data/{sample}/ivar/{sample}.ivar",
      convertscript=workflow.source_path("../scripts/ivar_variants_to_vcf.py")
  log:
    "data/{sample}/logs/ivar.log"
  conda:
    "../envs/ivar.yaml"
  shell:
      """
      ## cleanup failed previous run
      rm -rf data/{wildcards.sample}/ivar
      mkdir -p data/{wildcards.sample}/ivar || true

      samtools version  >>{log} 2>>{log}
      ivar version  >>{log} 2>>{log}

      samtools mpileup -aa -A -d 0 -B -Q 0 --reference {input.ref} {input.bam} \
          | ivar variants  -p {params.prefix} -r {input.ref} >>{log} 2>>{log} 

      python {params.convertscript} {output.tsv} {output.vcf}  >>{log} 2>>{log} 
      
      """
