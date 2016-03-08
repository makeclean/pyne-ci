#!/bin/bash
set -e

#unset LDFLAGS
export LD_LIBRARY_PATH="$PREFIX/lib:$LD_LIBRARY_PATH"
export CMAKE_LIBRARY_PATH="$PREFIX/lib:$CMAKE_LIBRARY_PATH"
export PATH="$PREFIX/bin:$PATH"
export DYLD_FALLBACK_LIBRARY_PATH="$PREFIX/lib/cyclus:$PREFIX/lib"
UNAME=$(uname)

if [[ "${UNAME}" == 'Linux' ]]; then
  ln -s $PREFIX/lib/libhdf5.so.9 $PREFIX/lib/libhdf5.so.8
  ln -s $PREFIX/lib/libhdf5_hl.so.9 $PREFIX/lib/libhdf5_hl.so.8
else
  ln -s $PREFIX/lib/libhdf5.9.dylib $PREFIX/lib/libhdf5.8.dylib
  ln -s $PREFIX/lib/libhdf5_hl.9.dylib $PREFIX/lib/libhdf5_hl.8.dylib
  export CC=gcc
  export CXX=g++
fi

# find / -name "libgfortran.so.3"
objdump -T /home/travis/.local/lib/libgfortran.so.3 | grep 'GFORTRAN_1.4'
objdump -T /home/travis/miniconda/pkgs/libgfortran-3.0-0/lib/libgfortran.so.3 | grep 'GFORTRAN_1.4'
${PYTHON} setup.py install
nuc_data_make

#
# Annoying hack for copying dlls
#
if [[ "$OSTYPE" == "darwin"* ]]; then
  cp build/src/*.dylib $PREFIX/lib
elif [[ "$OSTYPE" == "linux-gnu" ]]; then
  find . -name '*.so' | xargs chmod +x
  cp build/src/*.so $PREFIX/lib
fi
