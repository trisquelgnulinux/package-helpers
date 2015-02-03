/*
 * Common constants and functions for RIPEMD-128 and RIPEMD-160.
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

#ifndef RMDCOMMON_H
#define RMDCOMMON_H

#include <stdint.h>

/* Initial values */
static const uint32_t initvals[5] = {
    0x67452301,
    0xefcdab89,
    0x98badcfe,
    0x10325476,
    0xc3d2e1f0
};

/* Added constants */
static const uint32_t k[5] = {
    0x5a827999,
    0x6ed9eba1,
    0x8f1bbcdc,
    0xa953fd4e
};

static const uint32_t kprime[5] = {
    0x50a28be6,
    0x5c4dd124,
    0x6d703ef3,
    0x7a6d76e9,
};

/* Message selection */
static const int r[80] = {
    0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,
    7, 4, 13, 1, 10, 6, 15, 3, 12, 0, 9, 5, 2, 14, 11, 8,
    3, 10, 14, 4, 9, 15, 8, 1, 2, 7, 0, 6, 13, 11, 5, 12,
    1, 9, 11, 10, 0, 8, 12, 4, 13, 3, 7, 15, 14, 5, 6, 2,
    4, 0, 5, 9, 7, 12, 2, 10, 14, 1, 3, 8, 11, 6, 15, 13
};

static const int rprime[80] = {
     5, 14, 7, 0, 9, 2, 11, 4, 13, 6, 15, 8, 1, 10, 3, 12,
     6, 11, 3, 7, 0, 13, 5, 10, 14, 15, 8, 12, 4, 9, 1, 2,
     15, 5, 1, 3, 7, 14, 6, 9, 11, 8, 12, 2, 10, 0, 4, 13,
     8, 6, 4, 1, 3, 11, 15, 0, 5, 12, 2, 13, 9, 7, 10, 14,
     12, 15, 10, 4, 1, 5, 8, 7, 6, 2, 13, 14, 0, 3, 9, 11
};

/* Number of bits for left rotations */
static const int s[80] = {
     11, 14, 15, 12, 5, 8, 7, 9, 11, 13, 14, 15, 6, 7, 9, 8,
     7, 6, 8, 13, 11, 9, 7, 15, 7, 12, 15, 9, 11, 7, 13, 12,
     11, 13, 6, 7, 14, 9, 13, 15, 14, 8, 13, 6, 5, 12, 7, 5,
     11, 12, 14, 15, 14, 15, 9, 8, 9, 14, 5, 6, 8, 6, 5, 12,
     9, 15, 5, 11, 6, 8, 13, 12, 5, 12, 13, 14, 11, 8, 5, 6
};

static const int sprime[80] = {
     8, 9, 9, 11, 13, 15, 15, 5, 7, 7, 8, 11, 14, 14, 12, 6,
     9, 13, 15, 7, 12, 8, 9, 11, 7, 7, 12, 7, 6, 15, 13, 11,
     9, 7, 15, 11, 8, 6, 6, 14, 12, 13, 5, 14, 13, 13, 7, 5,
     15, 5, 8, 11, 14, 14, 6, 14, 6, 9, 12, 9, 12, 5, 15, 8,
     8, 5, 12, 9, 12, 5, 14, 6, 8, 13, 6, 5, 15, 13, 11, 11
};

static inline uint32_t rmd_f1(uint32_t x, uint32_t y, uint32_t z) {
    return x ^ y ^ z;
}

static inline uint32_t rmd_f2(uint32_t x, uint32_t y, uint32_t z) {
    return (x & y) | (~x & z);
}

static inline uint32_t rmd_f3(uint32_t x, uint32_t y, uint32_t z) {
    return (x | ~y) ^ z;
}

static inline uint32_t rmd_f4(uint32_t x, uint32_t y, uint32_t z) {
    return (x & z) | (y & ~z);
}

static inline uint32_t rmd_f5(uint32_t x, uint32_t y, uint32_t z) {
    return x ^ (y | ~z);
}

static inline uint32_t rmd_rol(uint32_t n, int bits) {
    return ((n << bits) | (n >> (32 - bits)));
}

#endif
