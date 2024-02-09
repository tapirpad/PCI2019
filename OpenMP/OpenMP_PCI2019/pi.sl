#!/bin/bash
#SBATCH -N 1
#SBATCH -J pi
#SBATCH -C haswell
#SBATCH -o pi.out
#SBATCH -t 20:00
#SBATCH -q debug

echo "===== running pi serial code ======"
time srun -n 1 ./pi

echo "===== running pi_omp_wrong using 4 threads ======"
export OMP_NUM_THREADS=4
time srun -n 1 ./pi_omp_wrong

echo "===== running pi_omp_wrong using 8 threads ======"
export OMP_NUM_THREADS=8
time srun -n 1 ./pi_omp_wrong

echo "===== running pi_omp_spmd using 8 threads ======"
time srun -n 1 ./pi_omp_spmd

echo "===== running pi_omp_spmd_pad using 8 threads ======"
time srun -n 1 ./pi_omp_spmd_pad

echo "===== running pi_omp_critical using 8 threads ======"
time srun -n 1 ./pi_omp_critical

echo "===== running pi_omp_reduction using 8 threads ======"
time srun -n 1 ./pi_omp_reduction

echo "===== running pi_omp_task using 8 threads ======"
time srun -n 1 ./pi_omp_task
