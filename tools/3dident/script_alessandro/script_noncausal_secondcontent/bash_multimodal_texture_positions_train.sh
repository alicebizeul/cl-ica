#!/bin/bash 
#BSUB -o "generation_positions.out"
#BSUB -W 30:00
#BSUB -J generation_positions
#BSUB -n 4
#BSUB -R "rusage[ngpus_excl_p=1,mem=10000]"

DIR_EXPERIMENT="$PWD/runs/tmp"  # NOTE: experiment logs are written here

############# PLEASE CHANGE THE FOLLOWING PARAMETERS ###############
CONDA_PATH="/cluster/project/sachan/alessandro/miniconda3/etc/profile.d/conda.sh"
SCRIPT_DIR=/cluster/home/stolfoa/alice/cl-ica/tools/3dident
BLENDER_DIR=/cluster/scratch/stolfoa/alice_experiments/blender-2.90.1-linux64/blender
DATA_NAME="mydata_multimodal_texture_positions/3dident/train"  # include mention to test/val/train, MS and C/S settings
DIR_DATA="/cluster/scratch/stolfoa/alice_dataset/$DATA_NAME"
N_POINTS=200000  # if test/validation fix this to 10 000, for train fix this to 250 000
#####################################################################

N_BATCHES=10
mkdir -p ${DIR_DATA}

source ${CONDA_PATH}
conda activate alice

cd ${SCRIPT_DIR}

python generate_clevr_dataset_latents.py --output-folder ${DIR_DATA} --n-points ${N_POINTS} --non-periodic-rotation-and-color --deterministic --all-positions --multimodal
for (( i=0; i<=$N_BATCHES; i++ ))
do
    MATERIAL="MyMetal"
    if [[ $i -ge 5 ]] 
    then
        MATERIAL="Rubber"
    fi
    echo $MATERIAL

    ${BLENDER_DIR} -noaudio --background --python generate_clevr_dataset_images.py --use-gpu --output-folder ${DIR_DATA} --n-batches 10 --batch-index ${i} --material-names ${MATERIAL} --no_range_change
done
