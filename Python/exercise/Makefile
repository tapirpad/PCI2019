# Makefile for the compiled version for comparison with parallel python codes
# Ramses van Zon
# SciNetHPC, 2017-2019

TIME=time -p
MPIRUN=mpiexec
MPIRUNOPT=-n 4
RM=\rm -f
RMD=\rm -rf
CXX=g++
OPT=-O3 -march=native
LOCAL_INC?=hpcenv/include
LOCAL_LIB?=hpcenv/lib
CXXFLAGS=-I${LOCAL_INC} -DRA_SKIPINTERMEDIATE $(OPT)
LDFLAGS=-L${LOCAL_LIB} $(OPT)
LDLIBS=-lcpgplot -lpgplot -lX11 -lxcb -ldl -lXau -lgfortran
F90=gfortran
FFLAGS=-I${LOCAL_INC} $(OPT)

all: auc_serial_cpp.ex auc_serial_f90.ex diff2d_cpp.ex diff2d_f90.ex diff2dplot_f90.mod

run: run_diff2d_cpp run_diff2d_f90 run_auc_serial_cpp

.PHONY: all clean run_diff2d_cpp run_diff2d_f90 

run_auc_serial_cpp: auc_serial_cpp.ex
	$(TIME) ./$< 

run_diff2d_cpp: diff2d_cpp.ex
	$(TIME) ./$< 

run_diff2d_f90: diff2d_f90.ex
	$(TIME) ./$< 

auc_serial_cpp.o: auc_serial.cpp
	$(CXX) -c $(CXXFLAGS) -o $@ $<

auc_serial_f90.o: auc_serial.f90
	$(F90) -c $(FFLAGS) -o $@ $<

diff2d_cpp.o: diff2d.cpp diff2dparams.py diff2dplot.h
	$(CXX) -c $(CXXFLAGS) -o $@ $<

diff2d_f90.o: diff2d.f90 diff2dparams.py diff2dplot_f90.mod
	$(F90) -c $(FFLAGS) -o $@ $<

diff2dplot_f90.mod: diff2dplot_f90.o
diff2dplot_f90.o: diff2dplot.f90 pgplot90.mod
	$(F90) -c $(FFLAGS) -o $@ $<

pgplot90.mod: pgplot90.o
pgplot90.o: pgplot90.f90
	$(F90) -c $(FFLAGS) -o $@ $<

diff2dplot_cpp.o: diff2dplot.cpp
	$(CXX) -c $(CXXFLAGS) -o $@ $<

auc_serial_cpp.ex : auc_serial.o
	$(CXX) $(LDFLAGS) -o $@ $^ 

auc_serial_f90.ex : auc_serial_f90.o
	$(F90) $(LDFLAGS) -o $@ $^ $(LDLIBS)

diff2d_cpp.ex : diff2d_cpp.o diff2dplot_cpp.o
	$(CXX) $(LDFLAGS) -o $@ $^ $(LDLIBS)

diff2d_f90.ex : diff2d_f90.o diff2dplot_f90.o pgplot90.o
	$(F90) $(LDFLAGS) -o $@ $^ $(LDLIBS)

clean:
	$(RM) *.o *.ex *.mod
