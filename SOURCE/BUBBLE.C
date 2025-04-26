
/*
    Copyright (c) 1992-2025 by Armin Hierstetter    This file is part of BubbleBook for Atari ST series.    BubbleBook is free software: you can redistribute it and/or modify it under    the terms of the GNU General Public License as published by the Free    Software Foundation, either version 3 of the License, or later.        BubbleBook is distributed in the hope that it will be useful, but WITHOUT    ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or    FITNESS FOR A PARTICULAR PURPOSE.        More about the GNU General Public License: http://www.gnu.org/licenses/*/
#include <aes.h>
#include <vdi.h>

#include "bubble.rsh"

#define BUBBLE_WIDTH	32
#define BUBBLE_HEIGHT	28
#define TOGGLES			6
#define IDLE_IN_MS		150
#define PREFS_OFFSET	0x3C

int save_prefs(void);

extern int _setting_1, _setting_2;
int xres, yres;

/* Will be set to correct drive in bubstart.s */
char bubble_pathname[]="X:\BUBBLE.ACC";

void set_button_state(OBJECT* dialog, int state) {
	
	if (state & 1)
		dialog[BUTTON_SHIFT_R].ob_state |= SELECTED;
	else
		dialog[BUTTON_SHIFT_R].ob_state &= ~SELECTED;

	if (state & 2)
		dialog[BUTTON_SHIFT_L].ob_state |= SELECTED;
	else
		dialog[BUTTON_SHIFT_L].ob_state &= ~SELECTED;

	if (state & 4)
		dialog[BUTTON_CONTROL].ob_state |= SELECTED;
	else
		dialog[BUTTON_CONTROL].ob_state &= ~SELECTED;

	if (state & 8)
		dialog[BUTTON_ALTERNATE].ob_state |= SELECTED;
	else
	dialog[BUTTON_ALTERNATE].ob_state &= ~SELECTED;
}

int get_button_state(OBJECT* dialog) {
	int state=0;

	if (dialog[BUTTON_SHIFT_R].ob_state & SELECTED)
		state |= 1;
	if (dialog[BUTTON_SHIFT_L].ob_state & SELECTED)
		state |= 2;
	if (dialog[BUTTON_CONTROL].ob_state & SELECTED)
		state |= 4;
	if (dialog[BUTTON_ALTERNATE].ob_state & SELECTED)
		state |= 8;

	return state;
}

int main(void) {

	int i, x, y, w, h, handle, msg_buffer[8];
	int mouse_x, mouse_y, mouse_button, kbd_state, dummy;

	OBJECT *dialog;
	OBJECT *bubbles;

	menu_register(appl_init(), "  BubbleBook");
	handle=graf_handle(&xres,&yres,&dummy, &dummy);
	(void) handle; 				/* to get rid of compiler warning */

	dialog=&rs_object[0];
	bubbles=&rs_object[15];
	
	for (i = 0; i < 15; i++)
		rsrc_obfix(dialog,i);

	/* set buttons in dialog according to setting */
	set_button_state(dialog, _setting_1);

	/* set on/off button, default is ON  */
	if (_setting_2 == BUTTON_ON || _setting_2 == BUTTON_OFF)
		dialog[_setting_2].ob_state |= SELECTED;
	else
		dialog[BUTTON_ON].ob_state |= SELECTED;

	/* Center dialog only once, not every time accessory is opened */
	form_center(dialog, &x, &y, &w, &h);

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
			if (kbd_state == get_button_state(dialog)) {
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

				for (i=0;i<TOGGLES;i++) {
					objc_draw(bubbles,bubble,0,mouse_x+offset_x,mouse_y+offset_y,BUBBLE_WIDTH,BUBBLE_HEIGHT);
					evnt_timer(IDLE_IN_MS,0);
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
				int state=0, on_off_state=0;

				/* event ack */				
				msg_buffer[0] = 0;

				/* save state of hotkey settings */
				state=get_button_state(dialog);

				/* save current on/off status*/
				if (dialog[BUTTON_ON].ob_state & SELECTED)
					on_off_state=BUTTON_ON;
				else
					on_off_state=BUTTON_OFF;

				wind_update(BEG_UPDATE);

				form_dial(FMD_START, 0, 0, 0, 0, x, y, w, h);
				form_dial(FMD_GROW, 0, 0, 0, 0, x, y, w, h);

				objc_draw(dialog, 0, 2, x, y, w, h);

				do {

					exit_object=form_do(dialog,0) & 0x7FFF;

					/* save prefs */
					if (exit_object == BUTTON_SAVE) {

						/* get state of hotkey settings */
						_setting_1=get_button_state(dialog);

						/* get on/off status*/
						if (dialog[BUTTON_ON].ob_state & SELECTED)
							_setting_2=BUTTON_ON;
						else
							_setting_2=BUTTON_OFF;

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

				/* restore state of hot keys if user clicks cancel */
				if (exit_object == BUTTON_CANCEL) {
					/* restore saved setting */
					set_button_state(dialog, state);

					/* unselect on and off */
					dialog[BUTTON_ON].ob_state &= ~SELECTED;
					dialog[BUTTON_OFF].ob_state &= ~SELECTED;

					if (on_off_state==BUTTON_ON)
						dialog[BUTTON_ON].ob_state |= SELECTED;
					else 
						dialog[BUTTON_OFF].ob_state |= SELECTED;
				}
				/* unselect exit_object */
				dialog[exit_object].ob_state &= ~SELECTED;
			}
		}
	}
}
