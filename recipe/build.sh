#!/bin/sh

# local superlu install
git clone --depth 1 https://github.com/xiaoyeli/superlu_mt.git
cmake ${CMAKE_ARGS} -LAH -G "Ninja" -B build_slu -S superlu_mt -DCMAKE_PREFIX_PATH=${PREFIX} -DPLAT="_OPENMP" -DBUILD_SHARED_LIBS=OFF
cmake --build build_slu --parallel ${CPU_COUNT}

# EXAMPLES_ENABLE=1 enables tests to be run (requires Python)

if [ $(uname -s) == 'Darwin' ]; then
    WITH_OPENMP=0  # CMake script fails to setup OpenMP_C_FLAGS anyway 
else
    WITH_OPENMP=1
fi

cmake ${CMAKE_ARGS} -LAH -G "Ninja" -B build \
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
    -DSUPERLUMT_INCLUDE_DIR="$PWD/superlu_mt/SRC" \
    -DSUPERLUMT_LIBRARY=$PWD/build_slu/SRC/libsuperlu_mt_OPENMP.a \
    -DSUPERLUMT_LIBRARIES="$PWD/build_slu/SRC/libsuperlu_mt_OPENMP.a;blas" \
    -DSUNDIALS_F77_FUNC_CASE="LOWER" -DSUNDIALS_F77_FUNC_UNDERSCORES="ONE" \
    -DSUNDIALS_INDEX_SIZE=32  # int32_t needed for Lapack not to be disabled

cmake --build build --target install --parallel ${CPU_COUNT}
cat ${PREFIX}/include/sundials/sundials_config.h
