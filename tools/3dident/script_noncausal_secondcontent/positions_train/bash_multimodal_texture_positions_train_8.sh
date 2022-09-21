#!/bin/bash 
#SBATCH -oo /cluster/work/vogtlab/Group/abizeul/multimodal_texture_positions_train.out
#SBATCH -p gpu
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=10G

DIR_EXPERIMENT="$PWD/runs/tmp"  # NOTE: experiment logs are written here

############# PLEASE CHANGE THE FOLLOWING PARAMETERS ###############
CONDA_PATH="/cluster/home/abizeul/software/anaconda/etc/profile.d/conda.sh"
SCRIPT_DIR=/cluster/home/abizeul/alice-clica/cl-ica/tools/3dident
BLENDER_DIR=/cluster/home/abizeul/software/blender-2.90.1-linux64/blender
DATA_NAME="mydata_multimodal_texture_positions/3dident/train"  # include mention to test/val/train, MS and C/S settings
DIR_DATA="/cluster/home/abizeul/$DATA_NAME"
N_POINTS=250000  # if test/validation fix this to 10 000, for train fix this to 250 000
#####################################################################

N_BATCHES=10
mkdir -p ${DIR_DATA}

source ${CONDA_PATH}
conda activate alice

cd ${SCRIPT_DIR}

#python generate_clevr_dataset_latents.py --output-folder ${DIR_DATA} --n-points ${N_POINTS} --non-periodic-rotation-and-color --deterministic --all-positions --multimodal
i=8
MATERIAL="MyMetal"
if [[ $i -ge 5 ]] 
then
    MATERIAL="Rubber"
fi
echo $MATERIAL

${BLENDER_DIR} -noaudio --background --python generate_clevr_dataset_images.py --use-gpu --output-folder ${DIR_DATA} --n-batches 10 --batch-index ${i} --material-names ${MATERIAL} --no_range_change

