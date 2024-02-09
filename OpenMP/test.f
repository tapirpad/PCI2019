        Program main
        use omp_lib !(or: include “omp_lib.h”)
        
        integer :: id, nthreads
        !$OMP PARALLEL PRIVATE(id)
        
        id = omp_get_thread_num()
        write (*,*) "Hello World from thread", id
        
        !$OMP BARRIER
        
        if ( id == 0 ) then
            nthreads = omp_get_num_threads()
            write (*,*) "Total threads=",nthreads
        end if
        
        !$OMP END PARALLEL
        
        End program
    
