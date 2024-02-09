# change these three according to your environment, or load apropriate
# modules(1)
PNETCDF=/usr
MPICC=cc

CC=cc
CPPFLAGS=-I${PNETCDF}/include

PROGRAMS=array-mpiio-write \
	array-pnetcdf-write \
	array-pnetcdf-write-read

all: $(PROGRAMS)

array-mpiio-write: array-mpiio-write.c util.o
	$(MPICC) $(CFLAGS) $(CPPFLAGS) $^ -o $@

array-pnetcdf-write: array-pnetcdf-write.c util.o
	$(MPICC) $(CFLAGS) $(CPPFLAGS) -I${PNETCDF}/include $^ -o $@ -L${PNETCDF}/lib -lpnetcdf

array-pnetcdf-read: array-pnetcdf-read.c util.o
	$(MPICC) $(CFLAGS) $(CPPFLAGS) -I${PNETCDF}/include $^ -o $@ -L${PNETCDF}/lib -lpnetcdf

clean:
	rm -f *.o *.rtf *.nc $(PROGRAMS)

