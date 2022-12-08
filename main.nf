#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { GRAPHTYPER_GENOTYPE } from './modules/graphtyper/genotype/main.nf'
include { BWA_INDEX } from './modules/bwa/index/main.nf'
include { FASTQ_ALIGN_BWA } from './subworkflows/fastq_align_bwa/main.nf'

workflow {
    
    input = [
        [ id:'test_sample' ], // meta map
        [ file('data/test.paired_end.sorted.bam', checkIfExists: true) ],
        [ file('data/test.paired_end.sorted.bam.bai', checkIfExists: true) ]
    ]
    reference = file('data/genome.fasta', checkIfExists: true)
    ref_index = file('data/genome.fasta.fai', checkIfExists: true)
    region = [ 'MT192765.1' ]
    
    reads = [
        [ id:'test_reads' ], // meta map
        [ file('data/test_1.fastq.gz', checkIfExists: true) ]
    ]
    bwa_ref = [
        [ id:'test_index' ], // meta map
        [ file('data/genome.fasta', checkIfExists: true) ]
    ]

    BWA_INDEX ( bwa_ref )
    FASTQ_ALIGN_BWA ( reads, BWA_INDEX.out.index, true, reference )
    GRAPHTYPER_GENOTYPE ( FASTQ_ALIGN_BWA.out.bam, FASTQ_ALIGN_BWA.out.bai, reference, ref_index, region )
}
