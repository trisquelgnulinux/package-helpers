/*
 * Header file for implementation of RIPEMD-128.
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

#ifndef RMD128_H
#define RMD128_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>

typedef uint32_t dword;
typedef uint16_t word;
typedef uint8_t byte;

void ripemd128_MDinit(dword *MDbuf);

void ripemd128_compress(dword *MDbuf, dword *X);

void ripemd128_MDfinish(dword *MDbuf, byte *strptr, dword lswlen, dword mswlen);

#ifdef __cplusplus
}
#endif
#endif
