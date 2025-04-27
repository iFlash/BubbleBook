
/*
    Copyright (c) 1992-2025 by Armin Hierstetter    This file is part of BubbleBook for Atari ST series.    BubbleBook is free software: you can redistribute it and/or modify it under    the terms of the GNU General Public License as published by the Free    Software Foundation, either version 3 of the License, or later.        BubbleBook is distributed in the hope that it will be useful, but WITHOUT    ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or    FITNESS FOR A PARTICULAR PURPOSE.        More about the GNU General Public License: http://www.gnu.org/licenses/*/
#include <aes.h>
#include <vdi.h>

#include "bubble.rsh"

#define BUBBLE_WIDTH	32
#define BUBBLE_HEIGHT	28
#define IDLE_IN_MS		150
#define PREFS_OFFSET	0x3C

int save_prefs(void);

extern int _setting_1, _setting_2, _setting_3;

int xres, yres;

/* PATHNAME; will be set to correct drive in bubstart.s */
char bubble_pathname[]="X:\BUBBLE.ACC";

void set_button_states(OBJECT* dialog) {
	
	/* KBD Buttons */
	if (_setting_1 & 1)
		dialog[BUTTON_SHIFT_R].ob_state |= SELECTED;
	else
		dialog[BUTTON_SHIFT_R].ob_state &= ~SELECTED;

	if (_setting_1 & 2)
		dialog[BUTTON_SHIFT_L].ob_state |= SELECTED;
	else
		dialog[BUTTON_SHIFT_L].ob_state &= ~SELECTED;

	if (_setting_1 & 4)
		dialog[BUTTON_CONTROL].ob_state |= SELECTED;
	else
		dialog[BUTTON_CONTROL].ob_state &= ~SELECTED;

	if (_setting_1 & 8)
		dialog[BUTTON_ALTERNATE].ob_state |= SELECTED;
	else
		dialog[BUTTON_ALTERNATE].ob_state &= ~SELECTED;

	/* On/Off status */
	/* unselect on and off */
	dialog[BUTTON_ON].ob_state &= ~SELECTED;
	dialog[BUTTON_OFF].ob_state &= ~SELECTED;

	if (_setting_2==BUTTON_OFF)
		dialog[BUTTON_OFF].ob_state |= SELECTED;
	else 
		dialog[BUTTON_ON].ob_state |= SELECTED;

	/* Blink count */
	dialog[BLINK_COUNT].ob_spec.tedinfo->te_ptext[0]=_setting_3+48;
}

void get_button_states(OBJECT* dialog) {

	/* reset value */
	_setting_1=0;

	/* KBD Buttons */
	if (dialog[BUTTON_SHIFT_R].ob_state & SELECTED)
		_setting_1 |= 1;
	if (dialog[BUTTON_SHIFT_L].ob_state & SELECTED)
		_setting_1 |= 2;
	if (dialog[BUTTON_CONTROL].ob_state & SELECTED)
		_setting_1 |= 4;
	if (dialog[BUTTON_ALTERNATE].ob_state & SELECTED)
		_setting_1 |= 8;

	/* On/Off status */
	/* unselect on and off */
	if (dialog[BUTTON_ON].ob_state & SELECTED)
		_setting_2 = BUTTON_ON;
	else
		_setting_2 = BUTTON_OFF;

	/* Blink count */
	_setting_3=dialog[BLINK_COUNT].ob_spec.tedinfo->te_ptext[0]-48;

	if (_setting_3 < 1 || _setting_3 > 9) {
		_setting_3 = 1;
		dialog[BLINK_COUNT].ob_spec.tedinfo->te_ptext[0]=49;
	}
}

