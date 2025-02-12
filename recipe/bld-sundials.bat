@echo ON

cmake -LAH -G "Ninja" -B superlu_mt/build -S superlu_mt -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% -DPLAT="_OPENMP" -DBUILD_SHARED_LIBS=OFF
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
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DBUILD_SHARED_LIBS=%SUNDIALS_BUILD_SHARED% ^
    -DBUILD_STATIC_LIBS=%SUNDIALS_BUILD_STATIC% ^
    -DEXAMPLES_ENABLE_C=ON ^
    -DEXAMPLES_INSTALL=OFF ^
    -DENABLE_OPENMP=OFF ^
    -DENABLE_LAPACK=ON ^
    -DLAPACK_LIBRARIES="lapack;blas" ^
    -DCMAKE_C_FLAGS="/DWIN32 /D_WINDOWS /W3 /D__OPENMP" ^
    -DENABLE_KLU=ON ^
    -DKLU_LIBRARY_DIR="%LIBRARY_PREFIX:\=/%/lib" ^
    -DKLU_INCLUDE_DIR="%LIBRARY_PREFIX:\=/%/include/suitesparse" ^
    -DKLU_LIBRARY="%LIBRARY_PREFIX:\=/%/lib/klu.lib" ^
    -DAMD_LIBRARY="%LIBRARY_PREFIX:\=/%/lib/amd.lib" ^
    -DBTF_LIBRARY="%LIBRARY_PREFIX:\=/%/lib/btf.lib" ^
    -DCOLAMD_LIBRARY="%LIBRARY_PREFIX:\=/%/lib/colamd.lib" ^
    -DENABLE_SUPERLUMT=ON ^
    -DSUPERLUMT_THREAD_TYPE=OPENMP ^
    -DSUPERLUMT_LIBRARY="superlu_mt_OPENMP.lib" ^
    -DSUPERLUMT_LIBRARIES="%LIBRARY_PREFIX:\=/%/lib/superlu_mt_OPENMP.lib;blas" ^
    -DSUPERLUMT_INCLUDE_DIR="%LIBRARY_PREFIX:\=/%/include/superlu_mt" ^
    -DSUNDIALS_INDEX_SIZE=32
if errorlevel 1 exit 1

cmake --build sundials/build --target install --config Release
if errorlevel 1 exit 1
