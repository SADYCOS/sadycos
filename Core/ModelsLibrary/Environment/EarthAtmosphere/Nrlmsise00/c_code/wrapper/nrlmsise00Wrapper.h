#include "nrlmsise-00.h"

void nrlmsise00Wrapper(int year,      /* year, currently ignored */
	int doy,       /* day of year */
	double sec,    /* seconds in day (UT) */
	double alt,    /* altitude in kilometers */
	double g_lat,  /* geodetic latitude */
	double g_long, /* geodetic longitude */
	double f107A,  /* 81 day average of F10.7 flux (centered on doy) */
	double f107,   /* daily F10.7 flux for previous day */
	double a[7], /* Array containing magnetic values */
    int switches[24], /* switches */
    double d[9],    /* output densities */
    double t[2]     /* output temperatures */);