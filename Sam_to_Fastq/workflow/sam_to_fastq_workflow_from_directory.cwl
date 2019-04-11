#!/usr/bin/env cwl-runner
#
# Authors: Andrew Lamb
#
# This starts with a directory of .bam files, and uploads them to synapse

cwlVersion: v1.0
class: Workflow

doc: sam to fastq workflow

requirements:
- class: ScatterFeatureRequirement
- class: StepInputExpressionRequirement
- class: InlineJavascriptRequirement
- class: MultipleInputFeatureRequirement

inputs:

- id: sam_file_directory
  type: Directory
- id: synapse_config
  type: File
- id: synapse_directory_id
  type: string

outputs: []


steps:

- id: get_files
  run: steps/expression_tools/directory_to_file_array.cwl
  in: 
  - id: directory
    source: sam_file_directory
  out:
  - file_array

- id: filter_bam_files
  run: ../../utils/expression_tools/CWL/split_file_array_by_extension.cwl
  in: 
  - id: file_array
    source: get_files/file_array
  - id: file_extension
    valueFrom: ".bam"
  out:
  - array1

- id: create_fastq_names
  run: steps/expression_tools/sam_to_fastq_names.cwl
  in: 
  - id: sam_file_array
    source: filter_bam_files/array1
  out:
  - fastq_names_1
  - fastq_names_2

- id: scatter_sam_to_fastq
  run: steps/sam_to_fastq/sam_to_fastq.cwl
  in: 
  - id: aligned_reads_sam
    source: filter_bam_files/array1
  - id: reads_r1_fastq
    source: create_fastq_names/fastq_names_1
  - id: reads_r2_fastq
    source: create_fastq_names/fastq_names_2
  scatter: 
  - aligned_reads_sam
  - reads_r1_fastq
  - reads_r2_fastq
  scatterMethod: dotproduct
  out: 
  - r1_fastq
  - r2_fastq

- id: filter_non_empty_fastq_files
  run: steps/expression_tools/split_file_array_by_size.cwl
  in: 
  - id: file_array
    source: [scatter_sam_to_fastq/r1_fastq, scatter_sam_to_fastq/r2_fastq]
    linkMerge: merge_flattened
  - id: size_filter
    valueFrom: $(1)
  out:
  - array1

- id: upload_to_synapse
  run: https://raw.githubusercontent.com/Sage-Bionetworks/synapse-client-cwl-tools/master/synapse-store-tool.cwl
  in:
  - id: synapse_config
    source: synapse_config
  - id: file_to_store
    source: filter_non_empty_fastq_files/array1
  - id: parentid
    source: synapse_directory_id
  scatter: file_to_store
  out: []

