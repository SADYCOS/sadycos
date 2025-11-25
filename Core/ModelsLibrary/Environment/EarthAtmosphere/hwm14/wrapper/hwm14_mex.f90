#include "fintrf.h"

subroutine mexFunction(nlhs, plhs, nrhs, prhs)
  implicit none


! MEX arguments declarations
  integer*4 nlhs, nrhs
  mwPointer plhs(*), prhs(*)


! function declarations out of the MEX_API
  mwPointer mxGetPr, mxCreateDoubleMatrix
  external  mxGetPr, mxCreateDoubleMatrix
  external  mxCopyPtrToReal8, mxCopyReal8ToPtr, mexErrMsgTxt
  

! HWM14 routine (defined in hwm14.f90) declaration as external subroutine
  external  hwm14  
  

! Pointers to MATLAB data
! Declaration of variables with typ mwPointer
! Syntax:
! Typ :: variable1, variable2, ...

 mwPointer :: p_iyd, p_sec, p_alt, p_glat, p_glon
 mwPointer :: p_stl, p_f107a, p_f107, p_ap, p_wout


! Declaration of double-precision (64-bit float) Fortran variables to receive MATLAB input/output

 double precision :: d_iyd, d_sec, d_alt, d_glat, d_glon
 double precision :: d_stl, d_f107a, d_f107
 double precision :: d_ap(2), d_w(2)


! Declaration of Fortran variables for HWM14 call
! Variables that are passed to hwm14 (in expected format)
! iyd --> 32-bit integer
! sec, alt, glat, glon, stl, f107a, f107, ap(2), w(2) --> 32-bit float

 integer*4 :: iyd
 real*4    :: sec, alt, glat, glon, stl, f107a, f107
 real*4    :: ap(2), w(2) 


! ------------------------------------------------------------
! Check number of input and output arguments
! ------------------------------------------------------------
 ! loop condition syntax:
 ! .ne.	not equal	
 ! .eq.	equal	
 ! .gt.	greater than	
 ! .lt.	less than	
 ! .ge.	greater or equal	
 ! .le.	less or equal 
 
  if (nrhs .ne. 9) then
   call mexErrMsgTxt('hwm14_mex: Exactly 9 input arguments are required.')
  endif

  if (nlhs .gt. 1) then
   call mexErrMsgTxt('hwm14_mex: Only one output argument is allowed.')
  endif


! ------------------------------------------------------------
! Get input arguments from MATLAB and convert types
! ------------------------------------------------------------
! Syntax:
! prsh(n) pointer to the n-th MATLAB input 
! mxGetPr(...) delivers pointer to the double data
! 1. p_xyz points to the location in MATLAB memory where the input data is located 
! 2. call mxCopyPtrToReal8(source, target variable, number of values) copy the double-values from matlab to fortran
! 3. xyz = real(d_xyz) for real*4 or xyz = int(d_xyz) for integer*4 convert Fortran double to hwm14 expected data typ

  ! iyd (INTEGER*4)
   p_iyd = mxGetPr(prhs(1))
   call mxCopyPtrToReal8(p_iyd, d_iyd, 1)
   iyd = int(d_iyd)

  ! sec
   p_sec = mxGetPr(prhs(2))
   call mxCopyPtrToReal8(p_sec, d_sec, 1)
   sec = real(d_sec)

  ! alt
   p_alt = mxGetPr(prhs(3))
   call mxCopyPtrToReal8(p_alt, d_alt, 1)
   alt = real(d_alt)

  ! glat
   p_glat = mxGetPr(prhs(4))
   call mxCopyPtrToReal8(p_glat, d_glat, 1)
   glat = real(d_glat)

  ! glon
   p_glon = mxGetPr(prhs(5))
   call mxCopyPtrToReal8(p_glon, d_glon, 1)
   glon = real(d_glon)

  ! stl
   p_stl = mxGetPr(prhs(6))
   call mxCopyPtrToReal8(p_stl, d_stl, 1)
   stl = real(d_stl)

  ! f107a
   p_f107a = mxGetPr(prhs(7))
   call mxCopyPtrToReal8(p_f107a, d_f107a, 1)
   f107a = real(d_f107a)

  ! f107
   p_f107 = mxGetPr(prhs(8))
   call mxCopyPtrToReal8(p_f107, d_f107, 1)
   f107  = real(d_f107)

  ! ap(2) – 2-element vector
   p_ap = mxGetPr(prhs(9))
   call mxCopyPtrToReal8(p_ap, d_ap, 2)
   ap(1) = real(d_ap(1))
   ap(2) = real(d_ap(2))


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