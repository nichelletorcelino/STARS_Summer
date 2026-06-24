#!/bin/bash

refGenome=/gpfs/gibbs/project/coughlan/shared/genomes/ref/Mimulus_guttatus_var_IM62_v3.mainGenome.fasta
fqdir=~/palmer_scratch/corallinus_seq/raw_data/fastqs
cleanfqdir=~/palmer_scratch/corallinus_seq/raw_data/cleaned_fastqs
mpdir=~/palmer_scratch/corallinus_seq/raw_data/sorted_bams

echo -n "module spider fastp 2> $fqdir/version_info.txt; module spider BWA 2> $mpdir/version_info.txt; module spider SAMtools 2>> $mpdir/version_info.txt; echo \"Picard version: picard/2.25.6-Java-11\" >> $mpdir/version_info.txt; " > cleanMapMerge_joblist.txt

while read f  ; do 

	sample=$(echo $f | sed 's/:.*//g' )
	#echo $sample
	IFS=' ' read -r -a fastqs <<< "$(echo $f | sed 's/.*://g')"
	#for element in "${fastqs[@]}" ; do echo "$element" ; done
	iList=""
    
    echo -n "module load fastp; module load BWA; module load SAMtools; module load picard/2.25.6-Java-11; "  >> cleanMapMerge_joblist.txt

	for element in "${fastqs[@]}" ; do
    
        if [[ "$element" =~ "_R1_" ]] ; then  
            	fileR2=$(echo $element | sed 's/_R1_/_R2_/')
        	fileO1=$(basename $element | sed 's/\.f.*q.gz/_clean\.fastq.gz/')
        	fileO2=$(basename $fileR2 | sed 's/\.f.*q.gz/_clean\.fastq.gz/')
		base=${fileO1%%_clean*}
	elif  [[ "$element" =~ "_R1." ]] ; then
        	fileR2=$(echo $element | sed 's/_R1/_R2/')
        	fileO1=$(basename $element | sed 's/\.f.*q.gz/_clean\.fastq.gz/')
        	fileO2=$(basename $fileR2 | sed 's/\.f.*q.gz/_clean\.fastq.gz/')
        	base=${fileO1%%_clean*}
        elif [[ "$element" =~ "_1." ]] ; then
		fileR2=$(echo $element | sed 's/_1\./_2\./')
          	fileO1=$(basename $element | sed 's/\.f.*q.gz/_clean\.fastq.gz/')
            	fileO2=$(basename $fileR2 | sed 's/\.f.*q.gz/_clean\.fastq.gz/')
            	base=${fileO1%%_clean*}	    		
	fi	
	
	if [[ ${#fastqs[@]} > 1 ]] ; then 
		#echo "multiple"
		echo -n "fastp --in1 $fqdir/$element --in2 $fqdir/$fileR2 --out1 $cleanfqdir/$fileO1 --out2 $cleanfqdir/$fileO2 -q 20 -h $cleanfqdir/$base.html -j $cleanfqdir/$base.json; bwa mem -t 8 -M $refGenome $cleanfqdir/$fileO1 $cleanfqdir/$fileO2 | samtools view -q 20 -b | samtools sort -@ 8 -T $base > $mpdir/$base.sorted.bam ; samtools index $mpdir/$base.sorted.bam; " >> cleanMapMerge_joblist.txt
		iList+=" I=${mpdir}/${base}.sorted.bam"
		#echo $iList
	else 
		#echo "single"
		echo -n "fastp --in1 $fqdir/$element --in2 $fqdir/$fileR2 --out1 $cleanfqdir/$fileO1 --out2 $cleanfqdir/$fileO2 -q 20 -h $cleanfqdir/$base.html -j $cleanfqdir/$base.json; bwa mem -t 8 -M $refGenome $cleanfqdir/$fileO1 $cleanfqdir/$fileO2 | samtools view -q 20 -b | samtools sort -@ 8 -T $sample > $mpdir/$sample.sorted.bam ; samtools index $mpdir/$sample.sorted.bam " >> cleanMapMerge_joblist.txt
	fi	

	done 
	
	if [[ ${#fastqs[@]} > 1 ]] ; then 
		#echo "multiple"
		echo "java -jar \$EBROOTPICARD/picard.jar MergeSamFiles $iList O=$mpdir/$sample.merged.sorted.bam ASSUME_SORTED=true CREATE_INDEX=true" >> cleanMapMerge_joblist.txt
	else 
		#echo "single"
		echo "" >> cleanMapMerge_joblist.txt
	fi

done < ~/palmer_scratch/corallinus_seq/scripts/seq_list.txt
