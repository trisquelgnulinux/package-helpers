/* bnx2_fw2.h: Broadcom NX2 network driver.
 *
 * Copyright (c) 2004, 2005, 2006, 2007 Broadcom Corporation
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, except as noted below.
 *
 * This file contains firmware data derived from proprietary unpublished
 * source code, Copyright (c) 2004, 2005, 2006, 2007 Broadcom Corporation.
 *
 * Permission is hereby granted for the distribution of this firmware data
 * in hexadecimal or equivalent format, provided this copyright notice is
 * accompanying it.
 */

static u8 bnx2_COM_b09FwText[] = {
};

static const u32 bnx2_COM_b09FwData[(0x0/4) + 1] = { 0x0 };
static const u32 bnx2_COM_b09FwRodata[(0x88/4) + 1] = {
 };

static struct fw_info bnx2_com_fw_09 = {
	/* Firmware version:  3.7.1 */
	.ver_major			= 0x3,
	.ver_minor			= 0x7,
	.ver_fix			= 0x1,

	.start_addr			= 0x080000b4,

	.text_addr			= 0x08000000,
	.text_len			= 0x7e94,
	.text_index			= 0x0,
	.gz_text			= bnx2_COM_b09FwText,
	.gz_text_len			= sizeof(bnx2_COM_b09FwText),

	.data_addr			= 0x08007f40,
	.data_len			= 0x0,
	.data_index			= 0x0,
	.data				= bnx2_COM_b09FwData,

	.sbss_addr			= 0x08007f40,
	.sbss_len			= 0x60,
	.sbss_index			= 0x0,

	.bss_addr			= 0x08007fa0,
	.bss_len			= 0x88,
	.bss_index			= 0x0,

	.rodata_addr			= 0x08007e98,
	.rodata_len			= 0x88,
	.rodata_index			= 0x0,
	.rodata				= bnx2_COM_b09FwRodata,
};

static u8 bnx2_CP_b09FwText[] = {
 };

static const u32 bnx2_CP_b09FwData[(0x0/4) + 1] = { 0x0 };
static const u32 bnx2_CP_b09FwRodata[(0x118/4) + 1] = {
 };

static struct fw_info bnx2_cp_fw_09 = {
	/* Firmware version:  3.7.1 */
	.ver_major			= 0x3,
	.ver_minor			= 0x7,
	.ver_fix			= 0x1,

	.start_addr			= 0x0800006c,

	.text_addr			= 0x08000000,
	.text_len			= 0x6fd0,
	.text_index			= 0x0,
	.gz_text			= bnx2_CP_b09FwText,
	.gz_text_len			= sizeof(bnx2_CP_b09FwText),

	.data_addr			= 0x08007100,
	.data_len			= 0x0,
	.data_index			= 0x0,
	.data				= bnx2_CP_b09FwData,

	.sbss_addr			= 0x08007104,
	.sbss_len			= 0xa9,
	.sbss_index			= 0x0,

	.bss_addr			= 0x080071b0,
	.bss_len			= 0x3b0,
	.bss_index			= 0x0,

	.rodata_addr			= 0x08006fd0,
	.rodata_len			= 0x118,
	.rodata_index			= 0x0,
	.rodata				= bnx2_CP_b09FwRodata,
};

static u8 bnx2_RXP_b09FwText[] = {
 };

static struct fw_info bnx2_rxp_fw_09 = {
	/* Firmware version:  3.7.1 */
	.ver_major			= 0x3,
	.ver_minor			= 0x7,
	.ver_fix			= 0x1,

	.start_addr			= 0x08003184,

	.text_addr			= 0x08000000,
	.text_len			= 0x6788,
	.text_index			= 0x0,
	.gz_text			= bnx2_RXP_b09FwText,
	.gz_text_len			= sizeof(bnx2_RXP_b09FwText),

	.data_addr			= 0x08006a20,
	.data_len			= 0x0,
	.data_index			= 0x0,
	.data				= bnx2_RXP_b09FwData,

	.sbss_addr			= 0x08006a20,
	.sbss_len			= 0x20,
	.sbss_index			= 0x0,

	.bss_addr			= 0x08006a40,
	.bss_len			= 0x13dc,
	.bss_index			= 0x0,

	.rodata_addr			= 0x08006788,
	.rodata_len			= 0x278,
	.rodata_index			= 0x0,
	.rodata				= bnx2_RXP_b09FwRodata,
};

static u8 bnx2_TPAT_b09FwText[] = {
 };

static const u32 bnx2_TPAT_b09FwData[(0x0/4) + 1] = { 0x0 };
static const u32 bnx2_TPAT_b09FwRodata[(0x0/4) + 1] = { 0x0 };

static struct fw_info bnx2_tpat_fw_09 = {
	/* Firmware version:  3.7.1 */
	.ver_major			= 0x3,
	.ver_minor			= 0x7,
	.ver_fix			= 0x1,

	.start_addr			= 0x08000860,

	.text_addr			= 0x08000800,
	.text_len			= 0x188c,
	.text_index			= 0x0,
	.gz_text			= bnx2_TPAT_b09FwText,
	.gz_text_len			= sizeof(bnx2_TPAT_b09FwText),

	.data_addr			= 0x080020c0,
	.data_len			= 0x0,
	.data_index			= 0x0,
	.data				= bnx2_TPAT_b09FwData,

	.sbss_addr			= 0x080020c8,
	.sbss_len			= 0x30,
	.sbss_index			= 0x0,

	.bss_addr			= 0x08002100,
	.bss_len			= 0x850,
	.bss_index			= 0x0,

	.rodata_addr			= 0x00000000,
	.rodata_len			= 0x0,
	.rodata_index			= 0x0,
	.rodata				= bnx2_TPAT_b09FwRodata,
};

static u8 bnx2_TXP_b09FwText[] = {
	 };

static const u32 bnx2_TXP_b09FwData[(0xd0/4) + 1] = {
	 };
static const u32 bnx2_TXP_b09FwRodata[(0x30/4) + 1] = {
	 };

static struct fw_info bnx2_txp_fw_09 = {
	/* Firmware version:  3.7.1 */
	.ver_major			= 0x3,
	.ver_minor			= 0x7,
	.ver_fix			= 0x1,

	.start_addr			= 0x08000060,

	.text_addr			= 0x08000000,
	.text_len			= 0x45b0,
	.text_index			= 0x0,
	.gz_text			= bnx2_TXP_b09FwText,
	.gz_text_len			= sizeof(bnx2_TXP_b09FwText),

	.data_addr			= 0x08004600,
	.data_len			= 0xd0,
	.data_index			= 0x0,
	.data				= bnx2_TXP_b09FwData,

	.sbss_addr			= 0x080046d0,
	.sbss_len			= 0x8c,
	.sbss_index			= 0x0,

	.bss_addr			= 0x08004760,
	.bss_len			= 0xa20,
	.bss_index			= 0x0,

	.rodata_addr			= 0x080045b0,
	.rodata_len			= 0x30,
	.rodata_index			= 0x0,
	.rodata				= bnx2_TXP_b09FwRodata,
};

