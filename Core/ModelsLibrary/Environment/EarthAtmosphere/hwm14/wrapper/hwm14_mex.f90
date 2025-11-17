#include "fintrf.h"

subroutine mexFunction(nlhs, plhs, nrhs, prhs)

  implicit none

! MEX arguments
  integer              :: nlhs, nrhs
  mwPointer            :: plhs(*), prhs(*)