/* GEM Resource C Source */

#include <portab.h>
#include <aes.h>
#include "BUBBLE.H"

#if !defined(WHITEBAK)
#define WHITEBAK    0x0040
#endif
#if !defined(DRAW3D)
#define DRAW3D      0x0080
#endif

#define FLAGS9  0x0200
#define FLAGS10 0x0400
#define FLAGS11 0x0800
#define FLAGS12 0x1000
#define FLAGS13 0x2000
#define FLAGS14 0x4000
#define FLAGS15 0x8000
#define STATE8  0x0100
#define STATE9  0x0200
#define STATE10 0x0400
#define STATE11 0x0800
#define STATE12 0x1000
#define STATE13 0x2000
#define STATE14 0x4000
#define STATE15 0x8000

TEDINFO rs_tedinfo[] =
{ " BubbleBook ",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x11C1, 0, -1, 13, 1,
  "VERSION 2.2 (C) 2025 BY ARMIN HIERSTETTER",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1180, 0, 0, 42, 1,
  "3",
  "Blinks _ times",
  "9",
  IBM  , 0, TE_LEFT , 0x1180, 0, 0, 2, 15,
  " BUBBLE ",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1180, 0, 0, 9, 1,
  "LSHIFT",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1101, 0, -1, 7, 1,
  "CONTROL",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1101, 0, -1, 8, 1,
  "ALTERNATE",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1100, 0, -1, 10, 1,
  "RSHIFT",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1100, 0, -1, 7, 1,
  " HOTKEY(S) ",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1180, 0, 0, 12, 1,
  "?",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1180, 0, -1, 2, 1,
  " BubbleBook ",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x11C1, 0, -1, 13, 1,
  "VERSION 2.2 (C) 2025 BY ARMIN HIERSTETTER",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1180, 0, 0, 42, 1,
  "BUBBLEBOOK DRAWS A SPEECH BUBBLE NEAR A",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1180, 0, -1, 40, 1,
  "\042LOST\042 MOUSE CURSOR WHEN YOU RIGHT-CLICK.",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1180, 0, -1, 42, 1,
  "YOU CAN DEFINE HOTKEYS THAT NEED TO BE",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1180, 0, -1, 39, 1,
  "PRESSED THE SAME TIME TO SHOW THE BUBBLE AND ",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1180, 0, -1, 46, 1,
  "ADJUST THE NUMBER OF BLINKS OF THE BUBBLE.",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1180, 0, -1, 43, 1,
  "FINALLY, YOU CAN SAVE YOUR SETTINGS.",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1180, 0, -1, 37, 1,
  " HELP ",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1180, 0, 0, 7, 1
};

WORD RSIB0MASK[] =
{ 0x3FFF, 0xFFF8, 0x7FFF, 0xFFFC, 
  0xFFFF, 0xFFFE, 0xFFFF, 0xFFFF, 
  0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
  0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
  0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
  0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
  0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
  0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
  0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
  0xFFFF, 0xFFFF, 0x7FFF, 0xFFFF, 
  0x7FFF, 0xFFFE, 0x1FFF, 0xFFFC, 
  0x0000, 0x0FC0, 0x0000, 0x0FC0, 
  0x0000, 0x07E0, 0x0000, 0x01F0, 
  0x0000, 0x0078, 0x0000, 0x0018
};

WORD RSIB0DATA[] =
{ 0x3FFF, 0xFFF8, 0x4000, 0x0004, 
  0x8000, 0x0002, 0x80D8, 0x0003, 
  0x80C8, 0x0003, 0x80C3, 0xB603, 
  0x80C1, 0xFE03, 0x80C1, 0xB603, 
  0x80C1, 0xB603, 0x80C1, 0xB603, 
  0x8000, 0x0003, 0x8C00, 0x0063, 
  0x8C00, 0x0063, 0x8D99, 0xE663, 
  0x8FB4, 0xED63, 0x8DBC, 0xCF63, 
  0x8DB0, 0xCC03, 0x8D9C, 0xC663, 
  0x8000, 0x0003, 0x4000, 0x0007, 
  0x7FFF, 0xF87E, 0x1FFF, 0xF8FC, 
  0x0000, 0x08C0, 0x0000, 0x08C0, 
  0x0000, 0x0660, 0x0000, 0x01B0, 
  0x0000, 0x0078, 0x0000, 0x0018
};

