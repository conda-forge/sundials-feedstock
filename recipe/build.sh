#!/bin/sh

# local superlu install
curl -fSsL https://portal.nersc.gov/project/sparse/superlu/superlu_mt_3.1.tar.gz | tar xz
cd SuperLU_MT_3.1
if test `uname` = "Linux"
then
  MPLIB="-fopenmp"
fi
make CC=${CC} CFLAGS="-O2 -fPIC ${MPLIB}" BLASLIB="-lblas" PLAT="_OPENMP" MPLIB=${MPLIB} lib -j1
mv SRC include
cd -

mkdir build
cd build

# EXAMPLES_ENABLE=1 enables tests to be run (requires Python)

if [ $(uname -s) == 'Darwin' ]; then
    WITH_OPENMP=0  # CMake script fails to setup OpenMP_C_FLAGS anyway 
else
    WITH_OPENMP=1
fi

cmake ${CMAKE_ARGS} -LAH \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DBUILD_SHARED_LIBS=ON \
    -DBUILD_STATIC_LIBS=OFF \
    -DCMAKE_C_STANDARD=11 \
    -DEXAMPLES_ENABLE_C=ON \
    -DEXAMPLES_INSTALL=OFF \
    -DENABLE_OPENMP=$WITH_OPENMP \
    -DENABLE_LAPACK=ON \
    -DLAPACK_LIBRARIES="lapack;blas" \
    -DCMAKE_INSTALL_RPATH="${PREFIX}/lib" \
    -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON \
    -DCMAKE_MACOSX_RPATH=ON \
    -DENABLE_KLU=ON \
    -DKLU_LIBRARY_DIR=${PREFIX}/lib \
    -DENABLE_SUPERLUMT=ON \
    -DSUPERLUMT_THREAD_TYPE=OPENMP \
    -DSUPERLUMT_LIBRARY=$PWD/../SuperLU_MT_3.1/lib/libsuperlu_mt_OPENMP.a \
    -DSUNDIALS_F77_FUNC_CASE="LOWER" -DSUNDIALS_F77_FUNC_UNDERSCORES="ONE" \
    -DSUNDIALS_INDEX_SIZE=32 \
    ..  # int32_t needed for Lapack not to be disabled

make install -j${CPU_COUNT}
cat ${PREFIX}/include/sundials/sundials_config.h
