#!/bin/bash 

#for folder in ASPEN1 BAG3 CF3r12 ; do 
for folder in DINKEY2 DM1 EAG EAM FREEMAN4 GAB1 GAB2 HELIPORT1 HMC1 HUNTINGTON1 ; do 
	cp /gpfs/gibbs/project/coughlan/shared/genomes/samples/$folder/*q.gz ../raw_data/fastqs/
done 


