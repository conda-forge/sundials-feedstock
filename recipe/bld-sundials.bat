@echo ON

if not exist "superlu_mt" (
    git clone --depth 1 https://github.com/xiaoyeli/superlu_mt.git
    if errorlevel 1 exit 1
)
cmake -LAH -G "Ninja" -B build_slu -S superlu_mt -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% -DPLAT="_OPENMP" -DBUILD_SHARED_LIBS=OFF
if errorlevel 1 exit 1
cmake --build build_slu  --target install --config Release
if errorlevel 1 exit 1

cmake -LAH -G "Ninja" -B build ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DBUILD_SHARED_LIBS=ON ^
    -DBUILD_STATIC_LIBS=ON ^
    -DEXAMPLES_ENABLE_C=ON ^
    -DEXAMPLES_INSTALL=OFF ^
    -DENABLE_OPENMP=OFF ^
    -DENABLE_LAPACK=OFF ^
    -DENABLE_SUPERLUMT=ON ^
    -DCMAKE_C_FLAGS="/DWIN32 /D_WINDOWS /W3 /D__OPENMP" ^
    -DSUPERLUMT_THREAD_TYPE=OPENMP ^
    -DSUPERLUMT_LIBRARY="superlu_mt_OPENMP.lib" ^
    -DSUPERLUMT_LIBRARIES="%LIBRARY_PREFIX:\=/%/lib/superlu_mt_OPENMP.lib;blas" ^
    -DSUPERLUMT_INCLUDE_DIR="%LIBRARY_PREFIX:\=/%/include/superlu_mt" ^
    -DSUNDIALS_INDEX_SIZE=32 ^
    -S .
if errorlevel 1 exit 1

cmake --build build --target install --config Release
if errorlevel 1 exit 1
