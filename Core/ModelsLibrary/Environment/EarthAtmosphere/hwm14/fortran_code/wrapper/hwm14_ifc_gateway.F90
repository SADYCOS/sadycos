#include "fintrf.h"

! Gateway for mex file creation with libhwm_ifc.a
! Data files (hwm123114.bin, dwm07b104i.dat, gd2qd.dat) are embedded
! directly in libhwm14.a at build time -- no runtime path needed.

subroutine mexFunction(nlhs, plhs, nrhs, prhs)

  use, intrinsic :: iso_fortran_env, only: real64
  use hwm_interface, only: hwm_14

  implicit none

  integer*4 nlhs, nrhs
  mwPointer plhs(*), prhs(*)

  mwPointer mxGetDoubles, mxCreateDoubleMatrix
  external  mxGetDoubles, mxCreateDoubleMatrix
  external  mxCopyPtrToReal8, mxCopyReal8ToPtr, mexErrMsgTxt

  mwPointer :: p_doy, p_utsec, p_alt, p_glat, p_glon, p_ap, p_wout

  real(real64) :: d_doy, d_utsec, d_alt, d_glat, d_glon, d_ap
  real(real64) :: d_w(2)

  integer(4)   :: dayOfYear
  real(real64) :: UTsec, alt_km, glat, glon, Ap
  real(real64) :: Wmeridional, Wzonal

! ---------------------------------------------------------------------
! Check number of input and output arguments
!
! Usage:
!   w = hwm14_mex(dayOfYear, UTsec, alt_km, glat, glon, Ap)
! ---------------------------------------------------------------------
  if (nrhs .ne. 6) then
    call mexErrMsgTxt( &
      'hwm14_mex: Exactly 6 input arguments required: dayOfYear, UTsec, alt_km, glat, glon, Ap.' &
    )
  endif

  if (nlhs .ne. 1) then
    call mexErrMsgTxt( &
      'hwm14_mex: Exactly 1 output argument required. Usage: w = hwm14_mex(...)' &
    )
  endif

! ---------------------------------------------------------------------
! Get numeric input arguments from MATLAB
! ---------------------------------------------------------------------

  p_doy = mxGetDoubles(prhs(1))
  call mxCopyPtrToReal8(p_doy, d_doy, 1)
  dayOfYear = int(d_doy)

  p_utsec = mxGetDoubles(prhs(2))
  call mxCopyPtrToReal8(p_utsec, d_utsec, 1)
  UTsec = d_utsec

  p_alt = mxGetDoubles(prhs(3))
  call mxCopyPtrToReal8(p_alt, d_alt, 1)
  alt_km = d_alt

  p_glat = mxGetDoubles(prhs(4))
  call mxCopyPtrToReal8(p_glat, d_glat, 1)
  glat = d_glat

  p_glon = mxGetDoubles(prhs(5))
  call mxCopyPtrToReal8(p_glon, d_glon, 1)
  glon = d_glon

  p_ap = mxGetDoubles(prhs(6))
  call mxCopyPtrToReal8(p_ap, d_ap, 1)
  Ap = d_ap

! ---------------------------------------------------------------------
! Call the HWM interface
! ---------------------------------------------------------------------
  call hwm_14(dayOfYear, UTsec, alt_km, glat, glon, Ap, Wmeridional, Wzonal)

! ---------------------------------------------------------------------
! Create MATLAB output array (2x1 double)
! ---------------------------------------------------------------------
  plhs(1) = mxCreateDoubleMatrix(2, 1, 0)
  p_wout  = mxGetDoubles(plhs(1))

  d_w(1) = Wmeridional
  d_w(2) = Wzonal

  call mxCopyReal8ToPtr(d_w, p_wout, 2)

  return
end subroutine mexFunction
