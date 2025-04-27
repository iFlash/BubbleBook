*
*    Copyright (c) 1992-2025 by Armin Hierstetter**    This file is part of BubbleBook for Atari ST series.
**    BubbleBook is free software: you can redistribute it and/or modify it under*    the terms of the GNU General Public License as published by the Free*    Software Foundation, either version 3 of the License, or later.*    *    BubbleBook is distributed in the hope that it will be useful, but WITHOUT*    ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or*    FITNESS FOR A PARTICULAR PURPOSE.*    *    More about the GNU General Public License: http://www.gnu.org/licenses/*


*		SAVEPREF.S
*
*		Saves the preferences into BUBBLE.ACC directly at offset 0x3c.
*		Doing this in assembler saves around 2k in program size.
*		Why bother? Because we can.

		.EXPORT save_prefs

        .IMPORT _setting_1		; selected special key buttons as a bitfield
        .IMPORT _setting_2		; ID of button (BUTTON_ON / BUTTON_OFF) selected
        .IMPORT _setting_3		; number of blinks

		.IMPORT bubble_pathname	; Pathname for bubble.acc; initialized as
								; X:\BUBBLE.ACC. Correct drive is determined on 
								; startup of accessory

        .CODE
        .EVEN

save_prefs:
		move.w	#2,-(sp)		; read/write
		pea		bubble_pathname	; pathname
		move.w	#$3d,-(sp)		; Fopen
		trap	#1				; GEMDOS
		addq.l	#8,sp			; clean up stackpointer

		cmp.l	#0,d0			; Error?
		beq		end_save_prefs	; then abort

		move.l	d0,d2			; save handle for later

		move.w	#0,-(sp)		; Seek from start
		move.w	d2,-(sp)		; file handle
		move.l	#$3c,-(sp)		; offset to prefs
		move.w	#$42,-(sp)		; Fseek
		trap	#1
		lea		$a(sp),sp

		pea		_setting_1		; pointer to settings
		move.l	#6,-(sp)		; write 6 bytes (3 words)
		move.w	d2,-(sp)		; file handle
		move.w	#$40,-(sp)		; Fwrite
		trap	#1
		lea		$c(sp),sp

		move.w	d2,-(sp)		; file handle		
		move.w	#$3e,-(sp)		; Fclose
		trap	#1
		addq.l	#4,sp

		move.w	#1,d0			; All was well

end_save_prefs:
		rts

		.END
