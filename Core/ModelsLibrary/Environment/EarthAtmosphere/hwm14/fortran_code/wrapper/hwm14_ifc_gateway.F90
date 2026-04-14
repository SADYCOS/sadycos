#include "fintrf.h"

! Gateway for mex file creation with libhwm_ifc.a
! PATCH:
!   This MEX gateway accepts an additional first input argument:
!   dataPath
!   The path is stored in data_path::hwm_data_path so that the patched
!   HWM14 file lookup routine can locate its support data files
!   independently of the current working directory.

subroutine mexFunction(nlhs, plhs, nrhs, prhs)

! Import double precision kind definition (from fortran intrisic module)
  use, intrinsic :: iso_fortran_env, only: real64

! Import the generic interface from hwm_interface module
  use hwm_interface, only: hwm_14

! PATCH: shared path storage for HWM14 support data files
  use data_path, only: hwm_data_path    ! Import module variable so this routine can write to shared data path

  implicit none

! MEX arguments declarations
  integer*4 nlhs, nrhs              ! number of outputs and inputs
  mwPointer plhs(*), prhs(*)        ! pointers to MATLAB output and input arrays

! Function declarations from the MEX API
  mwPointer mxGetDoubles, mxCreateDoubleMatrix
  integer*4 mxIsChar, mxGetString
  external  mxGetDoubles, mxCreateDoubleMatrix
  external  mxCopyPtrToReal8, mxCopyReal8ToPtr, mexErrMsgTxt
  external  mxIsChar, mxGetString

! Pointers to MATLAB memory location
! Declaration of variables with typ mwPointer
  mwPointer :: p_doy, p_utsec, p_alt, p_glat, p_glon, p_ap, p_wout

! Declaration of variables to store MATLAB input values
  real(real64) :: d_doy, d_utsec, d_alt, d_glat, d_glon, d_ap
  real(real64) :: d_w(2)

! ---- HWM interface inputs / outputs ----
! Variables passed to HWM interface
  integer      :: dayOfYear
  real(real64) :: UTsec, alt_km, glat, glon, Ap
  real(real64) :: Wmeridional, Wzonal

! PATCH: variables for MATLAB string input
  integer*4        :: status
  character(1024)  :: dataPath

! ---------------------------------------------------------------------
! Check number of input and output arguments
!
! New usage:
!   w = hwm14_mex(dataPath, dayOfYear, UTsec, alt_km, glat, glon, Ap)
! ---------------------------------------------------------------------
  if (nrhs .ne. 7) then
    call mexErrMsgTxt( &
      'hwm14_mex: Exactly 7 input arguments required: dataPath, dayOfYear, UTsec, alt_km, glat, glon, Ap.' &
    )
  endif

  if (nlhs .ne. 1) then
    call mexErrMsgTxt( &
      'hwm14_mex: Exactly 1 output argument required. Usage: w = hwm14_mex(dataPath, ...)' &
    )
  endif

! ---------------------------------------------------------------------
! PATCH:
! Read first input argument as MATLAB char array and store it in the
! shared module variable hwm_data_path.
! ---------------------------------------------------------------------
  if (mxIsChar(prhs(1)) .eq. 0) then
    call mexErrMsgTxt('hwm14_mex: First input argument dataPath must be a character array.')
  endif

  dataPath = ''                                           ! Initialize empty dataPath variable
  status = mxGetString(prhs(1), dataPath, len(dataPath))  ! Read MATLAB string (dataPath) into local Fortran variable

  if (status .ne. 0) then
    call mexErrMsgTxt('hwm14_mex: Failed to read dataPath string or path is too long.')
  endif

  hwm_data_path = trim(dataPath)                          ! Copy local path into module variable (shared state used by findandopen)

! ------------------------------------------------------------
! Get numeric input arguments from MATLAB and convert types
! ------------------------------------------------------------
! Syntax:
! prhs(n) pointer to the n-th MATLAB input 
! mxGetDoubles(...) delivers pointer to the double data
! 1. p_xyz points to the location in MATLAB memory where the input data is located 
! 2. call mxCopyPtrToReal8(source, target variable, number of values) copy the double-values from matlab to fortran
! 3. xyz = real(d_xyz) for real*4 or xyz = int(d_xyz) for integer*4 convert Fortran double to hwm14 expected data typ

! dayOfYear (integer)
  p_doy = mxGetDoubles(prhs(2))
  call mxCopyPtrToReal8(p_doy, d_doy, 1)
  dayOfYear = int(d_doy)

! UTsec
  p_utsec = mxGetDoubles(prhs(3))
  call mxCopyPtrToReal8(p_utsec, d_utsec, 1)
  UTsec = d_utsec

! alt_km
  p_alt = mxGetDoubles(prhs(4))
  call mxCopyPtrToReal8(p_alt, d_alt, 1)
  alt_km = d_alt

! glat
  p_glat = mxGetDoubles(prhs(5))
  call mxCopyPtrToReal8(p_glat, d_glat, 1)
  glat = d_glat

! glon
  p_glon = mxGetDoubles(prhs(6))
  call mxCopyPtrToReal8(p_glon, d_glon, 1)
  glon = d_glon

! Ap index
  p_ap = mxGetDoubles(prhs(7))
  call mxCopyPtrToReal8(p_ap, d_ap, 1)
  Ap = d_ap

! ---------------------------------------------------------------------
! Call the HWM interface
! ---------------------------------------------------------------------
  call hwm_14(dayOfYear, UTsec, alt_km, glat, glon, Ap, Wmeridional, Wzonal)

! ---------------------------------------------------------------------
! Create MATLAB output array (2x1 double)
! ---------------------------------------------------------------------
! plhs() declaration of 2x1 double-array for w
! p_wout gets pointer to output array plhs(1)
! mxCopyReal8ToPtr(d_w, p_wout, 2) copies two double values ​​from d_w(1:2) 
! into the MATLAB array pointed to by p_wout

  plhs(1) = mxCreateDoubleMatrix(2, 1, 0)   ! 0 = mxREAL
  p_wout  = mxGetDoubles(plhs(1))

! Store output values
  d_w(1) = Wmeridional
  d_w(2) = Wzonal

! Copy back to MATLAB memory
  call mxCopyReal8ToPtr(d_w, p_wout, 2)

  return
end subroutine mexFunction