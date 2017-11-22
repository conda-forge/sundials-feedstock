#!/bin/sh

echo "cmake_minimum_required(VERSION 2.8)" > CMakeLists.txt
echo "project (my_sundials_test)" >> CMakeLists.txt
echo "add_executable (cvRoberts_dns cvRoberts_dns.c)" >>CMakeLists.txt
echo "target_link_libraries (cvRoberts_dns LINK_PUBLIC sundials_cvode sundials_nvecserial)" >>CMakeLists.txt
echo "enable_testing()" >>CMakeLists.txt
echo "add_test (test_roberts cvRoberts_dns)" >>CMakeLists.txt

cmake .
C_INCLUDE_PATH=$PREFIX/include LIBRARY_PATH=$PREFIX/lib cmake --build .

if [ $(uname -s) == 'Darwin' ]; then
    DYLD_FALLBACK_LIBRARY_PATH=$PREFIX/lib ctest
else
    LD_LIBRARY_PATH=$PREFIX/lib ctest
fi
