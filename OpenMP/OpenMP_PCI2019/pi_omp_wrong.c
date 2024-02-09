/* filename: pi_omp_wrong.c */
/* this is the wrong openmp version of calculating pi, without critical directive */

#include <omp.h>
#include <stdio.h>
#include <stdlib.h>

static long num_steps = 100000;
double step;
int main()
{
    int i; double x, pi, sum = 0.0;
    step = 1.0/(double) num_steps;

#pragma omp parallel private(x, sum)
{
#pragma omp for
    for (i=0;i<=num_steps; i++)
    {
       x=(i+0.5)*step;
       sum=sum+ 4.0/(1.0+x*x);
    }
    pi = pi + step * sum;
}
    printf("pi=%f\n",pi);
    return 0;
}
