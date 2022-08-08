DEBUG ?= 0
USE_DRAMSIM3 ?= 1
CUDA_HOME = /jet/packages/spack/opt/spack/linux-centos8-zen/gcc-8.3.1/cuda-11.1.1-a6ajxenobex5bvpejykhtnfut4arfpwh
PAPI_HOME = /usr/local/papi-6.0.0
ICC_HOME = /opt/intel/compilers_and_libraries/linux/bin/intel64
NVSHMEM_HOME = /ocean/projects/cie170003p/shared/nvshmem
MPI_HOME = /opt/packages/openmpi/gcc/4.1.1-gcc8.3.1-cpu
MKLROOT = /opt/intel/mkl
CUB_DIR = ../../../cub
MGPU_DIR = ../../../moderngpu
BIN = ../../bin/

CC := gcc
CXX := g++
ICC := $(ICC_HOME)/icc
ICPC := $(ICC_HOME)/icpc
MPICC := mpicc
MPICXX := mpicxx
NVCC := nvcc
#NVCC := $(CUDA_HOME)/bin/nvcc
GENCODE_SM30 := -gencode arch=compute_30,code=sm_30
GENCODE_SM35 := -gencode arch=compute_35,code=sm_35
GENCODE_SM37 := -gencode arch=compute_37,code=sm_37
GENCODE_SM50 := -gencode arch=compute_50,code=sm_50
GENCODE_SM52 := -gencode arch=compute_52,code=sm_52
GENCODE_SM60 := -gencode arch=compute_60,code=sm_60
GENCODE_SM70 := -gencode arch=compute_70,code=sm_70
GENCODE_SM80 := -gencode arch=compute_80,code=sm_80 -gencode arch=compute_80,code=compute_80
CUDA_ARCH := $(GENCODE_SM70)
CXXFLAGS  := -Wall -fopenmp -std=c++17 -march=native
ICPCFLAGS := -O3 -Wall -qopenmp
NVFLAGS := $(CUDA_ARCH)
NVFLAGS += -Xptxas -v
NVFLAGS += -DUSE_GPU
NVLDFLAGS = -L$(CUDA_HOME)/lib64 -lcuda -lcudart
MPI_LIBS = -L$(MPI_HOME)/lib -lmpi
NVSHMEM_LIBS = -L$(NVSHMEM_HOME)/lib -lnvshmem -lnvToolsExt -lnvidia-ml -ldl -lrt

ifeq ($(VTUNE), 1)
	CXXFLAGS += -g
endif
ifeq ($(NVPROF), 1)
	NVFLAGS += -lineinfo
endif

ifeq ($(DEBUG), 1)
	CXXFLAGS += -g -O0
	NVFLAGS += -G
else
	CXXFLAGS += -O3
	NVFLAGS += -O3 -w
endif

INCLUDES := -I../../include
LIBS := $(NVLDFLAGS) -lgomp

ifeq ($(PAPI), 1)
CXXFLAGS += -DENABLE_PAPI
INCLUDES += -I$(PAPI_HOME)/include
LIBS += -L$(PAPI_HOME)/lib -lpapi
endif

ifeq ($(USE_TBB), 1)
LIBS += -L/h2/xchen/work/gardenia_code/tbb2020/lib/intel64/gcc4.8/ -ltbb
endif

VPATH += ../common
OBJS=main.o VertexSet.o graph.o

ifneq ($(NVSHMEM),)
NVFLAGS += -DUSE_NVSHMEM -dc
endif

# CUDA vertex parallel
ifneq ($(VPAR),)
NVFLAGS += -DVERTEX_PAR
endif

# CUDA CTA centric
ifneq ($(CTA),)
NVFLAGS += -DCTA_CENTRIC
endif

ifneq ($(PROFILE),)
CXXFLAGS += -DPROFILING
endif

ifneq ($(USE_SET_OPS),)
CXXFLAGS += -DUSE_MERGE
endif

ifneq ($(USE_SIMD),)
CXXFLAGS += -DSI=0
endif

# counting or listing
ifneq ($(COUNT),)
NVFLAGS += -DDO_COUNT
endif

# GPU vertex/edge parallel 
ifeq ($(VERTEX_PAR),)
NVFLAGS += -DEDGE_PAR
else
NVFLAGS += -DVERTEX_PAR
endif

# CUDA unified memory
ifneq ($(USE_UM),)
NVFLAGS += -DUSE_UM
endif

# kernel fission
ifneq ($(FISSION),)
NVFLAGS += -DFISSION
endif

