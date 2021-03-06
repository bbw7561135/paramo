ifeq ($(MPI),1)
FC=h5pfc
else  #####  MPI
FC=h5fc
endif #####  MPI


# ----- definitions -----
ifeq ($(BROWN),1)
DEFS+=-DBRWN
endif


# ----- optimization level -----
ifeq ($(DBG),1)

ifeq ($(IFORT),1)
OPTIMIZATION=-g -debug all -check all -check nostack -warn all -fp-stack-check -heap-arrays \
	-ftrapuv -free
else  #####  IFORT
OPTIMIZATION=-g -Wall -ffree-form -ffree-line-length-none \
	-ffpe-trap=invalid,zero -fbacktrace -fcheck=all \
	-fbounds-check -fno-unsafe-math-optimizations -frounding-math \
	-fsignaling-nans
endif #####  IFORT

else ######  DBG

ifeq ($(IFORT),1)

ifeq ($(IFAST),1)
FASTI=-fast
else  ##### IFAST
FASTI=-O3
endif #####  IFAST

ifeq ($(IPAR),1)
PARI=-parallel
endif #####  IPAR

ifeq ($(OPENMP),1)
OMP=-qopenmp
endif #####  OPENMP

OPTIMIZATION=-free $(FASTI) $(PARI) $(OMP)

else #####  IFORT

ifeq ($(OPENMP),1)
OMP=-fopenmp
endif #####  OPENMP

OPTIMIZATION=-O3 -ftree-vectorize -funroll-all-loops -ffree-form \
	-ffree-line-length-none -fbacktrace $(OMP)

endif #####  IFORT

ifeq ($(COREI7),1)
OPTIMIZATION+=-march=corei7 -mtune=corei7
endif

ifeq ($(NATIVE),1)
OPTIMIZATION+=-march=native -mtune=native
endif

ifeq ($(BROWN),1)
OPTIMIZATION+=-arch ssse3 -mtune=corei7-avx
LIBS+=-L/usr/lib64
endif

endif #####  DBG

COPT=-c $(OPTIMIZATION) $(DEFS) $(INCL)
LOPT=$(OPTIMIZATION) $(DEFS) $(LIBS)


# -----  executables  -----
BLAZMAG=xBlazMag
TESTS=xTests
AFGLOW=xAglow
TURBLAZ=xTurBlaz
BENCH=xBenchmarking


# -----  dependencies  -----
TESTS_OBJ=misc.o params.o pwl_integ.o h5_inout.o specialf.o SRtoolkit.o \
	anaFormulae.o radiation.o dist_evol.o tests.o
BLAZMAG_OBJ=misc.o params.o pwl_integ.o h5_inout.o specialf.o SRtoolkit.o \
	anaFormulae.o radiation.o dist_evol.o blazMag.o blazMag_main.o
AFGLOW_OBJ=transformers.o misc.o params.o pwl_integ.o h5_inout.o specialf.o \
	SRtoolkit.o anaFormulae.o radiation.o pairs.o dist_evol.o Aglow_models.o \
	afterglow.o afterglow_main.o
TURBLAZ_OBJ=misc.o params.o pwl_integ.o h5_inout.o specialf.o SRtoolkit.o \
	anaFormulae.o radiation.o dist_evol.o turBlaz.o turBlaz_main.o
BENCH_OBJ=transformers.o misc.o pwl_integ.o h5_inout.o SRtoolkit.o specialf.o \
	anaFormulae.o Aglow_models.o radiation.o dist_evol.o benchmarks.o \
	benchmarking.o


# -----  rules  -----
all: $(BLAZMAG) $(TESTS) $(AFGLOW) $(TURBLAZ) $(BENCH)

# objects
constants.o specialf.o pwl_integ.o misc.o h5_inout.o: data_types.o
transformers.o SRtoolkit.o: data_types.o constants.o
pairs.o: data_types.o constants.o misc.o
params.o: data_types.o misc.o
Aglow_models.o: data_types.o constants.o transformers.o SRtoolkit.o
blazMag.o: data_types.o constants.o misc.o pwl_integ.o h5_inout.o SRtoolkit.o \
	anaFormulae.o radiation.o dist_evol.o specialf.o
blazMag_main.o: data_types.o misc.o blazMag.o
afterglow_main.o: data_types.o misc.o afterglow.o
turBlaz.o: data_types.o constants.o misc.o pwl_integ.o h5_inout.o SRtoolkit.o \
	anaFormulae.o radiation.o dist_evol.o specialf.o
turBlaz_main.o: data_types.o misc.o turBlaz.o
anaFormulae.o: data_types.o constants.o misc.o pwl_integ.o
radiation.o: data_types.o constants.o misc.o pwl_integ.o SRtoolkit.o \
	anaFormulae.o
dist_evol.o: data_types.o constants.o misc.o pwl_integ.o SRtoolkit.o specialf.o
tests.o: data_types.o constants.o misc.o pwl_integ.o h5_inout.o SRtoolkit.o \
	anaFormulae.o Aglow_models.o radiation.o dist_evol.o specialf.o
afterglow.o: data_types.o constants.o misc.o pwl_integ.o specialf.o\
	h5_inout.o Aglow_models.o SRtoolkit.o anaFormulae.o radiation.o dist_evol.o
benchmarks.o: data_types.o constants.o transformers.o misc.o pwl_integ.o \
	h5_inout.o specialf.o SRtoolkit.o Aglow_models.o anaFormulae.o dist_evol.o \
	radiation.o
benchmarking.o: benchmarks.o

# ----- executables -----
$(TESTS): data_types.o constants.o $(TESTS_OBJ)
	$(FC) $(LOPT) -o $@ $^

$(BLAZMAG): data_types.o constants.o $(BLAZMAG_OBJ)
	$(FC) $(LOPT) -o $@ $^

$(AFGLOW): data_types.o constants.o $(AFGLOW_OBJ)
	$(FC) $(LOPT) -o $@ $^

$(TURBLAZ): data_types.o constants.o $(TURBLAZ_OBJ)
	$(FC) $(LOPT) -o $@ $^

$(BENCH): data_types.o constants.o $(BENCH_OBJ)
	$(FC) $(LOPT) -o $@ $^

# ----- objects -----
%.o: %.F90
	$(FC) $(COPT) $< -o $@


# -----  PHONY things  -----
.PHONY: clean

clean:
	rm -vf *.o *.mod *~
	rm -rvf x*
