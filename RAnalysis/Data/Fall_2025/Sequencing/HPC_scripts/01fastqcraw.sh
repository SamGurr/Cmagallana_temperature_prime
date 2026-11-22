#!/bin/bash
#SBATCH --job-name="fastp_oyster"
#SBATCH -t 100:00:00
#SBATCH --nodes=1 --ntasks-per-node=20
#SBATCH --output="%x_out.%j"
#SBATCH --error="%x_err.%j"
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=samuel.gurr@oregonstate.edu

# run from the home directory, navigating forward 
mkdir -p Mgigas_heat_prime_2025/data/raw/fastqc_output

fastqc Mgigas_heat_prime_2025/data/raw/*.gz -o Mgigas_heat_prime_2025/data/raw/fastqc_output/
echo "Finished FastQC"

multiqc Mgigas_heat_prime_2025/data/raw/fastqc_output/
echo "Finished MultiQC"
