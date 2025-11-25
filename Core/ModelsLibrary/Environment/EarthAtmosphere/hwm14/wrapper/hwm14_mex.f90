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