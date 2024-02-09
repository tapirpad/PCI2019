program jacobi_omp

! Solve [(d/dx)2 + (d/dy)2] u(x,y) = f(x,y) for u(x,y) in a rectangular
! domain: 0 < x < 1 and 0 < y < 1.

  implicit none
  real, allocatable :: u(:,:), unew(:,:), f(:,:)
  integer :: ngrid         ! number of grid cells along each axis
  integer :: n             ! number of cells: n = ngrid - 1
  integer :: maxiter       ! max number of Jacobi iterations
  real    :: tol           ! convergence tolerance threshold
  real    :: omega         ! relaxation parameter
  integer i, j, k
  real    h, utmp, diffnorm

! Read in problem and solver parameters.

  call read_params(ngrid,maxiter,tol,omega)

  n = ngrid - 1

! Allocate memory for arrays.

  allocate(u(0:n,0:n), unew(0:n,0:n), f(0:n,0:n))

! Initialize f, u(0,*), u(n:*), u(*,0), and u(*,n).

  call init_fields(u,f,n)

! Main solver loop.

  h = 1.0 / n

  do k=1,maxiter
!$omp parallel do private(utmp)
    do j=1,n-1
      do i=1,n-1
        utmp = 0.25 * ( u(i+1,j) + u(i-1,j) &
             + u(i,j+1) + u(i,j-1) &
             - h * h * f(i,j) )
        unew(i,j) = omega * utmp + (1. - omega) * u(i,j)
      enddo
    enddo
!$omp end parallel do

    call set_bc(unew,n)

!   Compute the difference between unew and u.

    call compute_diff(u,unew,n,diffnorm)

!    print *, k, diffnorm

!   Make the new value the old value for the next iteration.

!$omp parallel do
    do j=0,n
      u(:,j) = unew(:,j)
    end do
!$omp end parallel do

!   Check for convergence of unew to u. If converged, exit the loop.

    if (diffnorm <= tol) exit
  enddo

  deallocate(u, unew, f)

end program

!----------------------------------------------------------------------

subroutine read_params(ngrid,maxiter,tol,omega)

  implicit none
  integer ngrid, maxiter
  real    tol, omega
  namelist /params/ ngrid, maxiter, tol, omega

! Default values

  ngrid   = 1000
  maxiter = 1000
  tol     = 1.e-3
  omega   = 0.75

  open(10,file='indata')
  read(10,nml=params)
  close(10)

end subroutine read_params

!----------------------------------------------------------------------

subroutine init_fields(u,f,n)

  implicit none
  integer n
  real    u(0:n,0:n), f(0:n,0:n)
  integer i, j

! RHS term:

!$omp parallel
!$omp do
  do j=0,n
    f(:,j) = 4.
  end do
!$omp end do nowait

! Initial guess:

!$omp do
  do j=0,n
    u(:,j) = 0.5
  end do
!$omp end do nowait
!$omp end parallel

! Apply the boundary conditions.

  call set_bc(u,n)

end subroutine init_fields

!----------------------------------------------------------------------

subroutine set_bc(u,n)

  implicit none
  integer n
  real    u(0:n,0:n)
  integer i, j
  real    h

  h = 1.0 / n

!$omp parallel do
  do i=0,n
    u(i,0) = (i * h)**2
    u(i,n) = (i * h)**2 + 1.
  enddo
!$omp end parallel do

!$omp parallel do
  do j=0,n
    u(0,j) = (j * h)**2
    u(n,j) = (j * h)**2 + 1.
  enddo
!$omp end parallel do

end subroutine set_bc

!----------------------------------------------------------------------

subroutine compute_diff(u,unew,n,diffnorm)

  implicit none
  integer n
  real    u(0:n,0:n), unew(0:n,0:n)
  integer i, j
  real    diffnorm

  diffnorm = 0.0

!$omp parallel do reduction(+:diffnorm)
  do j=1,n-1
    do i=1,n-1
      diffnorm = diffnorm + (unew(i,j) - u(i,j))**2
    end do
  end do
!$omp end parallel do

  diffnorm = sqrt(diffnorm)

end subroutine compute_diff
