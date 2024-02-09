/* filename: hello_world.c */

#include <omp.h>
#include <stdio.h>
#include <stdlib.h>
 
int main (int argc, char *argv[]) {
  int th_id, nthreads;
  #pragma omp parallel private(th_id)
  {
    th_id = omp_get_thread_num();
    printf("Hello from thread %d\n", th_id);
    printf("World from thread %d\n", th_id);
    #pragma omp barrier
    if ( th_id == 0 ) {
      nthreads = omp_get_num_threads();
      printf("Total number of threads=%d\n",nthreads);
    }
  }
}
