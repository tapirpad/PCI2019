#!/bin/bash
#SBATCH -N 1
#SBATCH -C haswell
#SBATCH -q debug
#SBATCH -t 20:00
#PBS -o jacobi.out


echo "========running serial version ====="
time srun -n 1 ./jacobi_serial

echo "========running omp version using 8 threads ====="
export OMP_NUM_THREADS=8
time srun -n 1 ./jacobi_omp

echo "========running omp version using 16 threads ====="
export OMP_NUM_THREADS=16
time srun -n 1 ./jacobi_omp
