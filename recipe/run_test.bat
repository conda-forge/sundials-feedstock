
cmake -G "NMake Makefiles" -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% .
cmake --build . --config Release
ctest --output-on-failure