WORD RSIB1MASK[] =
{ 0x3FFF, 0xFFF8, 0x7FFF, 0xFFFC, 
  0xFFFF, 0xFFFE, 0xFFFF, 0xFFFF, 
  0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
  0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
  0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
  0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
  0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
  0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
  0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
  0xFFFF, 0xFFFF, 0x7FFF, 0xFFFF, 
  0x7FFF, 0xFFFE, 0x1FFF, 0xFFFC, 
  0x00FC, 0x0000, 0x00FC, 0x0000, 
  0x01F8, 0x0000, 0x03E0, 0x0000, 
  0x0780, 0x0000, 0x0600, 0x0000
};

WORD RSIB1DATA[] =
{ 0x3FFF, 0xFFF8, 0x4000, 0x0004, 
  0x8000, 0x0002, 0x80D8, 0x0003, 
  0x80C8, 0x0003, 0x80C3, 0xB603, 
  0x80C1, 0xFE03, 0x80C1, 0xB603, 
  0x80C1, 0xB603, 0x80C1, 0xB603, 
  0x8000, 0x0003, 0x8C00, 0x0063, 
  0x8C00, 0x0063, 0x8D99, 0xE663, 
  0x8FB4, 0xED63, 0x8DBC, 0xCF63, 
  0x8DB0, 0xCC03, 0x8D9C, 0xC663, 
  0x8000, 0x0003, 0x4000, 0x0007, 
  0x7F8F, 0xFFFE, 0x1F8F, 0xFFFC, 
  0x008C, 0x0000, 0x008C, 0x0000, 
  0x0138, 0x0000, 0x02E0, 0x0000, 
  0x0780, 0x0000, 0x0600, 0x0000
};

WORD RSIB2MASK[] =
{ 0x0000, 0x0018, 0x0000, 0x0078, 
  0x0000, 0x01F0, 0x0000, 0x07E0, 
  0x0000, 0x0FC0, 0x0000, 0x0FC0, 
  0x3FFF, 0xFFF8, 0x7FFF, 0xFFFC, 
  0xFFFF, 0xFFFE, 0xFFFF, 0xFFFF, 
  0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
  0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
  0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
  0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
  0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
  0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
  0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
  0xFFFF, 0xFFFF, 0x7FFF, 0xFFFF, 
  0x7FFF, 0xFFFE, 0x1FFF, 0xFFFC
};

WORD RSIB2DATA[] =
{ 0x0000, 0x0018, 0x0000, 0x0078, 
  0x0000, 0x01B0, 0x0000, 0x0660, 
  0x0000, 0x08C0, 0x0000, 0x08C0, 
  0x3FFF, 0xF8F8, 0x4000, 0x0004, 
  0x8000, 0x0002, 0x80D8, 0x0003, 
  0x80C8, 0x0003, 0x80C3, 0xB603, 
  0x80C1, 0xFE03, 0x80C1, 0xB603, 
  0x80C1, 0xB603, 0x80C1, 0xB603, 
  0x8000, 0x0003, 0x8C00, 0x0063, 
  0x8C00, 0x0063, 0x8D99, 0xE663, 
  0x8FB4, 0xED63, 0x8DBC, 0xCF63, 
  0x8DB0, 0xCC03, 0x8D9C, 0xC663, 
  0x8000, 0x0003, 0x4000, 0x0007, 
  0x7FFF, 0xFFFE, 0x1FFF, 0xFFFC
};

