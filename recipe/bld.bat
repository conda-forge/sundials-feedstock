
git clone --depth 1 https://github.com/xiaoyeli/superlu_mt.git
cmake -LAH -G "Ninja" -B build_slu -S superlu_mt -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% -DPLAT="_OPENMP" -DBUILD_SHARED_LIBS=OFF
cmake --build build_slu --config Release
dir /p build_slu\SRC

cmake -LAH -G "Ninja" -B build ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DBUILD_SHARED_LIBS=OFF ^
    -DBUILD_STATIC_LIBS=ON ^
    -DEXAMPLES_ENABLE_C=ON ^
    -DEXAMPLES_INSTALL=OFF ^
    -DENABLE_OPENMP=OFF ^
    -DENABLE_LAPACK=OFF ^
    -DENABLE_SUPERLUMT=ON ^
    -DCMAKE_C_FLAGS="/DWIN32 /D_WINDOWS /W3 /D__OPENMP" ^
    -DSUPERLUMT_THREAD_TYPE=OPENMP ^
    -DSUPERLUMT_LIBRARY="%SRC_DIR:\=/%/build_slu/SRC/superlu_mt_OPENMP.lib" ^
    -DSUPERLUMT_LIBRARIES="%SRC_DIR:\=/%/build_slu/SRC/superlu_mt_OPENMP.lib;blas" ^
    -DSUPERLUMT_INCLUDE_DIR="%SRC_DIR:\=/%/superlu_mt/SRC" ^
    -DSUNDIALS_INDEX_SIZE=32 ^
    -S .
cmake --build build --target install --config Release

