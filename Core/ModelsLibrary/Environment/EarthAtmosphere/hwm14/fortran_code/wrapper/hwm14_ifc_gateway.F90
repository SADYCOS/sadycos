#include "fintrf.h"

! Gateway for mex file creation with libhwm_ifc.a

subroutine mexFunction(nlhs, plhs, nrhs, prhs)

! Import double precision kind definition (from fortran intrisic module)
  use, intrinsic :: iso_fortran_env, only: real64

! Import the generic interface from hwm_interface module
  use hwm_interface, only: hwm_14

implicit none


! MEX arguments declarations
  integer*4 nlhs, nrhs              ! number of outputs and inputs
  mwPointer plhs(*), prhs(*)        ! pointers to MATLAB output and input arrays


! Function declarations out of the MEX_API
  mwPointer mxGetDoubles, mxCreateDoubleMatrix
  external  mxGetDoubles, mxCreateDoubleMatrix
  external  mxCopyPtrToReal8, mxCopyReal8ToPtr, mexErrMsgTxt
  external  mxGetString

! Status return value (0 for succes, 1 for failure)
  integer*4 mxGetString


! Pointers to MATLAB memory location
! Declaration of variables with typ mwPointer
  mwPointer :: p_doy, p_utsec, p_alt, p_glat, p_glon, p_ap, p_wout


! Declaration of variables to store MATLAB input values
  real(real64) :: d_doy, d_utsec, d_alt, d_glat, d_glon, d_ap
  real(real64) :: d_w(2)

! ---- HWM interface inputs / outputs ----
! Variables passed to HWM interface
  integer :: dayOfYear
  real(real64) :: UTsec, alt_km, glat, glon, Ap
  real(real64) :: Wmeridional, Wzonal
  character(1024) :: path
  logical      :: have_path


! Check correct number of input and output arguments
  if (nrhs .ne. 6 .and. nrhs .ne. 7) then
    call mexErrMsgTxt('hwm14_mex: Expected 6 or 7 input arguments: dayOfYear, UTsec, alt_km, glat, glon, Ap, path (optional).')
  endif

  if (nlhs .ne. 1) then
    call mexErrMsgTxt('hwm14_mex: Exactly 1 output argument required. Usage: w = hwm14_mex(...)')
  endif


! ------------------------------------------------------------
! Get input arguments from MATLAB and convert types
! ------------------------------------------------------------
! Syntax:
! prhs(n) pointer to the n-th MATLAB input 
! mxGetDoubles(...) delivers pointer to the double data
! 1. p_xyz points to the location in MATLAB memory where the input data is located 
! 2. call mxCopyPtrToReal8(source, target variable, number of values) copy the double-values from matlab to fortran
! 3. xyz = real(d_xyz) for real*4 or xyz = int(d_xyz) for integer*4 convert Fortran double to hwm14 expected data typ

 ! dayOfYear (integer)
  p_doy = mxGetDoubles(prhs(1))
  call mxCopyPtrToReal8(p_doy, d_doy, 1)
  dayOfYear = int(d_doy)

  ! UTsec
  p_utsec = mxGetDoubles(prhs(2))
  call mxCopyPtrToReal8(p_utsec, d_utsec, 1)
  UTsec = d_utsec

  ! alt_km
  p_alt = mxGetDoubles(prhs(3))
  call mxCopyPtrToReal8(p_alt, d_alt, 1)
  alt_km = d_alt

  ! glat
  p_glat = mxGetDoubles(prhs(4))
  call mxCopyPtrToReal8(p_glat, d_glat, 1)
  glat = d_glat

  ! glon
  p_glon = mxGetDoubles(prhs(5))
  call mxCopyPtrToReal8(p_glon, d_glon, 1)
  glon = d_glon

  ! Ap index
  p_ap = mxGetDoubles(prhs(6))
  call mxCopyPtrToReal8(p_ap, d_ap, 1)
  Ap = d_ap

  ! optional argument "path"
  have_path = .false.   !default: path is not set
  if (nrhs .eq. 7) then
    if (mxGetString(prhs(7), path, len(path)) == 0) then    !writes input argument 7 directly in variable path
      have_path = .true.    !path is set
    endif
  endif


!---------------------------------------------------------------------
! Call the HWM interface
!---------------------------------------------------------------------
  if (have_path) then
    call hwm_14(dayOfYear, UTsec, alt_km, glat, glon, Ap, Wmeridional, Wzonal, path=trim(path))
  else 
    call hwm_14(dayOfYear, UTsec, alt_km, glat, glon, Ap, Wmeridional, Wzonal)
  endif


!---------------------------------------------------------------------
! Create MATLAB output array (2x1 double)
!---------------------------------------------------------------------
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