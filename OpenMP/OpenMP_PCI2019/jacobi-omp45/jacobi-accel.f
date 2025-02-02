      program main 
************************************************************
* program to solve a finite difference 
* discretization of Helmholtz equation :  
* (d2/dx2)u + (d2/dy2)u - alpha u = f 
* using Jacobi iterative method. 
*
* Modified: Sanjiv Shah,       Kuck and Associates, Inc. (KAI), 1998
* Author:   Joseph Robicheaux, Kuck and Associates, Inc. (KAI), 1998
* 
* Directives are used in this code to achieve paralleism. 
* All do loops are parallized with default 'static' scheduling.
* 
* Input :  n - grid dimension in x direction 
*          m - grid dimension in y direction
*          alpha - Helmholtz constant (always greater than 0.0)
*          tol   - error tolerance for iterative solver
*          relax - Successice over relaxation parameter
*          mits  - Maximum iterations for iterative solver
*
* On output 
*       : u(n,m) - Dependent variable (solutions)
*       : f(n,m) - Right hand side function 
*************************************************************

      implicit none 

      integer n,m,mits 
      double precision tol,relax,alpha 

      common /idat/ n,m,mits
      common /fdat/tol,alpha,relax
* 
* Read info 
* 
      write(*,*) "Input n,m - grid dimension in x,y direction " 
      read(5,*) n,m 
      write(*,*) "Input alpha - Helmholts constant " 
      read(5,*) alpha
      write(*,*) "Input relax - Successive over-relaxation parameter"
      read(5,*) relax 
      write(*,*) "Input tol - error tolerance for iterative solver" 
      read(5,*) tol 
      write(*,*) "Input mits - Maximum iterations for solver" 
      read(5,*) mits

*
* Calls a driver routine 
* 
      call driver () 

      end 

      subroutine driver ( ) 
*************************************************************
* Subroutine driver () 
* This is where the arrays are allocated and initialzed. 
*
* Working varaibles/arrays 
*     dx  - grid spacing in x direction 
*     dy  - grid spacing in y direction 
*************************************************************
      use omp_lib
      implicit none 

      integer n,m,mits,mtemp 
      double precision tol,relax,alpha 

      common /idat/ n,m,mits,mtemp
      common /fdat/tol,alpha,relax

      double precision u(n,m),f(n,m),dx,dy

      integer nthreads, nteams

      double precision omptstart, omptend
      double precision omptotaltstart, omptotaltend
      double precision omptotaltime, ompjacobitime
      double precision ompinittime, omperrortime

!$omp target
!$omp teams
!$omp parallel
      nthreads = omp_get_num_threads()
      nteams = omp_get_num_teams()
!$omp end parallel
!$omp end teams
!$omp end target

      write(*,'(A,I5,A,I5)') 'target teams parallel: threads=',
     & nthreads, ', teams=', nteams

!$omp target
!$omp parallel
      nthreads = omp_get_num_threads()
      nteams = omp_get_num_teams()
!$omp end parallel
!$omp end target

      write(*,'(A,I5,A,I5)') 'target parallel: threads=',
     & nthreads, ', teams=', nteams

!$omp parallel
      nthreads = omp_get_num_threads()
      nteams = omp_get_num_teams()
!$omp end parallel

      write(*,'(A,I5,A,I5)') 'parallel: threads=',
     & nthreads, ', teams=', nteams

      omptotaltstart = omp_get_wtime ()

* Initialize data
      omptstart = omp_get_wtime ()
      call initialize (n,m,alpha,dx,dy,u,f)
      omptend = omp_get_wtime ()
      ompinittime = omptend - omptstart

* Solve Helmholtz equation

      omptstart = omp_get_wtime ()
      call jacobi (n,m,dx,dy,alpha,relax,u,f,tol,mits)
      omptend = omp_get_wtime ()
      ompjacobitime = omptend - omptstart

* Check error between exact solution

      omptstart = omp_get_wtime ()
      call  error_check (n,m,alpha,dx,dy,u,f)
      omptend = omp_get_wtime ()
      omperrortime = omptend - omptstart

      omptotaltend = omp_get_wtime ()
      omptotaltime = omptotaltend - omptotaltstart

      write(*,*) ''
      write(*,*) ''
      write(*,*) 'Timing statistics'
      write(*,*) '=================='
      write(*,*) 'header, ompinit, ompjacobi, omperror, omptotal'
      write(*,*) 'omp, ', ompinittime,', ', ompjacobitime,
     &', ',omperrortime,', ', omptotaltime
      write(*,100) 'ompt, ', ompinittime,', ', ompjacobitime,
     &', ',omperrortime,', ', omptotaltime
      write(*,*) ''
100   format (A,3(F12.8,A),F12.8)

      return 
      end 

      subroutine initialize (n,m,alpha,dx,dy,u,f) 
******************************************************
* Initializes data 
* Assumes exact solution is u(x,y) = (1-x^2)*(1-y^2)
*
******************************************************

      implicit none 
     
      integer n,m
      double precision u(n,m),f(n,m),dx,dy,alpha
      
      integer i,j, xx,yy
      double precision PI 
      parameter (PI=3.1415926)

      dx = 2.0 / (n-1)
      dy = 2.0 / (m-1)


