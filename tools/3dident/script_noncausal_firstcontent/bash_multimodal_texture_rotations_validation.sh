#BSUB -oo /cluster/work/grlab/projects/projects2022-identifiability/multimodal_texture_rotations_val.out
#BSUB -W 4:00
#BSUB -n 4
#BSUB -R "rusage[ngpus_excl_p=1,mem=10000,scratch=10000]"
#BSUB -R "select[gpu_mtotal0>=10240]"

if command -v module &> /dev/null; then
    echo "Loading Modules..."
    module load cuda/10.0.130
    module load cudnn/7.5
    module load openblas/0.2.19
fi

# define TMPDIR, if it's empty
if [[ -z "$TMPDIR" ]]; then
    TMPDIR="/tmp"
fi
mkdir "$TMPDIR/mydata"
DATA_TMPDIR="$TMPDIR/mydata"
echo "TMPDIR: $TMPDIR"

DIR_EXPERIMENT="$PWD/runs/tmp"  # NOTE: experiment logs are written here
DIR_FID="$TMPDIR"
LD_LIBRARY_PATH="/cluster/home/alpace/software/anaconda/envs/offlineRL/lib/:$LD_LIBRARY_PATH"

source /cluster/home/alpace/software/anaconda/etc/profile.d/conda.sh 
conda activate offlineRL

cd /cluster/home/alpace/Documents/cl-ica/tools/3dident

python generate_clevr_dataset_latents.py --output-folder "$TMPDIR/mydata" --n-points 10000 --non-periodic-rotation-and-color --deterministic --all-rotations --multimodal --first_content 
/cluster/work/grlab/projects/projects2022-identifiability/blender-2.90.1-linux64/blender -noaudio --background --python generate_clevr_dataset_images.py --use-gpu --output-folder "$TMPDIR/mydata" --n-batches 10 --batch-index 0 --material-names "MyMetal" --no_range_change
/cluster/work/grlab/projects/projects2022-identifiability/blender-2.90.1-linux64/blender -noaudio --background --python generate_clevr_dataset_images.py --use-gpu --output-folder "$TMPDIR/mydata" --n-batches 10 --batch-index 1 --material-names "MyMetal" --no_range_change
/cluster/work/grlab/projects/projects2022-identifiability/blender-2.90.1-linux64/blender -noaudio --background --python generate_clevr_dataset_images.py --use-gpu --output-folder "$TMPDIR/mydata" --n-batches 10 --batch-index 2 --material-names "MyMetal" --no_range_change
/cluster/work/grlab/projects/projects2022-identifiability/blender-2.90.1-linux64/blender -noaudio --background --python generate_clevr_dataset_images.py --use-gpu --output-folder "$TMPDIR/mydata" --n-batches 10 --batch-index 3 --material-names "MyMetal" --no_range_change
/cluster/work/grlab/projects/projects2022-identifiability/blender-2.90.1-linux64/blender -noaudio --background --python generate_clevr_dataset_images.py --use-gpu --output-folder "$TMPDIR/mydata" --n-batches 10 --batch-index 4 --material-names "MyMetal" --no_range_change
/cluster/work/grlab/projects/projects2022-identifiability/blender-2.90.1-linux64/blender -noaudio --background --python generate_clevr_dataset_images.py --use-gpu --output-folder "$TMPDIR/mydata" --n-batches 10 --batch-index 5 --material-names "Rubber" --no_range_change
/cluster/work/grlab/projects/projects2022-identifiability/blender-2.90.1-linux64/blender -noaudio --background --python generate_clevr_dataset_images.py --use-gpu --output-folder "$TMPDIR/mydata" --n-batches 10 --batch-index 6 --material-names "Rubber" --no_range_change
/cluster/work/grlab/projects/projects2022-identifiability/blender-2.90.1-linux64/blender -noaudio --background --python generate_clevr_dataset_images.py --use-gpu --output-folder "$TMPDIR/mydata" --n-batches 10 --batch-index 7 --material-names "Rubber" --no_range_change
/cluster/work/grlab/projects/projects2022-identifiability/blender-2.90.1-linux64/blender -noaudio --background --python generate_clevr_dataset_images.py --use-gpu --output-folder "$TMPDIR/mydata" --n-batches 10 --batch-index 8 --material-names "Rubber" --no_range_change
/cluster/work/grlab/projects/projects2022-identifiability/blender-2.90.1-linux64/blender -noaudio --background --python generate_clevr_dataset_images.py --use-gpu --output-folder "$TMPDIR/mydata" --n-batches 10 --batch-index 9 --material-names "Rubber" --no_range_change


zip -r "$TMPDIR/mydata.zip" "$TMPDIR/mydata"
scp "$TMPDIR/mydata.zip" "/cluster/work/grlab/projects/projects2022-identifiability/mydata_multimodal_texture_rotations_val_firstcontent.zip"

