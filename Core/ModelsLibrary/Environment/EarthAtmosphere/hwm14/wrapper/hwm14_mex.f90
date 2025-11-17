#include "fintrf.h"

subroutine mexFunction(nlhs, plhs, nrhs, prhs)

  implicit none

! MEX arguments
  integer              :: nlhs, nrhs
  mwPointer            :: plhs(*), prhs(*)

! function declarations out of the MEX_API
  mwPointer            :: mxGetPr
  mwPointer            :: mxCreateDoubleMatrix
  mwPointer            :: mxGetNumberOfElements
  real*8               :: mxGetScalar
  external             :: mxGetPr, mxCreateDoubleMatrix
  external             :: mxGetNumberOfElements, mxGetScalar