WORD RSIB3MASK[] =
{ 0x1800, 0x0000, 0x1E00, 0x0000, 
  0x0F80, 0x0000, 0x07E0, 0x0000, 
  0x03F0, 0x0000, 0x03F0, 0x0000, 
  0x3FFF, 0xFFF8, 0x7FFF, 0xFFFC, 
  0xFFFF, 0xFFFE, 0xFFFF, 0xFFFF, 
  0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
  0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
  0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
  0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
  0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
  0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
  0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
  0xFFFF, 0xFFFF, 0x7FFF, 0xFFFF, 
  0x7FFF, 0xFFFE, 0x1FFF, 0xFFFC
};

WORD RSIB3DATA[] =
{ 0x1800, 0x0000, 0x1E00, 0x0000, 
  0x0B80, 0x0000, 0x04E0, 0x0000, 
  0x0230, 0x0000, 0x0230, 0x0000, 
  0x3E3F, 0xFFF8, 0x4000, 0x0004, 
  0x8000, 0x0002, 0x80D8, 0x0003, 
  0x80C8, 0x0003, 0x80C3, 0xB603, 
  0x80C1, 0xFE03, 0x80C1, 0xB603, 
  0x80C1, 0xB603, 0x80C1, 0xB603, 
  0x8000, 0x0003, 0x8C00, 0x0063, 
  0x8C00, 0x0063, 0x8D99, 0xE663, 
  0x8FB4, 0xED63, 0x8DBC, 0xCF63, 
  0x8DB0, 0xCC03, 0x8D9C, 0xC663, 
  0x8000, 0x0003, 0x4000, 0x0007, 
  0x7FFF, 0xFFFE, 0x1FFF, 0xFFFC
};

ICONBLK rs_iconblk[] =
{ RSIB0MASK, RSIB0DATA, "\0\000\000\000\000\000\000\000\000", 0x1000|'\0',
    0,   0,   0,   0,  32,  28,   0,  30,  48,   8,
  RSIB1MASK, RSIB1DATA, "\0\000\000\000\000\000\000\000\000", 0x1000|'\0',
    0,   0,   0,   0,  32,  28,   0,  30,  48,   8,
  RSIB2MASK, RSIB2DATA, "\0\000\000\000\000\000\000\000\000", 0x1000|'\0',
    0,   0,   0,   0,  32,  28,   0,  30,  48,   8,
  RSIB3MASK, RSIB3DATA, "\0\000\000\000\000\000\000\000\000", 0x1000|'\0',
    0,   0,   0,   0,  32,  28,   0,  30,  48,   8
};

