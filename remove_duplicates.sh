#!/bin/bash 
#SBATCH --job-name=remove_dups
#SBATCH --time=03:00:00
#SBATCH --mem-per-cpu=10G

module load picard/2.25.6-Java-11

java -Xmx10g -jar $EBROOTPICARD/picard.jar MarkDuplicates INPUT=../raw_data/sorted_bams/ASPEN1_2.sorted.bam OUTPUT=../raw_data/processed_bams/ASPEN1_2.sorted.nodup.bam METRICS_FILE=../raw_data/processed_bamfiles/ASPEN1_2.duplicate.metrics REMOVE_DUPLICATES=true ASSUME_SORTED=true TMP_DIR=../raw_data/processed_bamfiles/tmp_ASPEN1 MAX_RECORDS_IN_RAM=500000 VALIDATION_STRINGENCY=LENIENT

module load SAMtools
samtools index ../raw_data/processed_bams/ASPEN1_2.sorted.nodup.bam
