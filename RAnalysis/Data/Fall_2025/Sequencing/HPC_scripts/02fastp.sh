#!/bin/bash
#SBATCH --job-name="fastp_oyster"
#SBATCH -t 100:00:00
#SBATCH --nodes=1 --ntasks-per-node=20
#SBATCH --output=./Mgigas_heat_prime_2025/data/trim/"%x_out.%j"
#SBATCH --error=./Mgigas_heat_prime_2025/data/trim/"%x_err.%j"
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=samuel.gurr@oregonstate.edu


# make a new director to save to
mkdir -p ./Mgigas_heat_prime_2025/data/trim # make subfolder
mkdir -p ./Mgigas_heat_prime_2025/data/trim/fastqc_output # make subfolder
mkdir -p ./Mgigas_heat_prime_2025/data/trim/fastqc_output/multiqc # make subfolder

## adapter.fasta file
#echo -e ">TruSeq_1 \nAGATCGGAAGAGCACACGTCTGAACTCCAGTCA \n>TruSeq_2 \nAGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT \n>OverRep_1 \nCGACCTTTAATACCCTACGTGATTTGAGTTCAGACCGGCGTAAGCCAGGT \n>OverRep_2 \nTCGACCTTTAATACCCTACGTGATTTGAGTTCAGACCGGCGTAAGCCAGG" > ./Mgigas_heat_prime_2025/data/trim/adapter.fasta
echo -e ">TruSeq_Universal \nAGATCGGAAGAGCACACGTCTGAACTCCAGTCA" > ./Mgigas_heat_prime_2025/data/trim/adapter.fasta

# array for all fastq.gz files (calling symbolic in home folder)
array_m=($(ls ./Mgigas_heat_prime_2025/data/raw/*.fastq.gz));  # an array of sequences to trim

# for loop for trimming
#for i in ${array_m[@]}; do # inside for loop for each loop var
#	filename=$(echo "${i}" | awk -F/ '{print $NF}') # filename ensures that the output name of the .gz file does not include the preceeding dir - solely filename.fasta.gz
#        fastp --in1 ${i} --out1 ./Mgigas_heat_prime_2025/data/trim/clean.${filename} --trim_poly_x --poly_x_min_len 10 --adapter_fasta ./Mgigas_heat_prime_2025/data/trim/adapter.fasta
#	fastqc  ./Mgigas_heat_prime_2025/data/trim/clean.${filename} --outdir ./Mgigas_heat_prime_2025/data/trim/fastqc_output # call the output files from fastp in previous line and output fastqc in the same folder with adapter_trim filename head
#	done;

# for loop for trimming
for i in ${array_m[@]}; do
    filename=$(echo "${i}" | awk -F/ '{print $NF}')
    fastp \
        --in1 ${i} \
        --out1 ./Mgigas_heat_prime_2025/data/trim/clean.${filename} \
        --adapter_sequence AGATCGGAAGAGCACACGTCTGAACTCCAGTCA \
        --trim_poly_x \
        --poly_x_min_len 10 \
        --trim_poly_g \
        --poly_g_min_len 10 \
        --cut_right \
        --cut_right_mean_quality 20 \
        --cut_window_size 4 \
        --cut_mean_quality 20 \
        --qualified_quality_phred 20 \
        --unqualified_percent_limit 20 \
        --length_required 20 \
        --thread 4 \
        -j ./logs/${filename}.json \
        -h ./logs/${filename}.html
    fastqc ./Mgigas_heat_prime_2025/data/trim/clean.${filename} \
        --outdir ./Mgigas_heat_prime_2025/data/trim/fastqc_output
done


# multiqc
multiqc ./Mgigas_heat_prime_2025/data/trim/fastqc_output -o ./Mgigas_heat_prime_2025/data/trim/fastqc_output/multiqc
