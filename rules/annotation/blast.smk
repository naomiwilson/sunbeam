# -*- mode: Snakemake -*-
#
# Contig annotation:
# 	Rules for BLASTing against databases
#
# See Readme.md


rule build_diamond_db:
    """Use diamond makedb to create any necessary db indeces that don't exist."""
    input:
        [Blastdbs["prot"][db] for db in Blastdbs["prot"]],
    output:
        [Blastdbs["prot"][db] + ".dmnd" for db in Blastdbs["prot"]],
    benchmark:
        BENCHMARK_FP / "build_diamond_db.tsv"
    conda:
        "../../envs/annotation.yml"
    shell:
        """
        diamond makedb --in {input} -d {input}
        """


rule run_blastn:
    """Run BLASTn against a given database and write the results to blast tabular format."""
    input:
        contigs=ASSEMBLY_FP / "contigs" / "{sample}-contigs.fa",
    output:
        ANNOTATION_FP / "blastn" / "{db}" / "{contigs}" / "{sample}.btf",
    benchmark:
        BENCHMARK_FP / "run_blastn_{db}_{contigs}_{sample}.tsv"
    params:
        db=lambda wildcard: Blastdbs["nucl"][wildcard.db],
    threads: 4  # Should be overridden by profile's set-threads (https://github.com/snakemake/snakemake/issues/1983)
    conda:
        "../../envs/annotation.yml"
    shell:
        """
        blastn \
        -query {input.contigs} \
        -db {params.db} \
        -outfmt 7 \
        -num_threads {threads} \
        -evalue 1e-10 \
        -max_target_seqs 5000 \
        -out {output} \
        """


rule run_diamond_blastp:
    """Run diamond blastp on translated genes against a target db and write to blast tabular format."""
    input:
        genes=ANNOTATION_FP / "genes" / "{orf_finder}" / "{sample}_genes_prot.fa",
        db=lambda wildcard: Blastdbs["prot"][wildcard.db],
        indeces=rules.build_diamond_db.output,
    output:
        ANNOTATION_FP / "blastp" / "{db}" / "{orf_finder}" / "{sample}.btf",
    benchmark:
        BENCHMARK_FP / "run_diamond_blastp_{db}_{orf_finder}_{sample}.tsv"
    threads: 4  # Should be overridden by profile's set-threads (https://github.com/snakemake/snakemake/issues/1983)
    conda:
        "../../envs/annotation.yml"
    shell:
        """
        diamond blastp \
        -q {input.genes} \
        --db {input.db} \
        --outfmt 6 \
        --threads {threads} \
        --evalue 1e-10 \
        --max-target-seqs 2475 \
        --out {output} \
        || if [ $? == 1 ]; then echo "Caught empty query error from diamond" && touch {output}; fi
        """


rule run_diamond_blastx:
    """Run diamond blastx on untranslated genes against a target db and write to blast tabular format."""
    input:
        genes=ANNOTATION_FP / "genes" / "{orf_finder}" / "{sample}_genes_nucl.fa",
        db=lambda wildcard: Blastdbs["prot"][wildcard.db],
        indeces=rules.build_diamond_db.output,
    output:
        ANNOTATION_FP / "blastx" / "{db}" / "{orf_finder}" / "{sample}.btf",
    benchmark:
        BENCHMARK_FP / "run_diamond_blastx_{db}_{orf_finder}_{sample}.tsv"
    threads: 4  # Should be overridden by profile's set-threads (https://github.com/snakemake/snakemake/issues/1983)
    conda:
        "../../envs/annotation.yml"
    shell:
        """
        diamond blastx \
        -q {input.genes} \
        --db {input.db} \
        --outfmt 6 \
        --threads {threads} \
        --evalue 1e-10 \
        --max-target-seqs 2475 \
        --out {output} \
        || if [ $? == 1 ]; then echo "Caught empty query error from diamond" && touch {output}; fi
        """


rule blast_report:
    """Create a summary of results from a BLAST call."""
    input:
        expand(
            ANNOTATION_FP / "{{blast_prog}}" / "{{db}}" / "{{query}}" / "{sample}.btf",
            sample=Samples.keys(),
        ),
    output:
        ANNOTATION_FP / "{blast_prog}" / "{db}" / "{query}" / "report.tsv",
    conda:
        "../../envs/annotation.yml"
    script:
        "../../scripts/annotation/blast_report.py"


rule _test_blastpx:
    input:
        expand(
            ANNOTATION_FP / "{blastpx}" / "card" / "prodigal" / "{sample}.btf",
            blastpx=["blastx", "blastp"],
            sample=Samples.keys(),
        ),


rule _test_blastpx_report:
    input:
        expand(
            ANNOTATION_FP / "{blastpx}" / "card" / "prodigal" / "report.tsv",
            blastpx=["blastx", "blastp"],
        ),
