/*
 * Port
 *
 * This code has been extracted from the Csound opcode "portk".
 * It has been modified to work as a Soundpipe module.
 *
 * Original Author(s): Robbin Whittle, John ffitch
 * Year: 1995, 1998
 * Location: Opcodes/biquad.c
 *
 */


#include <math.h>
#include <stdlib.h>

#ifndef M_PI
#define M_PI        3.14159265358979323846
#endif

#include <AudioKit/soundpipe.h>
#include "S1DSPKernel.hpp"

int S1DSPKernel::s1_port_create(s1_port **p)
{
    *p = (s1_port*)malloc(sizeof(s1_port));
    return SP_OK;
}

int S1DSPKernel::s1_port_destroy(s1_port **p)
{
    free(*p);
    return SP_OK;
}

int S1DSPKernel::s1_port_init(sp_data *sp, s1_port *p, SPFLOAT htime)
{
    p->y[1] = 0;
    p->prvhtim = -100.0;
    p->htime = htime;

    p->sr = sp->sr;
    p->onedsr = 1.0/p->sr;
    return SP_OK;
}

int S1DSPKernel::s1_port_reset(sp_data *sp, s1_port *p, SPFLOAT *in)
{
    p->y[1] = *in;
    return SP_OK;
}
