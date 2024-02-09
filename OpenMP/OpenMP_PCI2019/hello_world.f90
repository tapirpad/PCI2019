program hello_world
use omp_lib
integer:: id, nthreads
  !$omp parallel private(id)
  id = omp_get_thread_num()
  write (*,*) 'Hello from thread', id
  write (*,*) 'World from thread', id
  !$omp barrier
  if ( id == 0 ) then
    nthreads = omp_get_num_threads()
    write (*,*) 'Total number of threads=', nthreads
  end if
  !$omp end parallel
end program
