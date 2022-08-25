#!/bin/bash

### Example usage ###
# bash "./scripts/slurm/submit_perturb.sh" "./conf/multi_news/primera/eval.yml"

### Script arguments ###
# Must be provided as argument to the script
CONFIG_FILEPATH="$1"  # The path on disk to the yml config file
OUTPUT_DIR="$2"       # The path on disk to save the output to
# Constants
PERTURBATIONS=("backtranslation" "duplication" "addition" "deletion" "replacement")
STRATEGIES=("random" "best-case" "worst-case")
PERTURBED_FRAC=(0.1 0.5 1.0)

### Job ###

# Run the baseline
sbatch "./scripts/slurm/perturb.sh" "$CONFIG_FILEPATH" "$OUTPUT_DIR/baseline"

# Run the grid
for strategy in "${STRATEGIES[@]}";
do
    # Sorting does not need to run for multiple perturbed fractions
    sbatch "./scripts/slurm/perturb.sh" "$CONFIG_FILEPATH" \
        "$OUTPUT_DIR/perturbations/$strategy/sorting" \
        "sorting" \
        "${strategy}"

    for perturbation in "${PERTURBATIONS[@]}";
    do
        for perturbed_frac in "${PERTURBED_FRAC[@]}";
        do
            sbatch "./scripts/slurm/perturb.sh" "$CONFIG_FILEPATH" \
                "$OUTPUT_DIR/perturbations/$strategy/$perturbation/$perturbed_frac" \
                "${perturbation}" \
                "${strategy}" \
                "${perturbed_frac}"
        done
    done
done