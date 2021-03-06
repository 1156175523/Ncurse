/****************************************************************************
 * Copyright (c) 1998 Free Software Foundation, Inc.                        *
 *                                                                          *
 * Permission is hereby granted, free of charge, to any person obtaining a  *
 * copy of this software and associated documentation files (the            *
 * "Software"), to deal in the Software without restriction, including      *
 * without limitation the rights to use, copy, modify, merge, publish,      *
 * distribute, distribute with modifications, sublicense, and/or sell       *
 * copies of the Software, and to permit persons to whom the Software is    *
 * furnished to do so, subject to the following conditions:                 *
 *                                                                          *
 * The above copyright notice and this permission notice shall be included  *
 * in all copies or substantial portions of the Software.                   *
 *                                                                          *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS  *
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF               *
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.   *
 * IN NO EVENT SHALL THE ABOVE COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,   *
 * DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR    *
 * OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR    *
 * THE USE OR OTHER DEALINGS IN THE SOFTWARE.                               *
 *                                                                          *
 * Except as contained in this notice, the name(s) of the above copyright   *
 * holders shall not be used in advertising or otherwise to promote the     *
 * sale, use or other dealings in this Software without prior written       *
 * authorization.                                                           *
 ****************************************************************************/

/****************************************************************************
 *  Author: Zeyd M. Ben-Halim <zmbenhal@netcom.com> 1992,1995               *
 *     and: Eric S. Raymond <esr@snark.thyrsus.com>                         *
 ****************************************************************************/

/* $Id: capdefaults.c,v 1.7 1998/02/11 12:13:45 tom Exp $ */

	/*
	 * Compute obsolete capabilities.  The reason this is an include file
	 * is that the two places where it's needed want the macros to
	 * generate offsets to different structures.  See the file Caps for
	 * explanations of these conversions.
	 *
	 * Note: This code is the functional inverse of the first part
	 * of postprocess_entry().
	 */
	{
		char *sp;
		int capval;

#define EXTRACT_DELAY(str)	(sp = strchr(str, '*'), sp ? atoi(sp+1) : 0)

		/* current (4.4BSD) capabilities marked obsolete */
		if (VALID_STRING(carriage_return)
				&& (capval = EXTRACT_DELAY(carriage_return)))
			carriage_return_delay = capval;
		if (VALID_STRING(newline) && (capval = EXTRACT_DELAY(newline)))
			new_line_delay = capval;

		/* current (4.4BSD) capabilities not obsolete */
		if (!VALID_STRING(termcap_init2) && VALID_STRING(init_3string))
		{
			termcap_init2 = init_3string;
			init_3string = (char *)NULL;
		}
		if (VALID_STRING(reset_1string)
			&& !VALID_STRING(reset_2string)
			&& VALID_STRING(reset_3string))
		{
			termcap_reset = reset_1string;
			reset_1string = (char *)NULL;
		}
#if USE_XMC_SUPPORT
		if (magic_cookie_glitch_ul < 0 && magic_cookie_glitch && VALID_STRING(enter_underline_mode))
			magic_cookie_glitch_ul = magic_cookie_glitch;
#else
		magic_cookie_glitch_ul = -1;
#endif

		/* totally obsolete capabilities */
		linefeed_is_newline = VALID_STRING(newline)
					&& (strcmp("\n", newline) == 0);
		if (VALID_STRING(cursor_left)
				&& (capval = EXTRACT_DELAY(cursor_left)))
			backspace_delay = capval;
		if (VALID_STRING(tab) && (capval = EXTRACT_DELAY(tab)))
			horizontal_tab_delay = capval;
#undef EXTRACT_DELAY
	}