OBJECT rs_object[] =
{ 
  /******** Tree 0 DIALOG_BUBBLE ****************************************************/
        -1,        1, BUTTON_OK       , G_BOX             ,   /* Object 0  */
  NONE, OUTLINED, (LONG)0x00021100L,
  0x0000, 0x0000, 0x0027, 0x000E,
         2,       -1,       -1, G_BOXTEXT         ,   /* Object 1  */
  NONE, OUTLINED|SHADOWED, (LONG)&rs_tedinfo[0],
  0x0002, 0x0001, 0x0023, 0x0001,
         3,       -1,       -1, G_TEXT            ,   /* Object 2  */
  NONE, NORMAL, (LONG)&rs_tedinfo[1],
  0x0004, 0x0402, 0x061E, 0x0001,
         8, BLINK_COUNT     ,        5, G_BOX             ,   /* Object 3  */
  NONE, NORMAL, (LONG)0x00FF1100L,
  0x0002, 0x0004, 0x0023, 0x0003,
         5,       -1,       -1, G_FTEXT           ,   /* Object 4 BLINK_COUNT */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[2],
  0x0013, 0x0001, 0x000E, 0x0001,
         3, BUTTON_ON       , BUTTON_OFF      , G_IBOX            ,   /* Object 5  */
  NONE, NORMAL, (LONG)0x00FF1100L,
  0x0002, 0x0001, 0x000F, 0x0001,
  BUTTON_OFF      ,       -1,       -1, G_BUTTON          |0x1500,   /* Object 6 BUTTON_ON */
  SELECTABLE|RBUTTON, OUTLINED|SHADOWED, (LONG)"ON",
  0x0000, 0x0000, 0x0207, 0x0001,
         5,       -1,       -1, G_BUTTON          |0x1500,   /* Object 7 BUTTON_OFF */
  SELECTABLE|RBUTTON, OUTLINED|SHADOWED, (LONG)"OFF",
  0x0008, 0x0000, 0x0007, 0x0001,
         9,       -1,       -1, G_TEXT            ,   /* Object 8  */
  NONE, NORMAL, (LONG)&rs_tedinfo[3],
  0x0003, 0x0803, 0x0006, 0x0001,
        14, BUTTON_SHIFT_L  , BUTTON_SHIFT_R  , G_BOX             ,   /* Object 9  */
  NONE, NORMAL, (LONG)0x00FF1100L,
  0x0002, 0x0008, 0x0023, 0x0003,
  BUTTON_CONTROL  ,       -1,       -1, G_BOXTEXT         |0x1500,   /* Object 10 BUTTON_SHIFT_L */
  SELECTABLE, OUTLINED|SHADOWED, (LONG)&rs_tedinfo[4],
  0x0002, 0x0001, 0x0007, 0x0001,
  BUTTON_ALTERNATE,       -1,       -1, G_BOXTEXT         |0x1500,   /* Object 11 BUTTON_CONTROL */
  SELECTABLE, OUTLINED|SHADOWED, (LONG)&rs_tedinfo[5],
  0x000A, 0x0001, 0x0007, 0x0001,
  BUTTON_SHIFT_R  ,       -1,       -1, G_BOXTEXT         |0x1500,   /* Object 12 BUTTON_ALTERNATE */
  SELECTABLE, OUTLINED|SHADOWED, (LONG)&rs_tedinfo[6],
  0x0012, 0x0001, 0x0007, 0x0001,
         9,       -1,       -1, G_BOXTEXT         |0x1500,   /* Object 13 BUTTON_SHIFT_R */
  SELECTABLE, OUTLINED|SHADOWED, (LONG)&rs_tedinfo[7],
  0x001A, 0x0001, 0x0007, 0x0001,
  BUTTON_HELP     ,       -1,       -1, G_TEXT            ,   /* Object 14  */
  NONE, NORMAL, (LONG)&rs_tedinfo[8],
  0x0003, 0x0807, 0x0208, 0x0001,
  BUTTON_SAVE     ,       -1,       -1, G_BOXTEXT         ,   /* Object 15 BUTTON_HELP */
  SELECTABLE|EXIT, NORMAL, (LONG)&rs_tedinfo[9],
  0x0002, 0x000C, 0x0002, 0x0001,
  BUTTON_CANCEL   ,       -1,       -1, G_BUTTON          ,   /* Object 16 BUTTON_SAVE */
  SELECTABLE|TOUCHEXIT, NORMAL, (LONG)"SAVE",
  0x0005, 0x000C, 0x0008, 0x0001,
  BUTTON_OK       ,       -1,       -1, G_BUTTON          ,   /* Object 17 BUTTON_CANCEL */
  SELECTABLE|EXIT, NORMAL, (LONG)"CANCEL",
  0x0011, 0x000C, 0x0009, 0x0001,
         0,       -1,       -1, G_BUTTON          ,   /* Object 18 BUTTON_OK */
  SELECTABLE|DEFAULT|EXIT|LASTOB, NORMAL, (LONG)"OK",
  0x001C, 0x000C, 0x0009, 0x0001,
  
  /******** Tree 1 DIALOG_HELP ****************************************************/
        -1,        1, K               , G_BOX             ,   /* Object 0  */
  NONE, OUTLINED, (LONG)0x00021100L,
  0x0000, 0x0000, 0x0027, 0x000E,
         2,       -1,       -1, G_BOXTEXT         ,   /* Object 1  */
  NONE, OUTLINED|SHADOWED, (LONG)&rs_tedinfo[10],
  0x0002, 0x0001, 0x0023, 0x0001,
  BOX_HELP        ,       -1,       -1, G_TEXT            ,   /* Object 2  */
  NONE, NORMAL, (LONG)&rs_tedinfo[11],
  0x0004, 0x0402, 0x061E, 0x0001,
  TITLE_HELP      ,        4,        9, G_BOX             ,   /* Object 3 BOX_HELP */
  NONE, NORMAL, (LONG)0x00FF1100L,
  0x0002, 0x0004, 0x0023, 0x0007,
         5,       -1,       -1, G_TEXT            ,   /* Object 4  */
  NONE, NORMAL, (LONG)&rs_tedinfo[12],
  0x0001, 0x0001, 0x021D, 0x0001,
         6,       -1,       -1, G_TEXT            ,   /* Object 5  */
  NONE, NORMAL, (LONG)&rs_tedinfo[13],
  0x0001, 0x0002, 0x061E, 0x0001,
         7,       -1,       -1, G_TEXT            ,   /* Object 6  */
  NONE, NORMAL, (LONG)&rs_tedinfo[14],
  0x0001, 0x0003, 0x041C, 0x0001,
         8,       -1,       -1, G_TEXT            ,   /* Object 7  */
  NONE, NORMAL, (LONG)&rs_tedinfo[15],
  0x0001, 0x0004, 0x0621, 0x0001,
         9,       -1,       -1, G_TEXT            ,   /* Object 8  */
  NONE, NORMAL, (LONG)&rs_tedinfo[16],
  0x0001, 0x0005, 0x041F, 0x0001,
  BOX_HELP        ,       -1,       -1, G_TEXT            ,   /* Object 9  */
  NONE, NORMAL, (LONG)&rs_tedinfo[17],
  0x0001, 0x0006, 0x001B, 0x0001,
  K               ,       -1,       -1, G_TEXT            ,   /* Object 10 TITLE_HELP */
  NONE, NORMAL, (LONG)&rs_tedinfo[18],
  0x0003, 0x0803, 0x0404, 0x0001,
         0,       -1,       -1, G_BUTTON          ,   /* Object 11 K */
  SELECTABLE|DEFAULT|EXIT|LASTOB, NORMAL, (LONG)"BACK",
  0x001C, 0x000C, 0x0009, 0x0001,
  
  /******** Tree 2 BUBBLES ****************************************************/
        -1, BUBBLE_TAIL_BR  , BUBBLE_TAIL_TL  , G_BOX             ,   /* Object 0  */
  NONE, OUTLINED, (LONG)0x00020100L,
  0x0000, 0x0000, 0x0019, 0x0603,
  BUBBLE_TAIL_BL  ,       -1,       -1, G_ICON            ,   /* Object 1 BUBBLE_TAIL_BR */
  NONE, NORMAL, (LONG)&rs_iconblk[0],
  0x0001, 0x0001, 0x0006, 0x0602,
  BUBBLE_TAIL_TR  ,       -1,       -1, G_ICON            ,   /* Object 2 BUBBLE_TAIL_BL */
  NONE, NORMAL, (LONG)&rs_iconblk[1],
  0x0007, 0x0001, 0x0006, 0x0602,
  BUBBLE_TAIL_TL  ,       -1,       -1, G_ICON            ,   /* Object 3 BUBBLE_TAIL_TR */
  NONE, NORMAL, (LONG)&rs_iconblk[2],
  0x000D, 0x0001, 0x0006, 0x0602,
         0,       -1,       -1, G_ICON            ,   /* Object 4 BUBBLE_TAIL_TL */
  LASTOB, NORMAL, (LONG)&rs_iconblk[3],
  0x0013, 0x0001, 0x0006, 0x0602
};

OBJECT *rs_trindex[] =
{ &rs_object[0],   /* Tree  0 DIALOG_BUBBLE    */
  &rs_object[19],   /* Tree  1 DIALOG_HELP      */
  &rs_object[31]    /* Tree  2 BUBBLES          */
};
