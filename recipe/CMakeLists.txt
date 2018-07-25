cmake_minimum_required (VERSION 2.8)

if (NOT DEFINED CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release CACHE STRING "Build type")
endif ()

project (my_sundials_test C)

find_package (OpenMP)

enable_testing()

find_path (SUNDIALS_INCLUDE_DIR cvode/cvode.h)
message (STATUS "SUNDIALS_INCLUDE_DIR: ${SUNDIALS_INCLUDE_DIR}")

set(SUNDIALS_LIBS_LIST
  cvode
  ida
  idas
  kinsol
  nvecserial
  nvecopenmp
  sunlinsolklu
  sunlinsollapackband
)

foreach(LIB ${SUNDIALS_LIBS_LIST})
  find_library (SUNDIALS_LIB_${LIB} sundials_${LIB})
  message (STATUS "SUNDIALS_LIB_${LIB}: ${SUNDIALS_LIB_${LIB}}")
endforeach ()

include_directories (${SUNDIALS_INCLUDE_DIR})

if (UNIX)
  find_library (BLAS_LIBRARIES openblas)
endif ()

add_executable (cvRoberts_dns cvRoberts_dns.c)
add_executable (cvRoberts_klu cvRoberts_klu.c)
add_executable (cvAdvDiff_bndL cvAdvDiff_bndL.c)
target_link_libraries (cvRoberts_dns LINK_PUBLIC ${SUNDIALS_LIB_cvode} ${SUNDIALS_LIB_nvecserial})
target_link_libraries (cvRoberts_klu LINK_PUBLIC ${SUNDIALS_LIB_cvode} ${SUNDIALS_LIB_nvecserial} ${SUNDIALS_LIB_sunlinsolklu})
target_link_libraries (cvAdvDiff_bndL LINK_PUBLIC ${SUNDIALS_LIB_cvode} ${SUNDIALS_LIB_nvecserial} ${SUNDIALS_LIB_sunlinsollapackband} ${BLAS_LIBRARIES})
add_test (test_roberts_dns cvRoberts_dns)
add_test (test_roberts_klu cvRoberts_klu)
add_test (test_advdiff_bndL cvAdvDiff_bndL)

if (OpenMP_C_FOUND)
  add_executable (cvAdvDiff_bnd_omp cvAdvDiff_bnd_omp.c)
  target_link_libraries (cvAdvDiff_bnd_omp LINK_PUBLIC ${SUNDIALS_LIB_cvode} ${SUNDIALS_LIB_nvecopenmp})
  add_test (test_advdiff_omp cvAdvDiff_bnd_omp)
endif ()
