
!Filename: schedule.f90
 
      program schedule
      use omp_lib

      integer id, nthreads
      real  A(20), B(20)

      do i = 1, 20
        A(i) = i * 1.0
      enddo

!$OMP PARALLEL DEFAULT(SHARED) PRIVATE(i,id)

      id = OMP_GET_THREAD_NUM()
      if (id .eq. 0) then
        nthreads = OMP_GET_NUM_THREADS()
        write(*,*) 'Total number of threads =', nthreads
      end if

      if (id .eq. 0) write(*,*)'======= Default static scheduling ======'
!$OMP DO
      do i = 1, 20
        B(i) = A(i) + 100.0
        WRITE(*,*) "thread ", id, " worked on index ", i
      enddo
!$OMP END DO 

      if (id .eq. 0) write(*,*)'======= static,2 scheduling ======'
!$OMP DO SCHEDULE(STATIC,2)
      do i = 1, 20
        B(i) = A(i) + 100.0
        WRITE(*,*) "thread ", id, " worked on index ", i
      enddo
!$OMP END DO 

      if (id .eq. 0) write(*,*)'======= dynamic,3 scheduling ======'
!$OMP DO SCHEDULE(DYNAMIC,3)
      do i = 1, 20
        B(i) = A(i) + 100.0
        WRITE(*,*) "thread ", id, " worked on index ", i
      enddo
!$OMP END DO NOWAIT

!$OMP END PARALLEL

      end
