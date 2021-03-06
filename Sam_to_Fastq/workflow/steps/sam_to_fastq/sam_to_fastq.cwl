#!/usr/bin/env cwl-runner

# https://raw.githubusercontent.com/Sage-Bionetworks/amp-workflows/develop/tools/picard_samtofastq/picard_samtofastq.cwl

class: CommandLineTool
cwlVersion: v1.0
id: picard-samtofastq
label: Picard SamToFastq

doc: |
  Use Picard to convert BAM to FASTQ.

  Original command:
  java -Xmx4G -jar $PICARD SamToFastq \
    INPUT=/dev/stdin \
    FASTQ="${fastqdir}/${sample}.r1.fastq" \
    SECOND_END_FASTQ="${fastqdir}/${sample}.r2.fastq" \
    VALIDATION_STRINGENCY=SILENT

baseCommand: 
- picard.sh
- SamToFastq

requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: ResourceRequirement
    ramMin: 4000
    tmpdirMin: 35000
  - class: DockerRequirement
    dockerPull: 'quay.io/sage-bionetworks/picard_utils:1.0'


inputs:

  - id: aligned_reads_sam
    label: Aligned reads SAM
    doc: Reads data file in SAM (or BAM) format
    type: File
    inputBinding:
      position: 1
      prefix: INPUT=
      separate: false

  - id: reads_r1_fastq
    label: R1 reads FASTQ
    default: r1.fastq.gz
    type: string
    inputBinding:
      position: 2
      prefix: FASTQ=
      separate: false

  - id: reads_r2_fastq
    label: R2 reads FASTQ
    default: r2.fastq.gz
    type: string?
    inputBinding:
      position: 3
      prefix: SECOND_END_FASTQ=
      separate: false

  - id: validation_stringency
    type: string
    default: "LENIENT"
    inputBinding:
      position: 4
      prefix: VALIDATION_STRINGENCY=
      separate: false

outputs:

  - id: r1_fastq
    label: Unaligned reads FASTQ
    doc: Unaligned reads in FASTQ file format
    type: File
    outputBinding:
      glob: $(inputs.reads_r1_fastq)

  - id: r2_fastq
    label: Unaligned reads FASTQ
    doc: Unaligned reads in FASTQ file format
    type: File
    outputBinding:
      glob: $(inputs.reads_r2_fastq)

