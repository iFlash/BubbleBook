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
{ "RSHIFT",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1100, 0, -1, 7, 1,
  "ALTERNATE",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1100, 0, -1, 10, 1,
  "CONTROL",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1101, 0, -1, 8, 1,
  "LSHIFT",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1101, 0, -1, 7, 1,
  "HOTKEY(S)",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1180, 0, 0, 10, 1,
  "BUBBLE",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1180, 0, 0, 7, 1,
  "VERSION 2.0 (C) 2025 BY ARMIN HIERSTETTER",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1180, 0, 0, 42, 1,
  "BubbleBook",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 11, 1
};

OBJECT rs_object[] =
{ 
  /******** Tree 0 DIALOG_BUBBLE ****************************************************/
        -1, BUTTON_OK       ,       14, G_BOX             ,   /* Object 0  */
  NONE, OUTLINED, (LONG)0x00021100L,
  0x0000, 0x0000, 0x0025, 0x000D,
  BUTTON_CANCEL   ,       -1,       -1, G_BUTTON          ,   /* Object 1 BUTTON_OK */
  SELECTABLE|DEFAULT|EXIT, NORMAL, (LONG)"OK",
  0x0019, 0x000B, 0x0009, 0x0001,
  BUTTON_SAVE     ,       -1,       -1, G_BUTTON          ,   /* Object 2 BUTTON_CANCEL */
  SELECTABLE|EXIT, NORMAL, (LONG)"CANCEL",
  0x000E, 0x000B, 0x0009, 0x0001,
  BUTTON_SHIFT_R  ,       -1,       -1, G_BUTTON          ,   /* Object 3 BUTTON_SAVE */
  SELECTABLE|TOUCHEXIT, NORMAL, (LONG)"SAVE",
  0x0003, 0x000B, 0x0008, 0x0001,
  BUTTON_ALTERNATE,       -1,       -1, G_BOXTEXT         |0x1500,   /* Object 4 BUTTON_SHIFT_R */
  SELECTABLE, OUTLINED|SHADOWED, (LONG)&rs_tedinfo[0],
  0x001B, 0x0008, 0x0007, 0x0001,
  BUTTON_CONTROL  ,       -1,       -1, G_BOXTEXT         |0x1500,   /* Object 5 BUTTON_ALTERNATE */
  SELECTABLE, OUTLINED|SHADOWED, (LONG)&rs_tedinfo[1],
  0x0013, 0x0008, 0x0007, 0x0001,
  BUTTON_SHIFT_L  ,       -1,       -1, G_BOXTEXT         |0x1500,   /* Object 6 BUTTON_CONTROL */
  SELECTABLE, OUTLINED|SHADOWED, (LONG)&rs_tedinfo[2],
  0x000B, 0x0008, 0x0007, 0x0001,
         8,       -1,       -1, G_BOXTEXT         |0x1500,   /* Object 7 BUTTON_SHIFT_L */
  SELECTABLE, OUTLINED|SHADOWED, (LONG)&rs_tedinfo[3],
  0x0003, 0x0008, 0x0007, 0x0001,
         9,       -1,       -1, G_TEXT            ,   /* Object 8  */
  NONE, NORMAL, (LONG)&rs_tedinfo[4],
  0x0003, 0x0007, 0x0606, 0x0001,
        12, BUTTON_ON       , BUTTON_OFF      , G_IBOX            ,   /* Object 9  */
  NONE, NORMAL, (LONG)0x00FF1100L,
  0x0003, 0x0005, 0x001F, 0x0001,
  BUTTON_OFF      ,       -1,       -1, G_BUTTON          |0x1500,   /* Object 10 BUTTON_ON */
  SELECTABLE|RBUTTON, OUTLINED|SHADOWED, (LONG)"ON",
  0x0000, 0x0000, 0x020F, 0x0001,
         9,       -1,       -1, G_BUTTON          |0x1500,   /* Object 11 BUTTON_OFF */
  SELECTABLE|RBUTTON, OUTLINED|SHADOWED, (LONG)"OFF",
  0x060F, 0x0000, 0x020F, 0x0001,
        13,       -1,       -1, G_TEXT            ,   /* Object 12  */
  NONE, NORMAL, (LONG)&rs_tedinfo[5],
  0x0003, 0x0004, 0x0404, 0x0001,
        14,       -1,       -1, G_TEXT            ,   /* Object 13  */
  NONE, NORMAL, (LONG)&rs_tedinfo[6],
  0x0003, 0x0002, 0x061E, 0x0001,
         0,       -1,       -1, G_TEXT            ,   /* Object 14  */
  LASTOB, NORMAL, (LONG)&rs_tedinfo[7],
  0x0003, 0x0001, 0x000A, 0x0001
};

OBJECT *rs_trindex[] =
{ &rs_object[0]    /* Tree  0 DIALOG_BUBBLE    */
};
