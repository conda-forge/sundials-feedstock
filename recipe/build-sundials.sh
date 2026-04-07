#!/bin/sh
set -euxo pipefail

cmake ${CMAKE_ARGS} -LAH -G "Ninja" -B superlu_mt/build -S superlu_mt -DCMAKE_PREFIX_PATH=${PREFIX} -DPLAT="_OPENMP" -DBUILD_SHARED_LIBS=OFF
cmake --build superlu_mt/build --target install --parallel ${CPU_COUNT}

if [[ $PKG_NAME == "sundials-devel" || $PKG_NAME == "sundials" ]]; then
    SUNDIALS_BUILD_SHARED=ON
else
    SUNDIALS_BUILD_SHARED=OFF
fi

if [[ $PKG_NAME == "sundials-devel" || $PKG_NAME == "sundials-static" ]]; then
    SUNDIALS_BUILD_STATIC=ON
else
    SUNDIALS_BUILD_STATIC=OFF
fi

cmake ${CMAKE_ARGS} -LAH -G "Ninja" -B sundials/build -S sundials \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DBUILD_SHARED_LIBS=$SUNDIALS_BUILD_SHARED \
    -DBUILD_STATIC_LIBS=$SUNDIALS_BUILD_STATIC \
    -DCMAKE_C_STANDARD=11 \
    -DSUNDIALS_ENABLE_C_EXAMPLES=ON \
    -DSUNDIALS_ENABLE_EXAMPLES_INSTALL=OFF \
    -DSUNDIALS_ENABLE_OPENMP=ON \
    -DSUNDIALS_ENABLE_LAPACK=ON \
    -DCMAKE_INSTALL_RPATH="${PREFIX}/lib" \
    -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON \
    -DCMAKE_MACOSX_RPATH=ON \
    -DSUNDIALS_ENABLE_KLU=ON \
    -DKLU_LIBRARY_DIR=${PREFIX}/lib \
    -DKLU_INCLUDE_DIR=${PREFIX}/include/suitesparse \
    -DSUNDIALS_ENABLE_SUPERLUMT=ON \
    -DSUPERLUMT_THREAD_TYPE=OPENMP \
    -DSUPERLUMT_INCLUDE_DIR="${PREFIX}/include/superlu_mt" \
    -DSUPERLUMT_LIBRARY=libsuperlu_mt_OPENMP.a \
    -DSUPERLUMT_LIBRARIES="${PREFIX}/lib/libsuperlu_mt_OPENMP.a;blas" \
    -DSUNDIALS_ENABLE_KLU_CHECKS=ON \
    -DSUNDIALS_INDEX_SIZE=32  # int32_t needed for Lapack not to be disabled

cmake --build sundials/build --target install --parallel ${CPU_COUNT}
