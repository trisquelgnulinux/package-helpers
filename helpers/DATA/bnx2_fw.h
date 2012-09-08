/* bnx2_fw.h: Broadcom NX2 network driver.
 *
 * Copyright (c) 2004, 2005, 2006 Broadcom Corporation
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, except as noted below.
 *
 * This file contains firmware data derived from proprietary unpublished
 * source code, Copyright (c) 2004, 2005, 2006 Broadcom Corporation.
 *
 * Permission is hereby granted for the distribution of this firmware data
 * in hexadecimal or equivalent format, provided this copyright notice is
 * accompanying it.
 */

static u8 bnx2_COM_b06FwText[] = {
	};

static const u32 bnx2_COM_b06FwData[(0x0/4) + 1] = { 0x0 };
static const u32 bnx2_COM_b06FwRodata[(0x88/4) + 1] = {
	};

static struct fw_info bnx2_com_fw_06 = {
	.ver_major			= 0x3,
	.ver_minor			= 0x4,
	.ver_fix			= 0x3,

	.start_addr			= 0x080000b4,

	.text_addr			= 0x08000000,
	.text_len			= 0x7d54,
	.text_index			= 0x0,
	.gz_text			= bnx2_COM_b06FwText,
	.gz_text_len			= sizeof(bnx2_COM_b06FwText),

	.data_addr			= 0x08007e00,
	.data_len			= 0x0,
	.data_index			= 0x0,
	.data				= bnx2_COM_b06FwData,

	.sbss_addr			= 0x08007e00,
	.sbss_len			= 0x60,
	.sbss_index			= 0x0,

	.bss_addr			= 0x08007e60,
	.bss_len			= 0x88,
	.bss_index			= 0x0,

	.rodata_addr			= 0x08007d58,
	.rodata_len			= 0x88,
	.rodata_index			= 0x0,
	.rodata				= bnx2_COM_b06FwRodata,
};

static u8 bnx2_RXP_b06FwText[] = {
 };

static u32 bnx2_RXP_b06FwData[(0x0/4) + 1] = { 0x0 };
static u32 bnx2_RXP_b06FwRodata[(0x278/4) + 1] = {
	 };

static struct fw_info bnx2_rxp_fw_06 = {
	.ver_major			= 0x2,
	.ver_minor			= 0x8,
	.ver_fix			= 0x17,

	.start_addr			= 0x08003184,

	.text_addr			= 0x08000000,
	.text_len			= 0x6728,
	.text_index			= 0x0,
	.gz_text			= bnx2_RXP_b06FwText,
	.gz_text_len			= sizeof(bnx2_RXP_b06FwText),

	.data_addr			= 0x080069c0,
	.data_len			= 0x0,
	.data_index			= 0x0,
	.data				= bnx2_RXP_b06FwData,

	.sbss_addr			= 0x080069c0,
	.sbss_len			= 0x2c,
	.sbss_index			= 0x0,

	.bss_addr			= 0x080069f0,
	.bss_len			= 0x13dc,
	.bss_index			= 0x0,

	.rodata_addr			= 0x08006728,
	.rodata_len			= 0x278,
	.rodata_index			= 0x0,
	.rodata				= bnx2_RXP_b06FwRodata,
};

static u8 bnx2_rv2p_proc1[] = {
 };

static u8 bnx2_rv2p_proc2[] = {
 };

static u8 bnx2_TPAT_b06FwText[] = {
 };

static u32 bnx2_TPAT_b06FwData[(0x0/4) + 1] = { 0x0 };
static u32 bnx2_TPAT_b06FwRodata[(0x0/4) + 1] = { 0x0 };

static struct fw_info bnx2_tpat_fw_06 = {
	.ver_major			= 0x1,
	.ver_minor			= 0x0,
	.ver_fix			= 0x0,

	.start_addr			= 0x08000860,

	.text_addr			= 0x08000800,
	.text_len			= 0x122c,
	.text_index			= 0x0,
	.gz_text			= bnx2_TPAT_b06FwText,
	.gz_text_len			= sizeof(bnx2_TPAT_b06FwText),

	.data_addr			= 0x08001a60,
	.data_len			= 0x0,
	.data_index			= 0x0,
	.data				= bnx2_TPAT_b06FwData,

	.sbss_addr			= 0x08001a60,
	.sbss_len			= 0x34,
	.sbss_index			= 0x0,

	.bss_addr			= 0x08001aa0,
	.bss_len			= 0x250,
	.bss_index			= 0x0,

	.rodata_addr			= 0x00000000,
	.rodata_len			= 0x0,
	.rodata_index			= 0x0,
	.rodata				= bnx2_TPAT_b06FwRodata,
};

static u8 bnx2_TXP_b06FwText[] = {
};

static u32 bnx2_TXP_b06FwData[(0x0/4) + 1] = { 0x0 };
static u32 bnx2_TXP_b06FwRodata[(0x0/4) + 1] = { 0x0 };

static struct fw_info bnx2_txp_fw_06 = {
	.ver_major			= 0x1,
	.ver_minor			= 0x0,
	.ver_fix			= 0x0,

	.start_addr			= 0x080034b0,

	.text_addr			= 0x08000000,
	.text_len			= 0x5748,
	.text_index			= 0x0,
	.gz_text			= bnx2_TXP_b06FwText,
	.gz_text_len			= sizeof(bnx2_TXP_b06FwText),

	.data_addr			= 0x08005760,
	.data_len			= 0x0,
	.data_index			= 0x0,
	.data				= bnx2_TXP_b06FwData,

	.sbss_addr			= 0x08005760,
	.sbss_len			= 0x38,
	.sbss_index			= 0x0,

	.bss_addr			= 0x080057a0,
	.bss_len			= 0x1c4,
	.bss_index			= 0x0,

	.rodata_addr			= 0x00000000,
	.rodata_len			= 0x0,
	.rodata_index			= 0x0,
	.rodata				= bnx2_TXP_b06FwRodata,
};

