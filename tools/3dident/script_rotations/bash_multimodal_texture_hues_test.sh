#!/bin/bash 
#SBATCH -o /cluster/work/vogtlab/Group/abizeul/cow_rotations.out
#SBATCH --time=24:00:00
#SBATCH -p gpu
#SBATCH --gres=gpu:rtx2080ti:1
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=10G
#SBATCH --array=0-10

DIR_EXPERIMENT="$PWD/runs/tmp"  # NOTE: experiment logs are written here

############# PLEASE CHANGE THE FOLLOWING PARAMETERS ###############
LD_LIBRARY_PATH="/cluster/home/abizeul/software/anaconda/envs/kugelen/lib/:$LD_LIBRARY_PATH"
CONDA_PATH=/cluster/home/abizeul/software/anaconda/etc/profile.d/conda.sh 
SCRIPT_DIR=/cluster/home/abizeul/cl-ica/tools/3dident
BLENDER_DIR=/cluster/home/abizeul/software/blender-2.90.1-linux64/blender
#####################################################################
#j=$(expr $SLURM_ARRAY_TASK_ID % 10)
#object=$(expr $SLURM_ARRAY_TASK_ID / 10)
j=$SLURM_ARRAY_TASK_ID
object=1
for (( i=0; i<3; i++ ))
do
    if [[$object -eq 0]]
    then
        OBJECT="Teapot"
    fi 
    if [[$object -eq 1]]
    then
        OBJECT="Cow"
    fi 
    if [[$object -eq 2]]
    then
        OBJECT="Head"
    fi 
    if [[$object -eq 3]]
    then
        OBJECT="Dragon"
    fi 
    if [[$object -eq 4]]
    then
        OBJECT="Armardillo"
    fi 
    if [[$object -eq 5]]
    then
        OBJECT="Bunny"
    fi 
    if [[$object -eq 6]]
    then
        OBJECT="Horse"
    fi 
    DATA_NAME="mydata_fixing_rotation_$OBJECT"

    if [[$i -eq 0]]
    then
        DIR_DATA="/cluster/work/vogtlab/Group/abizeul/$DATA_NAME/train"
        N_POINTS=200000  # if test/validation fix this to 10 000, for train fix this to 250 000  
    fi

    if [[$i -eq 1]]
    then
        DIR_DATA="/cluster/work/vogtlab/Group/abizeul/$DATA_NAME/test"
        N_POINTS=10000  # if test/validation fix this to 10 000, for train fix this to 250 000  
    fi

    if [[$i -eq 2]]
    then
        DIR_DATA="/cluster/work/vogtlab/Group/abizeul/$DATA_NAME/validation"
        N_POINTS=10000  # if test/validation fix this to 10 000, for train fix this to 250 000  
    fi

    N_BATCHES=10
    mkdir -p ${DIR_DATA}

    source ${CONDA_PATH}
    conda activate kugelen

    cd ${SCRIPT_DIR}

    if [[ $j -eq 0 ]] 
    then
        python generate_clevr_dataset_latents.py --output-folder ${DIR_DATA} --n-points ${N_POINTS} --non-periodic-rotation-and-color --deterministic --all-hues --multimodal
    fi

    MATERIAL="MyMetal"
    if [[ $j -ge 5 ]] 
    then
        MATERIAL="Rubber"
    fi
    echo $MATERIAL

    ${BLENDER_DIR} -noaudio --background --python generate_clevr_dataset_images.py --use-gpu --output-folder ${DIR_DATA} --n-batches 10 --batch-index ${j} --material-names ${MATERIAL} --no_range_change --shape-names ${OBJECT}

done

#zip -r "$DIR_DATA.zip" ${DIR_DATA}
#scp "$DIR_DATA.zip" "${DIR_ZIP}/${DATA_NAME}.zip"