int main(void) {

	int i, x, y, w, h, handle, msg_buffer[8];
	int mouse_x, mouse_y, mouse_button, kbd_state, dummy;

	OBJECT *dialog;
	OBJECT *help;
	OBJECT *bubbles;

	menu_register(appl_init(), "  BubbleBook");
	handle=graf_handle(&xres,&yres,&dummy, &dummy);

	(void) handle;	/* to get rid of compiler warning */

	dialog=rs_trindex[DIALOG_BUBBLE];
	help=rs_trindex[DIALOG_HELP];
	bubbles=rs_trindex[BUBBLES];
	
	for (i = 0; i < 31; i++)
		rsrc_obfix(dialog,i);

	set_button_states(dialog);

	/* Center dialogs only once, not every time accessory is opened */
	/* Note: As both dialogs have exactly the same size, we can 	*/
	/* overwrite x, y, w, h without trouble							*/

	form_center(dialog, &x, &y, &w, &h);
	form_center(help, &x, &y, &w, &h);

	while (1) {
		int events = MU_TIMER|MU_MESAG;

		/* only check for button presses when active */
		if (dialog[BUTTON_ON].ob_state & SELECTED)
			events |= MU_BUTTON;

		events = evnt_multi( events,
					1,0x02,0x02,					/* Mouse Button */
					0,0,0,0,0,						/* Mouse Event1 */
					0,0,0,0,0,						/* Mouse Event2 */			
					msg_buffer,						/* Message		*/
					IDLE_IN_MS,0,					/* Timer		*/
					&mouse_x,&mouse_y,&mouse_button,/* Mouse		*/
					&kbd_state,						/* Keyboard-St.	*/
					&dummy,&dummy					/* Keys			*/
				);

		/* Mouse button pressed? */
		if (events & MU_BUTTON) {

			/* only show if kbd_state matches hotkey settings */
			if (kbd_state == _setting_1) {
	
				int offset_x=-BUBBLE_WIDTH;
				int offset_y=-BUBBLE_HEIGHT;
				int bubble=BUBBLE_TAIL_BR;

				if (mouse_x<BUBBLE_WIDTH) {
					offset_x=0;

					if (mouse_y<BUBBLE_HEIGHT + 2 * yres) {
						offset_y=BUBBLE_HEIGHT-yres/2;
						offset_x=xres;

						bubble=BUBBLE_TAIL_TL;
					}
					else
						bubble=BUBBLE_TAIL_BL;
				}
				else if (mouse_y<BUBBLE_HEIGHT + 2 * yres) {
					offset_y=BUBBLE_HEIGHT-yres/2;
					bubble=BUBBLE_TAIL_TR;
				}

				bubbles[bubble].ob_x=mouse_x+offset_x;
				bubbles[bubble].ob_y=mouse_y+offset_y;

				wind_update(BEG_UPDATE);
				form_dial(FMD_START,0,0,0,0,mouse_x+offset_x,mouse_y+offset_y,BUBBLE_WIDTH,BUBBLE_HEIGHT);

				for (i=0;i<_setting_3*2;i++) {
					/* draw the bubble */
					objc_draw(bubbles,bubble,0,mouse_x+offset_x,mouse_y+offset_y,BUBBLE_WIDTH,BUBBLE_HEIGHT);

					evnt_timer(IDLE_IN_MS,0);

					/* toggle selected state for bubble to blink */
					bubbles[bubble].ob_state^=SELECTED;
				}

				form_dial(FMD_FINISH,0,0,0,0,mouse_x+offset_x, mouse_y+offset_y,BUBBLE_WIDTH,BUBBLE_HEIGHT);
				wind_update(END_UPDATE);
			}
		}

		/* Accessorry opened? */
		if (events & MU_MESAG) {

			if (msg_buffer[0]==AC_OPEN) {
				int exit_object;

				/* event ack */				
				msg_buffer[0] = 0;

				dialog_begin:

				wind_update(BEG_UPDATE);
				form_dial(FMD_START, 0, 0, 0, 0, x, y, w, h);
				form_dial(FMD_GROW, 0, 0, 0, 0, x, y, w, h);

				objc_draw(dialog, 0, 3, x, y, w, h);

				do {
					/* NOTE: Mask out double click flag bit 15! */
					exit_object=form_do(dialog,BLINK_COUNT) & 0x7FFF;

					/* save prefs clicked*/
					if (exit_object == BUTTON_SAVE) {

						/* get current states */
						get_button_states(dialog);
						objc_draw(dialog, BLINK_COUNT, 1, x, y, w, h);

						/* change cancel button to disabled as cancel makes */
						/* no more sense now that the status has been saved */
						dialog[BUTTON_CANCEL].ob_state |= DISABLED;
						objc_draw(dialog, BUTTON_CANCEL, 1, x, y, w, h);
		
						/* change button text to "SAVING" */
						dialog[BUTTON_SAVE].ob_spec.free_string="SAVING";
						objc_draw(dialog, BUTTON_SAVE, 1, x, y, w, h);
						evnt_timer(500,0);

						/* save prefs in accessory */
						if (save_prefs()) {

							/* change button text to "DONE" */
							dialog[BUTTON_SAVE].ob_spec.free_string="SAVED";
							objc_draw(dialog, BUTTON_SAVE, 1, x, y, w, h);
							evnt_timer(1000,0);

							/* and back to "SAVE" */
							dialog[BUTTON_SAVE].ob_spec.free_string="SAVE";
							objc_draw(dialog, BUTTON_SAVE, 1, x, y, w, h);
						}
						else {
							/* change button text to "ERROR!" */
							dialog[BUTTON_SAVE].ob_spec.free_string="ERROR";
							objc_draw(dialog, BUTTON_SAVE, 1, x, y, w, h);
							evnt_timer(1000,0);

							/* and back to "SAVE" */
							dialog[BUTTON_SAVE].ob_spec.free_string="SAVE";
							objc_draw(dialog, BUTTON_SAVE, 1, x, y, w, h);
						}
						dialog[BUTTON_SAVE].ob_state &= ~SELECTED;
						objc_draw(dialog, BUTTON_SAVE, 1, x, y, w, h);
					}
				} while (exit_object == BUTTON_SAVE);

				form_dial(FMD_SHRINK, 0, 0, 0, 0, x, y, w, h);
				form_dial(FMD_FINISH, 0, 0, 0, 0, x, y, w, h);

				wind_update(END_UPDATE);

				/* unselect exit_object */
				dialog[exit_object].ob_state &= ~SELECTED;

				/* Enable cancel button again as it might have been disabled */
				dialog[BUTTON_CANCEL].ob_state &= ~DISABLED;

				/* restore state of hot keys if user clicks cancel */
				if (exit_object == BUTTON_CANCEL)
					set_button_states(dialog);
				else if (exit_object == BUTTON_OK)
					get_button_states(dialog);
				/* help was clicked	*/
				else {
					int exit_object;

					wind_update(BEG_UPDATE);
					form_dial(FMD_START, 0, 0, 0, 0, x, y, w, h);
					form_dial(FMD_GROW, 0, 0, 0, 0, x, y, w, h);

					objc_draw(help, 0, 2, x, y, w, h);
					exit_object=form_do(help,0) & 0x7FFF;

					form_dial(FMD_SHRINK, 0, 0, 0, 0, x, y, w, h);
					form_dial(FMD_FINISH, 0, 0, 0, 0, x, y, w, h);

					wind_update(END_UPDATE);
					help[exit_object].ob_state &= ~SELECTED;

					/* this is the very first time I have used 'goto' in C  */
					/* in this case, though, I think it is the most         */
					/* efficient/elegant way to get back from the help      */
					/* dialog to the main dialog.                           */

					/* of course, you could do a do/while thing or similar, */
					/* but that felt really odd to do just to avoid 'goto'. */
					/* So: 'goto' it is!                                    */

					goto dialog_begin;
				}
			}
		}
	}
}
