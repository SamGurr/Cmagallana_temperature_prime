#!/bin/bash
#SBATCH --job-name="mapping"
#SBATCH -t 100:00:00
#SBATCH --nodes=1 --ntasks-per-node=20
#SBATCH --output=./Mgigas_heat_prime_2025/data/map/"%x_out.%j"
#SBATCH --error=./Mgigas_heat_prime_2025/data/map/"%x_err.%j"
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=samuel.gurr@oregonstate.edu

# make a new director to save to
mkdir -p ./Mgigas_heat_prime_2025/data/map # make subfolder

# index the reference genome for Panopea generosa output index to working directory
#hisat2-build -f  ./../../../../nfs5/external/Gurr_Lab/refs/Magallana_gigas/GCF_963853765.1_xbMagGiga1.1_genomic.fna ./Mgigas_heat_prime_2025/data/map/Mgigas_ref # called the reference genome (scaffolds)
echo "Referece genome indexed. Starting alingment" $(date)

# change dir to run in map subfolder
cd ./Mgigas_heat_prime_2025/data/map

# symbolically link 'clean' reads to hisat2 dir
#ln -s ./../trim/clean*.fastq.gz ./ # symb link from map dir all clean data from trim and output in the map dir

# This script exports alignments as bam files
# sorts the bam file because Stringtie takes a sorted file for input (--dta)
# removes the sam file because it is no longer needed
array=(*.fastq.gz) # # call the symbolically linked sequences - make an array to align
for i in "${array[@]}"; do
        sample_name=$(echo $i | awk -F '[._]' '{print $1"_"$3}')
        hisat2 \
                -p 8 \
                --dta \
                -x ./Mgigas_ref \
                -U ${i} \
                -S ${sample_name}.sam
        samtools \
                sort \
                -@ 8 \
                -o ./${sample_name}.bam ./${sample_name}.sam
        echo "${i} bam-ified!"
        rm ./${sample_name}.sam
done
