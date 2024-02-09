program auc_serial
  implicit none
  integer :: i, ntot 
  character(64) :: arg
  double precision :: dx, width, x, y, a
  call get_command_argument(1,arg)
  read (arg,'(i40)') ntot
  dx = 3.0/ntot
  width = 3.0
  x = 0.0
  a = 0.0
  do i = 1,ntot
      y = 0.7*x**3 - 2*x**2 + 4
      a = a + y*dx
      x = x + dx
  end do
  print *, "The area is " , a
end program
