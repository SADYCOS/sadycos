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

! local variables
  integer          :: dayOfYear
  real(real64)     :: UTsec, alt_km, glat, glon, Ap
  real(real64)     :: Wmer, Wzon
  double precision :: tmp
  mwPointer        :: out_ptr
  double precision :: w_out(2)