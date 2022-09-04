#!/bin/bash 
#SBATCH -o myoutput.out
#SBATCH --time=80:00:00
#SBATCH -p gpu
#SBATCH --gres=gpu:rtx2080ti:1   
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=10G

DIR_EXPERIMENT="$PWD/runs/tmp"  # NOTE: experiment logs are written here

############# CHANGE THE FOLLOWING PARAMETERS ###############
CONDA_PATH="<path conda.sh>"  # "/cluster/home/abizeul/software/anaconda/envs/kugelen/lib/:$LD_LIBRARY_PATH"
SCRIPT_DIR="<path to the cl-ica/tools/3dident/ folder>"  # /cluster/home/abizeul/cl-ica/tools/3dident
BLENDER_DIR="<path to blender>"   # /cluster/home/abizeul/software/blender-2.90.1-linux64/blender
DATA_NAME="<name of dataset folder>"  # include mention to test/val/train, MS and C/S settings, 
DIR_DATA="<path to data parent directory>/$DATA_NAME" # /cluster/work/vogtlab/Group/abizeul/
N_POINTS=<number of samples>  # if test/validation fix this to 10 000, for train fix this to 250 000
CONDA_ENV=<name conda environment>
#####################################################################

N_BATCHES=10
mkdir -p ${DIR_DATA}

source ${CONDA_PATH}
conda activate $CONDA_ENV

cd ${SCRIPT_DIR}

python generate_clevr_dataset_latents_causal.py \ 
        --output-folder ${DIR_DATA} \
        --n-points ${N_POINTS} \
        --non-periodic-rotation-and-color \
        --deterministic \
        --all-positions \   # --all-positions/--all-hues/--all-rotations | change depending what is modality specific information
        --multimodal
        # --first-content   # add or remove depending what is content/style (order of blocks: positions/rotations/hues)

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
