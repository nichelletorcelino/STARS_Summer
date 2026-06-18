#!/bin/bash 
#SBATCH --job-name=bams
#SBATCH --time=03:00:00
#SBATCH -c 8

module load BWA

module load SAMtools

bwa mem -t 8 -M /gpfs/gibbs/project/coughlan/shared/genomes/ref/Mimulus_guttatus_var_IM62_v3.mainGenome.fasta ../raw_data/cleaned_fastqs/ASPEN1_2_A22CJLFLT3_L001_R1_001_cleaned.fastq.gz ../raw_data/cleaned_fastqs/ASPEN1_2_A22CJLFLT3_L001_R2_001_cleaned.fastq.gz > ../raw_data/sorted_bams/ASPEN1_2.bam

samtools view -q 20 -b ../raw_data/sorted_bams/ASPEN1_2.bam | samtools sort -@ 8 -T ASPEN1_2 > ../raw_data/sorted_bams/ASPEN1_2.sorted.bam 

samtools index ../raw_data/sorted_bams/ASPEN1_2.sorted.bam

