#!/bin/bash 
#SBATCH --time=120:00:00
#SBATCH -p gpu
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=10G
#SBATCH --array=0-10
#SBATCH -w gpu-biomed-06

#SBATCH -o /cluster/work/vogtlab/Group/abizeul/newobject_rotations.out


DIR_EXPERIMENT="$PWD/runs/tmp"  # NOTE: experiment logs are written here
# #SBATCH --exclude=gpu-biomed-[16-21]
############# PLEASE CHANGE THE FOLLOWING PARAMETERS ###############
TMP=/scratch
LD_LIBRARY_PATH="/cluster/home/abizeul/software/anaconda/envs/kugelen/lib/:$LD_LIBRARY_PATH"
CONDA_PATH=/cluster/home/abizeul/software/anaconda/etc/profile.d/conda.sh 
SCRIPT_DIR=/cluster/home/abizeul/alice-clica/cl-ica/tools/3dident
BLENDER_DIR=/cluster/home/abizeul/software/blender-2.90.1-linux64/blender
#####################################################################



#j=$(expr $SLURM_ARRAY_TASK_ID % 10)
#object=$(expr $SLURM_ARRAY_TASK_ID / 10)
j=$SLURM_ARRAY_TASK_ID
object=6
for (( i=0; i<3; i++ ))
do
    if [[ $object -eq 0 ]]
    then
        OBJECT="Teapot"
    fi 
    if [[ $object -eq 1 ]]
    then
        OBJECT="Cow"
    fi 
    if [[ $object -eq 2 ]]
    then
        OBJECT="Head"
    fi 
    if [[ $object -eq 3 ]]
    then
        OBJECT="Dragon"
    fi 
    if [[ $object -eq 4 ]]
    then
        OBJECT="Armardillo"
    fi 
    if [[ $object -eq 5 ]]
    then
        OBJECT="Bunny"
    fi 
    if [[ $object -eq 6 ]]
    then
        OBJECT="Horse"
    fi 
    DATA_NAME="mydata_fixing_rotation_$OBJECT"
    ROOT_FOLDER="${TMP}/${DATA_NAME}"
    UNZIPPED_FOLDER="/cluster/work/vogtlab/Group/abizeul/${DATA_NAME}"

    if [[ $i -eq 0 ]]
    then
        DIR_DATA="${ROOT_FOLDER}/train"
        mkdir -p ${DIR_DATA}
        N_POINTS=200000  # if test/validation fix this to 10 000, for train fix this to 250 000  
        if [[ ! -f "${ROOT_FOLDER}/train/raw_latents.npy" ]]
        then
            scp "${UNZIPPED_FOLDER}/train/raw_latents.npy" "${ROOT_FOLDER}/train/raw_latents.npy"
            scp "${UNZIPPED_FOLDER}/train/latents.npy" "${ROOT_FOLDER}/train/latents.npy"
        fi
    fi

    if [[ $i -eq 1 ]]
    then
        DIR_DATA="${ROOT_FOLDER}/test"
        mkdir -p ${DIR_DATA}
        N_POINTS=10000  # if test/validation fix this to 10 000, for train fix this to 250 000  
        if [[ ! -f "${ROOT_FOLDER}/test/raw_latents.npy" ]]
        then
            scp "${UNZIPPED_FOLDER}/test/raw_latents.npy" "${ROOT_FOLDER}/test/raw_latents.npy"
            scp "${UNZIPPED_FOLDER}/test/latents.npy" "${ROOT_FOLDER}/test/latents.npy"
        fi
    fi

    if [[ $i -eq 2 ]]
    then
        DIR_DATA="${ROOT_FOLDER}/validation"
        mkdir -p ${DIR_DATA}
        N_POINTS=10000  # if test/validation fix this to 10 000, for train fix this to 250 000 
        if [[ ! -f "${ROOT_FOLDER}/validation/raw_latents.npy" ]]
        then 
            scp "${UNZIPPED_FOLDER}/validation/raw_latents.npy" "${ROOT_FOLDER}/validation/raw_latents.npy"
            scp "${UNZIPPED_FOLDER}/validation/latents.npy" "${ROOT_FOLDER}/validation/latents.npy"
        fi
    fi


    N_BATCHES=8

    source ${CONDA_PATH}
    conda activate kugelen

    cd ${SCRIPT_DIR}
    echo $i
    echo $j
    #if [[ $j -eq 0 ]] 
    #then
    #    python generate_clevr_dataset_latents.py --output-folder ${DIR_DATA} --n-points ${N_POINTS} --non-periodic-rotation-and-color --deterministic --all-hues --multimodal
    #fi

    MATERIAL="MyMetal"
    if [[ $j -ge 5 ]] 
    then
        MATERIAL="Rubber"
    fi
    echo $MATERIAL

    ${BLENDER_DIR} -noaudio --background --python generate_clevr_dataset_images.py --use-gpu --output-folder ${DIR_DATA} --n-batches 10 --batch-index ${j} --material-names ${MATERIAL} --no_range_change --shape-names ${OBJECT}

done

zip -r "${ROOT_FOLDER}.zip" ${ROOT_FOLDER}
scp "${ROOT_FOLDER}.zip" "/cluster/work/vogtlab/Group/abizeul/${DATA_NAME}.zip"

ls ${ROOT_FOLDER}/train/images/ | wc -l 
ls ${ROOT_FOLDER}/test/images/ | wc -l 
ls ${ROOT_FOLDER}/validation/images/ | wc -l 

#rm -r ${ROOT_FOLDER}
#rm "${ROOT_FOLDER}.zip"

