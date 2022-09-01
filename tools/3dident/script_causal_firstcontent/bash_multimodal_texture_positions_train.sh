#!/bin/bash 
#SBATCH -o /cluster/work/vogtlab/Group/abizeul/multimodal_texture_positions_train_causal.out
#SBATCH --time=60:00:00
#SBATCH -p gpu
#SBATCH --gres=gpu:rtx2080ti:1
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=10G

DIR_EXPERIMENT="$PWD/runs/tmp"  # NOTE: experiment logs are written here


############# PLEASE CHANGE THE FOLLOWING PARAMETERS ###############
LD_LIBRARY_PATH="/cluster/home/abizeul/software/anaconda/envs/kugelen/lib/:$LD_LIBRARY_PATH"
CONDA_PATH=/cluster/home/abizeul/software/anaconda/etc/profile.d/conda.sh 
SCRIPT_DIR=/cluster/home/abizeul/cl-ica/tools/3dident
BLENDER_DIR=/cluster/home/abizeul/software/blender-2.90.1-linux64/blender
DATA_NAME="mydata_positions_train_causal_firstcontent"  # include mention to test/val/train, MS and C/S settings
DIR_DATA="/cluster/work/vogtlab/Group/abizeul/$DATA_NAME"
DIR_ZIP="/cluster/work/vogtlab/Group/abizeul/3DIdent/"
N_POINTS=250000  # if test/validation fix this to 10 000, for train fix this to 250 000
#####################################################################

N_BATCHES=10
mkdir -p ${DIR_DATA}

source ${CONDA_PATH}
conda activate kugelen

cd ${SCRIPT_DIR}

python generate_clevr_dataset_latents_causal.py --output-folder ${DIR_DATA} --n-points ${N_POINTS} --non-periodic-rotation-and-color --deterministic --all-positions --multimodal --first_content
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

zip -r "$DIR_DATA.zip" ${DIR_DATA}
scp "$DIR_DATA.zip" "${DIR_ZIP}/${DATA_NAME}.zip"