#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: Workflow

doc: sam to fastq workflow

requirements:
- class: ScatterFeatureRequirement

inputs:

- id: sam_file
  type: File

- id: fastq_r1_name
  type: string

- id: fastq_r2_name
  type: string

outputs:

- id: r1_fastq
  outputSource: sam_to_fastq/r1_fastq
  type: File

- id: r2_fastq
  outputSource: sam_to_fastq/r2_fastq
  type: File


steps:

- id: sort
  run: steps/sort/sort.cwl
  in:
  - id: aligned_reads_sam
    source: sam_file
  out:
  - id: sorted_reads_bam

- id: sam_to_fastq
  run: steps/sam_to_fastq/sam_to_fastq.cwl
  in: 
  - id: aligned_reads_sam
    source: sort/sorted_reads_bam
  - id: reads_r1_fastq
    source: fastq_r1_name
  - id: reads_r2_fastq
    source: fastq_r2_name
  out: 
  - r1_fastq
  - r2_fastq

$namespaces:
  s: https://schema.org/

s:author:
  - class: s:Person
    s:identifier: https://orcid.org/0000-0002-0326-7494
    s:email: andrew.lamb@sagebase.org
    s:name: Andrew Lamb



