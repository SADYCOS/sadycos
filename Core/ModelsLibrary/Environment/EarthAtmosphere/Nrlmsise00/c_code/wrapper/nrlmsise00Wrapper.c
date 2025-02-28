#include "nrlmsise00Wrapper.h"

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
    double t[2]     /* output temperatures */)
{
    // Declare input, flags, and output structs
    struct nrlmsise_input input;
    struct nrlmsise_flags flags;
    struct nrlmsise_output output;

    struct ap_array ap_a;

    // Populate input struct with input values
    input.year = year;
    input.doy = doy;
    input.sec = sec;
    input.alt = alt;
    input.g_lat = g_lat;
    input.g_long = g_long;
    input.lst = sec/3600 + g_long/15; // suggested by NRLMSISE-00 documentation
    input.f107A = f107A;
    input.f107 = f107;
    input.ap = a[0]; // daily ap

    for (int i = 0; i < 7; i++)
    {
        ap_a.a[i] = a[i];
    }
    input.ap_a = &ap_a;

    // Populate flags struct with switches
    for (int i = 0; i < 24; i++)
    {
        flags.switches[i] = switches[i];
    }
    
    // Call the NRLMSISE-00 model
    gtd7d(&input, &flags, &output);

    // Populate output arrays
    for (int i = 0; i < 9; i++)
    {
        d[i] = output.d[i];
    }
    for (int i = 0; i < 2; i++)
    {
        t[i] = output.t[i];
    }
}