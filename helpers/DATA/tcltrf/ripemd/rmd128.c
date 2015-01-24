/*
 * Implementation of RIPEMD-128.
 *
 * Copyright (C) 2014 Legimet <legimet.calc@gmail.com>
 *
 * Permission is hereby granted, without written agreement and without
 * license or royalty fees, to use, copy, modify, and distribute this
 * software and its documentation for any purpose, provided that the
 * above copyright notice and the following two paragraphs appear in
 * all copies of this software.
 *
 * IN NO EVENT SHALL I LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL,
 * INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OF THIS
 * SOFTWARE AND ITS DOCUMENTATION, EVEN IF I HAVE BEEN ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 *
 * I SPECIFICALLY DISCLAIM ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE.  THE SOFTWARE PROVIDED HEREUNDER IS ON AN "AS IS" BASIS, AND
 * I HAVE NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES,
 * ENHANCEMENTS, OR MODIFICATIONS.
 */

#include <stdint.h>
#include <string.h>
#include "rmdcommon.h"
#include "rmd128.h"

void ripemd128_MDinit(dword *MDbuf) {
    MDbuf[0] = initvals[0];
    MDbuf[1] = initvals[1];
    MDbuf[2] = initvals[2];
    MDbuf[3] = initvals[3];
}

static inline void ripemd128_round1(dword *a, dword *b, dword *c, dword *d,
	dword *ap, dword *bp, dword *cp, dword *dp, int i, dword *X) {
    *a = rmd_rol(*a + rmd_f1(*b, *c, *d) + X[r[i]], s[i]);
    *ap = rmd_rol(*ap + rmd_f4(*bp, *cp, *dp) + X[rprime[i]] + kprime[0], sprime[i]);
}

static inline void ripemd128_round2(dword *a, dword *b, dword *c, dword *d,
	dword *ap, dword *bp, dword *cp, dword *dp, int i, dword *X) {
    *a = rmd_rol(*a + rmd_f2(*b, *c, *d) + X[r[i]] + k[0], s[i]);
    *ap = rmd_rol(*ap + rmd_f3(*bp, *cp, *dp) + X[rprime[i]] + kprime[1], sprime[i]);
}

static inline void ripemd128_round3(dword *a, dword *b, dword *c, dword *d,
	dword *ap, dword *bp, dword *cp, dword *dp, int i, dword *X) {
    *a = rmd_rol(*a + rmd_f3(*b, *c, *d) + X[r[i]] + k[1], s[i]);
    *ap = rmd_rol(*ap + rmd_f2(*bp, *cp, *dp) + X[rprime[i]] + kprime[2], sprime[i]);
}

static inline void ripemd128_round4(dword *a, dword *b, dword *c, dword *d,
	dword *ap, dword *bp, dword *cp, dword *dp, int i, dword *X) {
    *a = rmd_rol(*a + rmd_f4(*b, *c, *d) + X[r[i]] + k[2], s[i]);
    *ap = rmd_rol(*ap + rmd_f1(*bp, *cp, *dp) + X[rprime[i]], sprime[i]);
}

void ripemd128_compress(dword *MDbuf, dword *X) {
    dword a = MDbuf[0], b = MDbuf[1], c = MDbuf[2], d = MDbuf[3];
    dword ap = MDbuf[0], bp = MDbuf[1], cp = MDbuf[2], dp = MDbuf[3];
    int i;

    for (i = 0; i < 16;) {
	ripemd128_round1(&a, &b, &c, &d, &ap, &bp, &cp, &dp, i++, X);
	ripemd128_round1(&d, &a, &b, &c, &dp, &ap, &bp, &cp, i++, X);
	ripemd128_round1(&c, &d, &a, &b, &cp, &dp, &ap, &bp, i++, X);
	ripemd128_round1(&b, &c, &d, &a, &bp, &cp, &dp, &ap, i++, X);
    }

    for (i = 16; i < 32;) {
	ripemd128_round2(&a, &b, &c, &d, &ap, &bp, &cp, &dp, i++, X);
	ripemd128_round2(&d, &a, &b, &c, &dp, &ap, &bp, &cp, i++, X);
	ripemd128_round2(&c, &d, &a, &b, &cp, &dp, &ap, &bp, i++, X);
	ripemd128_round2(&b, &c, &d, &a, &bp, &cp, &dp, &ap, i++, X);
    }

    for (i = 32; i < 48;) {
	ripemd128_round3(&a, &b, &c, &d, &ap, &bp, &cp, &dp, i++, X);
	ripemd128_round3(&d, &a, &b, &c, &dp, &ap, &bp, &cp, i++, X);
	ripemd128_round3(&c, &d, &a, &b, &cp, &dp, &ap, &bp, i++, X);
	ripemd128_round3(&b, &c, &d, &a, &bp, &cp, &dp, &ap, i++, X);
    }

    for (i = 48; i < 64;) {
	ripemd128_round4(&a, &b, &c, &d, &ap, &bp, &cp, &dp, i++, X);
	ripemd128_round4(&d, &a, &b, &c, &dp, &ap, &bp, &cp, i++, X);
	ripemd128_round4(&c, &d, &a, &b, &cp, &dp, &ap, &bp, i++, X);
	ripemd128_round4(&b, &c, &d, &a, &bp, &cp, &dp, &ap, i++, X);
    }

    c += MDbuf[1] + dp;
    MDbuf[1] = MDbuf[2] + d + ap;
    MDbuf[2] = MDbuf[3] + a + bp;
    MDbuf[3] = MDbuf[0] + b + cp;
    MDbuf[0] = c;
}

void ripemd128_MDfinish(dword *MDbuf, byte *strptr, dword lswlen, dword mswlen) {
    dword X[16] = {0}; /* Initialize to all 0 */
    dword i;

    /* Copy bytes from strptr into X */
    for (i = 0; i < (lswlen & 63); i++) {
	X[i >> 2] |= (dword)strptr[i] << ((i & 3) << 3);
    }

    /* Add a 1 bit for padding */
    X[i >> 2] |= 128 << ((i & 3) << 3);

    /* length in bits is at least 448 mod 512, second block needed */
    if ((lswlen & 63) >= 56) {
	ripemd128_compress(MDbuf, X);
	memset(X, 0, 64);
    }

    /* Append the 64-bit length in the last 2 words, low-order word first */
    X[14] = lswlen << 3;
    X[15] = (mswlen << 3) + (lswlen >> 29);
    ripemd128_compress(MDbuf, X); /* Compress the final block */
}