* Initilize initial condition and RHS

!$omp target
!$omp teams distribute parallel do private(xx,yy)
      do j = 1,m
         do i = 1,n
            xx = -1.0 + dx * dble(i-1)        ! -1 < x < 1
            yy = -1.0 + dy * dble(j-1)        ! -1 < y < 1
            u(i,j) = 0.0 
            f(i,j) = -alpha *(1.0-xx*xx)*(1.0-yy*yy) 
     &           - 2.0*(1.0-xx*xx)-2.0*(1.0-yy*yy)
         enddo
      enddo
!$omp end teams distribute parallel do
!$omp end target

      return 
      end 

      subroutine jacobi (n,m,dx,dy,alpha,omega,u,f,tol,maxit)
******************************************************************
* Subroutine HelmholtzJ
* Solves poisson equation on rectangular grid assuming : 
* (1) Uniform discretization in each direction, and 
* (2) Dirichlect boundary conditions 
* 
* Jacobi method is used in this routine 
*
* Input : n,m   Number of grid points in the X/Y directions 
*         dx,dy Grid spacing in the X/Y directions 
*         alpha Helmholtz eqn. coefficient 
*         omega Relaxation factor 
*         f(n,m) Right hand side function 
*         u(n,m) Dependent variable/Solution
*         tol    Tolerance for iterative solver 
*         maxit  Maximum number of iterations 
*
* Output : u(n,m) - Solution 
*****************************************************************
      use omp_lib
      implicit none 
      integer n,m,maxit
      double precision dx,dy,f(n,m),u(n,m),alpha, tol,omega
*
* Local variables 
* 
      integer i,j,k,k_local 
      double precision error,resid,rsum,ax,ay,b,brecip
      double precision error_local, uold(n,m)

      real ta,tb,tc,td,te,ta1,ta2,tb1,tb2,tc1,tc2,td1,td2
      real te1,te2
      real second
      external second
      double precision t1, t2
*
* Initialize coefficients 
      ax = 1.0/(dx*dx) ! X-direction coef 
      ay = 1.0/(dy*dy) ! Y-direction coef
      b  = -2.0/(dx*dx)-2.0/(dy*dy) - alpha ! Central coeff  
      brecip = 1/b

      error = 0
      k = 1

      t1 = omp_get_wtime()

!$omp target data map(to:f) map(tofrom:u) map(alloc:uold)
      do while (k.le.maxit .and. (error.gt.tol .or. k .eq. 1))

         error = 0.0    

* Copy new solution into old
!$omp target
!$omp teams distribute parallel do
         do j=1,m
            do i=1,n
               uold(i,j) = u(i,j) 
            enddo
         enddo
!$omp end teams distribute parallel do
!$omp end target

* Compute stencil, residual, & update

!$omp target map(tofrom:error)
!$omp teams distribute parallel do reduction(+:error) 
         do j = 2,m-1
!$omp simd private(resid) reduction(+:error)
            do i = 2,n-1 
*     Evaluate residual 
               resid = (ax*(uold(i-1,j) + uold(i+1,j))
     &                + ay*(uold(i,j-1) + uold(i,j+1))
     &                - f(i,j))*brecip + uold(i,j)
* Update solution 
               u(i,j) = uold(i,j) - omega * resid
* Accumulate residual error
               error = error + resid*resid 
            end do
         enddo
!$omp end teams distribute parallel do
!$omp end target

* Error check 

         k = k + 1

         error = sqrt(error)/dble(n*m)
*
      enddo                     ! End iteration loop 
!$omp end target data
      t2 = omp_get_wtime()
      k = k - 1 !---fix iteration count.
*
      print *, 'Total Number of Iterations ', k
      print *, 'Residual                   ', error
      print *, 'Walltime                   ', t2-t1
      print *, 'GF/sec                     ',
     &         m*n*k*8*1e-9/(t2-t1)
      print *, 'GB/sec                     ',
     &         m*n*k*8*9*1e-9/(t2-t1)

!---Titan/Chester per-socket mem BW: 25.6 GB/sec
!---Titan/Chester per-core max flop rate: 8.8 GF/sec

      return 
      end 

      subroutine error_check (n,m,alpha,dx,dy,u,f) 
      implicit none 
************************************************************
* Checks error between numerical and exact solution 
*
************************************************************ 
     
      integer n,m
      double precision u(n,m),f(n,m),dx,dy,alpha 
      
      integer i,j
      double precision xx,yy,temp,error 

      dx = 2.0 / (n-1)
      dy = 2.0 / (m-1)
      error = 0.0 

!$omp target map(tofrom:error)
!$omp teams distribute parallel do reduction(+:error)
      do j = 1,m
!$omp simd private(xx,yy,temp) reduction(+:error)
         do i = 1,n
            xx = -1.0d0 + dx * dble(i-1)
            yy = -1.0d0 + dy * dble(j-1)
            temp  = u(i,j) - (1.0-xx*xx)*(1.0-yy*yy)
            error = error + temp*temp 
         enddo
      enddo
!$omp end teams distribute parallel do
!$omp end target
  
      error = sqrt(error)/dble(n*m)

      print *, 'Solution Error             ',error

      return 
      end 
