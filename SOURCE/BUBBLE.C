/*
    Copyright (c) 1992-2025 by Armin Hierstetter    This file is part of BubbleBook for Atari ST series.    BubbleBook is free software: you can redistribute it and/or modify it under    the terms of the GNU General Public License as published by the Free    Software Foundation, either version 3 of the License, or later.        BubbleBook is distributed in the hope that it will be useful, but WITHOUT    ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or    FITNESS FOR A PARTICULAR PURPOSE.        More about the GNU General Public License: http://www.gnu.org/licenses/*/
#include <aes.h>
#include <vdi.h>

#include "bubbles.h"
#include "bubble.rsh"

#define BUBBLE_WIDTH	48
#define BUBBLE_HEIGHT	28
#define TOGGLES			6
#define IDLE_IN_MS		150
#define PREFS_OFFSET	0x3C

int save_prefs(void);

extern int _magic, _setting_1, _setting_2;

MFDB bubble,screen;
int pxy[8], xres, yres;

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

void init_bubbles(void) {

	/* Setup bubble MFDB */
	bubble.fd_w			= BUBBLE_WIDTH;
	bubble.fd_h			= BUBBLE_HEIGHT;
	bubble.fd_wdwidth	= 3;
	bubble.fd_stand		= 0;
	bubble.fd_nplanes	= 1;

	/* Setup screen MFDB */
	screen.fd_addr = 0;

	/* Set size of bubble	*/
	pxy[0] = 0;
	pxy[1] = 0;
	pxy[2] = BUBBLE_WIDTH-1;
	pxy[3] = BUBBLE_HEIGHT-1;
}

void draw(int handle, int x, int y) {

	int i, color[2];
	void *mask,*bitmap;

	color[0]=0;
	color[1]=1;

	/* Cursor near top left corner? */
	if (x < (BUBBLE_WIDTH)) {
		if (y < (BUBBLE_HEIGHT + yres + yres)) {	/* tail top left */
			pxy[4]=x;
			pxy[5]=y + BUBBLE_HEIGHT/2 + yres/2;
			mask	= (void *)bmask_3;
			bitmap	= (void *)bbitmap_3;
		}
		else {										/* tail bottom left */
			pxy[4]=x+2;
			pxy[5]=y - BUBBLE_HEIGHT - 4;
			mask	= (void *)bmask_2;
			bitmap	= (void *)bbitmap_2;
		}
	}
	/* Cursor near top right corner? */
	else if (y < (BUBBLE_HEIGHT + yres + yres)) {	/* tail top right */
		pxy[4]=x - BUBBLE_WIDTH + xres/2;
		pxy[5]=y + BUBBLE_HEIGHT/2 + yres/2;
		mask	= (void *)bmask_4;
		bitmap	= (void *)bbitmap_4;
	}
	else {											/* tail bottom right */
		pxy[4]=x - BUBBLE_WIDTH + xres/2;
		pxy[5]=y - BUBBLE_HEIGHT - 2;
		mask	= (void *)bmask_1;
		bitmap	= (void *)bbitmap_1;
	}

	pxy[6]=pxy[4] + BUBBLE_WIDTH - 1;
	pxy[7]=pxy[5] + BUBBLE_HEIGHT - 1;

	form_dial(FMD_START, 0, 0, 0, 0, pxy[4], pxy[5], BUBBLE_WIDTH-1, BUBBLE_HEIGHT-1);

	for (i = 0; i < TOGGLES; i++) {
		
		/* copy mask, then bitmap */
		bubble.fd_addr = mask;
		vrt_cpyfm(handle, 2, pxy, &bubble, &screen,color);

		bubble.fd_addr = bitmap;
		vrt_cpyfm(handle, 3, pxy, &bubble, &screen,color);

		evnt_timer(200,0);

		/* invert bckground and foreground color */
		color[0]=!color[0];
		color[1]=!color[1];
	}

	form_dial(FMD_FINISH, 0, 0, 0, 0, pxy[4], pxy[5], BUBBLE_WIDTH-1, BUBBLE_HEIGHT-1);
}

int main(void) {

	int i, handle, work_out[57], x, y, w, h, msg_buffer[8];
	int mouse_x, mouse_y, mouse_button, kbd_state, dummy;

	OBJECT *dialog;
	
	menu_register(appl_init(), "  BubbleBook");
	handle = graf_handle(&xres,&yres,&work_out[0],&work_out[1]);

	init_bubbles();

	dialog=rs_object;
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
			if (kbd_state == get_button_state(dialog))
				draw(handle, mouse_x, mouse_y);
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
