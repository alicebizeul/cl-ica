#!/bin/bash 
#SBATCH -o /cluster/work/vogtlab/Group/abizeul/multimodal_texture_positions_firstcontent_train.out
#SBATCH --time=80:00:00
#SBATCH -p gpu
#SBATCH --gres=gpu:rtx2080ti:1
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=10G

DIR_EXPERIMENT="$PWD/runs/tmp"  # NOTE: experiment logs are written here
LD_LIBRARY_PATH="/cluster/home/abizeul/software/anaconda/envs/kugelen/lib/:$LD_LIBRARY_PATH"

source /cluster/home/abizeul/software/anaconda/etc/profile.d/conda.sh 
conda activate kugelen

cd /cluster/home/abizeul/cl-ica/tools/3dident
DIR_DATA="/cluster/work/vogtlab/Group/abizeul/mydata_positions_firstcontent"

python generate_clevr_dataset_latents.py --output-folder ${DIR_DATA} --n-points 250000 --non-periodic-rotation-and-color --deterministic --all-positions --multimodal --first_content 
/cluster/home/abizeul/software/blender-2.90.1-linux64/blender -noaudio --background --python generate_clevr_dataset_images.py --use-gpu --output-folder ${DIR_DATA} --n-batches 10 --batch-index 0 --material-names "MyMetal" --no_range_change
/cluster/home/abizeul/software/blender-2.90.1-linux64/blender -noaudio --background --python generate_clevr_dataset_images.py --use-gpu --output-folder ${DIR_DATA} --n-batches 10 --batch-index 1 --material-names "MyMetal" --no_range_change
/cluster/home/abizeul/software/blender-2.90.1-linux64/blender -noaudio --background --python generate_clevr_dataset_images.py --use-gpu --output-folder ${DIR_DATA} --n-batches 10 --batch-index 2 --material-names "MyMetal" --no_range_change
/cluster/home/abizeul/software/blender-2.90.1-linux64/blender -noaudio --background --python generate_clevr_dataset_images.py --use-gpu --output-folder ${DIR_DATA} --n-batches 10 --batch-index 3 --material-names "MyMetal" --no_range_change
/cluster/home/abizeul/software/blender-2.90.1-linux64/blender -noaudio --background --python generate_clevr_dataset_images.py --use-gpu --output-folder ${DIR_DATA} --n-batches 10 --batch-index 4 --material-names "MyMetal" --no_range_change
/cluster/home/abizeul/software/blender-2.90.1-linux64/blender -noaudio --background --python generate_clevr_dataset_images.py --use-gpu --output-folder ${DIR_DATA} --n-batches 10 --batch-index 5 --material-names "Rubber" --no_range_change
/cluster/home/abizeul/software/blender-2.90.1-linux64/blender -noaudio --background --python generate_clevr_dataset_images.py --use-gpu --output-folder ${DIR_DATA} --n-batches 10 --batch-index 6 --material-names "Rubber" --no_range_change
/cluster/home/abizeul/software/blender-2.90.1-linux64/blender -noaudio --background --python generate_clevr_dataset_images.py --use-gpu --output-folder ${DIR_DATA} --n-batches 10 --batch-index 7 --material-names "Rubber" --no_range_change
/cluster/home/abizeul/software/blender-2.90.1-linux64/blender -noaudio --background --python generate_clevr_dataset_images.py --use-gpu --output-folder ${DIR_DATA} --n-batches 10 --batch-index 8 --material-names "Rubber" --no_range_change
/cluster/home/abizeul/software/blender-2.90.1-linux64/blender -noaudio --background --python generate_clevr_dataset_images.py --use-gpu --output-folder ${DIR_DATA} --n-batches 10 --batch-index 9 --material-names "Rubber" --no_range_change

zip -r "/cluster/work/vogtlab/Group/abizeul/mydata_multimodal_texture_positions_train_firstcontent.zip" "/cluster/work/vogtlab/Group/abizeul/mydata_positions_firstcontent"
mv "/cluster/work/vogtlab/Group/abizeul/mydata_multimodal_texture_positions_train_firstcontent.zip" "/cluster/work/vogtlab/Group/abizeul/3DIdent/mydata_multimodal_texture_positions_train_firstcontent.zip"

