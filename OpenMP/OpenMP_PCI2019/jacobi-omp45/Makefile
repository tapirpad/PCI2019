FC=ftn

all: cray-acc

intel:
	$(FC) -openmp jacobi.f -o j.intel

cray:
	$(FC) -homp jacobi.f -o j.cray

intel-acc:
	$(FC) -qopenmp jacobi-accel.f -o jacc.intel

intel-acc-host:
	$(FC) -qopenmp-offload=host -qopenmp jacobi-accel.f -o jacc.host.intel

cray-acc:
	$(FC) -m 4 -homp jacobi-accel.f -o jacc.cray

cray-acc-host:
	$(FC) -homp jacobi-accel.f -o jacc.host.cray

pgi-openacc:
	$(FC) -acc jacobi-openacc.f -o j.openacc.pgi


clean:
	rm -f j.cray j.intel jacc.cray jacc.intel jacc.host.intel \
    jacc.host.cray j.openacc.pgi *.cub *.ptx *.o
