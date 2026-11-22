#!/bin/bash
#SBATCH --job-name=sort_align
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=20
#SBATCH --mem=32G
#SBATCH --time=24:00:00
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=samuel.gurr@oregonstate.edu
#SBATCH --output=Mgigas_heat_prime_2025/outputs/sort_align_%j.log
#SBATCH --error=Mgigas_heat_prime_2025/outputs/sort_align_%j.err

# ---- Load modules ----
# module load samtools
# module load stringtie

# ---- Define paths ----
BAM_DIR=Mgigas_heat_prime_2025/data/map
SORT_DIR=Mgigas_heat_prime_2025/data/sort_align
GTF=/nfs5/external/Gurr_Lab/refs/Magallana_gigas/genomic.gff
PREPDE=Mgigas_heat_prime_2025/scripts/prepDE.py
OUT_DIR=Mgigas_heat_prime_2025/outputs

# ---- Make output dirs if needed ----
mkdir -p ${SORT_DIR}
mkdir -p ${OUT_DIR}

# ---- Loop over all samples ----
#for BAM in ${BAM_DIR}/clean_S*.bam; do

    # Extract sample name e.g. clean_S43
#    SAMPLE=$(basename ${BAM} .bam)

#    echo "Processing ${SAMPLE}..."

    # Step 1: samtools sort
#    samtools sort \
#        -@ 20 \
#        -o ${SORT_DIR}/${SAMPLE}_sorted.bam \
#        ${BAM}

    # Step 2: samtools index
    #samtools index ${SORT_DIR}/${SAMPLE}_sorted.bam

    # Step 3: StringTie2 quantification against reference GTF
#    stringtie \
#        ${SORT_DIR}/${SAMPLE}_sorted.bam \
#        -G ${GTF} \
#        -e \
#        -p 20 \
#        -o ${SORT_DIR}/${SAMPLE}.gtf \
#        -A ${SORT_DIR}/${SAMPLE}_gene_abund.tab

#    echo "Finished ${SAMPLE}"

#done

# ---- Build sample list for prepDE.py ----
#echo "Building sample list for prepDE.py..."

#SAMPLE_LIST=${OUT_DIR}/sample_list.txt

#for GTF_FILE in ${SORT_DIR}/clean_S*_sorted.gtf; do
#    SAMPLE=$(basename ${GTF_FILE} _sorted.gtf)
#    echo "${SAMPLE} ${GTF_FILE}" >> ${SAMPLE_LIST}
#done
SAMPLE_LIST=${OUT_DIR}/sample_list.txt

for GTF_FILE in ${SORT_DIR}/clean_S*.gtf; do
    SAMPLE=$(basename ${GTF_FILE} _sorted.gtf)
    printf "%s\t%s\n" "${SAMPLE}" "${GTF_FILE}" >> ${SAMPLE_LIST}
done

# ---- Run prepDE.py to generate abundance matrix ----
echo "Running prepDE.py..."

python2 ${PREPDE} \
    -i ${SAMPLE_LIST} \
    -g ${OUT_DIR}/gene_count_matrix.csv \
    -t ${OUT_DIR}/transcript_count_matrix.csv

echo "Pipeline complete. Count matrices written to ${OUT_DIR}/"
