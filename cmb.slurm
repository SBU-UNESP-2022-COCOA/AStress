#!/bin/bash

#SBATCH --job-name=cmb
#SBATCH --output=cmb-%j.out
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4
#SBATCH --cpus-per-task=5
#SBATCH --partition=long-28core
#SBATCH --mail-type=ALL
#SBATCH --mail-user=kunhao.zhong@stonybrook.edu
#SBATCH -t 48:00:00

# Clear the environment from any previously loaded modules
module purge > /dev/null 2>&1

source /gpfs/home/kuzhong/.conda/etc/profile.d/conda.sh

echo Running on host `hostname`
echo Time is `date`
echo Directory is `pwd`
echo Slurm job NAME is $SLURM_JOB_NAME
echo Slurm job ID is $SLURM_JOBID
echo Number of chains is $SLURM_NTASKS

cd $SLURM_SUBMIT_DIR
conda activate cocoa
source start_cocoa

export OMP_PROC_BIND=close
if [ -n "$SLURM_CPUS_PER_TASK" ]; then
  export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
else
  export OMP_NUM_THREADS=1
fi

mpirun -n ${SLURM_NTASKS} --report-bindings --mca btl tcp,self --bind-to core --map-by numa:pe=${OMP_NUM_THREADS} cobaya-run ./projects/AStress/cmb.yaml -r