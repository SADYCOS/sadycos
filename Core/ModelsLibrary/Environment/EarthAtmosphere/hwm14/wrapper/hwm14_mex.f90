#include "fintrf.h"

subroutine mexFunction(nlhs, plhs, nrhs, prhs)

use, intrinsic :: iso_fortran_env, only : real64
use hwm_interface, only : hwm_14

  implicit none


! MEX arguments
  integer              :: nlhs, nrhs
  mwPointer            :: plhs(*), prhs(*)


! function declarations out of the MEX_API
  mwPointer :: mxGetPr, mxCreateDoubleMatrix
  double precision :: mxGetScalar
  external :: mxGetPr, mxCreateDoubleMatrix, mxGetScalar, mxCopyReal8ToPtr
  

! local variables
  integer          :: dayOfYear
  real(real64)     :: UTsec, alt_km, glat, glon, Ap
  real(real64)     :: Wmer, Wzon
  double precision :: tmp
  mwPointer        :: out_ptr
  double precision :: w_out(2)


!
! MATLAB call signature:
!   w = hwm14_mex(dayOfYear, UTsec, altitude_km, glat, glon, Ap)
!
! Returns:
!   w(1) = meridional wind [m/s]
!   w(2) = zonal wind [m/s]
!

! --- Check number of inputs/outputs ---
  if (nrhs .ne. 6) then
     call mexErrMsgIdAndTxt('hwm14_mex:nrhs', &
       'Six inputs required: dayOfYear, UTsec, altitude_km, glat, glon, Ap.')
  end if

  if (nlhs .ne. 1) then
     call mexErrMsgIdAndTxt('hwm14_mex:nlhs', &
       'Exactly one output argument (1x2 wind vector) is required.')
  end if


! --- Read MATLAB scalars (double -> Fortran) ---
tmp       = mxGetScalar(prhs(1));  dayOfYear = int(tmp)
tmp       = mxGetScalar(prhs(2));  UTsec     = tmp
tmp       = mxGetScalar(prhs(3));  alt_km    = tmp
tmp       = mxGetScalar(prhs(4));  glat      = tmp
tmp       = mxGetScalar(prhs(5));  glon      = tmp
tmp       = mxGetScalar(prhs(6));  Ap        = tmp


! --- Call HWM14 via the interface module ---
  call hwm_14(dayOfYear, UTsec, alt_km, glat, glon, Ap, Wmer, Wzon)


! --- Prepare MATLAB output ---
w_out(1) = Wmer
w_out(2) = Wzon

plhs(1) = mxCreateDoubleMatrix(1, 2, 0)   ! 1x2 real*8 (double)
out_ptr = mxGetPr(plhs(1))
call mxCopyReal8ToPtr(w_out, out_ptr, 2)

return
end subroutine mexFunction