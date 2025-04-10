@echo ON

:: Use forward slashes in LIBRARY_PREFIX - needed for Fortran-compiled LAPACK
set SAFE_PREFIX=%LIBRARY_PREFIX:\=/%

:: Use forward slashes in FFLAGS - needed for Fortran-compiled LAPACK
set "FFLAGS=%FFLAGS:\=/%"

cmake -LAH -G "Ninja" -B superlu_mt/build -S superlu_mt ^
    -DCMAKE_INSTALL_PREFIX=%SAFE_PREFIX% ^
    -DPLAT="_OPENMP" ^
    -DBLA_VENDOR=Generic ^
    -DBUILD_SHARED_LIBS=OFF
if errorlevel 1 exit 1

cmake --build superlu_mt/build --target install --config Release
if errorlevel 1 exit 1

set SUNDIALS_BUILD_SHARED=ON
if /I "%PKG_NAME%" == "sundials-static" (
    set SUNDIALS_BUILD_SHARED=OFF
)

set SUNDIALS_BUILD_STATIC=ON
if /I "%PKG_NAME%" == "sundials" (
    set SUNDIALS_BUILD_STATIC=OFF
)

cmake -LAH -G "Ninja" -B sundials/build -S sundials ^
    -DCMAKE_INSTALL_PREFIX=%SAFE_PREFIX% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DBUILD_SHARED_LIBS=%SUNDIALS_BUILD_SHARED% ^
    -DBUILD_STATIC_LIBS=%SUNDIALS_BUILD_STATIC% ^
    -DEXAMPLES_ENABLE_C=ON ^
    -DEXAMPLES_INSTALL=OFF ^
    -DENABLE_OPENMP=ON ^
    -DOpenMP_Fortran_FLAGS=-fopenmp ^
    -DOpenMP_Fortran_LIB_NAMES=libomp ^
    -DOpenMP_libomp_LIBRARY="%SAFE_PREFIX%/libomp.lib" ^
    -DENABLE_LAPACK=ON ^
    -DBLA_VENDOR=Generic ^
    -DCMAKE_C_FLAGS="/DWIN32 /D_WINDOWS /W3 /D__OPENMP" ^
    -DENABLE_KLU=ON ^
    -DKLU_LIBRARY_DIR="%SAFE_PREFIX%/lib" ^
    -DKLU_INCLUDE_DIR="%SAFE_PREFIX%/include/suitesparse" ^
    -DKLU_LIBRARY="%SAFE_PREFIX%/lib/klu.lib" ^
    -DAMD_LIBRARY="%SAFE_PREFIX%/lib/amd.lib" ^
    -DBTF_LIBRARY="%SAFE_PREFIX%/lib/btf.lib" ^
    -DCOLAMD_LIBRARY="%SAFE_PREFIX%/lib/colamd.lib" ^
    -DENABLE_SUPERLUMT=ON ^
    -DSUPERLUMT_THREAD_TYPE=OPENMP ^
    -DSUPERLUMT_LIBRARY="superlu_mt_OPENMP.lib" ^
    -DSUPERLUMT_LIBRARIES="%SAFE_PREFIX%/lib/superlu_mt_OPENMP.lib;blas" ^
    -DSUPERLUMT_INCLUDE_DIR="%SAFE_PREFIX%/include/superlu_mt" ^
    -DSUNDIALS_INDEX_SIZE=32
if errorlevel 1 exit 1

cmake --build sundials/build --target install --config Release
if errorlevel 1 exit 1
