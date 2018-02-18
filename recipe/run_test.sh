#!/bin/sh

echo "cmake_minimum_required(VERSION 2.8)" > CMakeLists.txt
echo "project (my_sundials_test)" >> CMakeLists.txt
echo "add_executable (cvRoberts_dns cvRoberts_dns.c)" >>CMakeLists.txt
echo "add_executable (cvRoberts_klu cvRoberts_klu.c)" >>CMakeLists.txt
echo "add_executable (cvAdvDiff_bndL cvAdvDiff_bndL.c)" >>CMakeLists.txt
echo "target_link_libraries (cvRoberts_dns LINK_PUBLIC sundials_cvode sundials_nvecserial)" >>CMakeLists.txt
echo "target_link_libraries (cvRoberts_klu LINK_PUBLIC sundials_cvode sundials_nvecserial sundials_sunlinsolklu)" >>CMakeLists.txt
echo "target_link_libraries (cvAdvDiff_bndL LINK_PUBLIC sundials_cvode sundials_nvecserial sundials_sunlinsollapackband openblas)" >>CMakeLists.txt
echo "enable_testing()" >>CMakeLists.txt
echo "add_test (test_roberts_dns cvRoberts_dns)" >>CMakeLists.txt
echo "add_test (test_roberts_klu cvRoberts_klu)" >>CMakeLists.txt
echo "add_test (test_advdiff_bndL cvAdvDiff_bndL)" >>CMakeLists.txt
if [ $(uname -s) != 'Darwin' ]; then
    echo "add_executable (cvAdvDiff_bnd_omp cvAdvDiff_bnd_omp.c)" >>CMakeLists.txt
    echo "target_link_libraries (cvAdvDiff_bnd_omp LINK_PUBLIC sundials_cvode sundials_nvecopenmp)" >>CMakeLists.txt
    echo "add_test (test_advdiff_omp cvAdvDiff_bnd_omp)" >>CMakeLists.txt
fi

cmake .
C_INCLUDE_PATH=$PREFIX/include LIBRARY_PATH=$PREFIX/lib cmake --build .

if [ $(uname -s) == 'Darwin' ]; then
    DYLD_FALLBACK_LIBRARY_PATH=$PREFIX/lib ctest
else
    LD_LIBRARY_PATH=$PREFIX/lib ctest
fi
