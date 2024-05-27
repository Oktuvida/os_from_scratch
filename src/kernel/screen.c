#include "screen.h"

volatile unsigned char *video = 0xB8000;

extern int nextTextPos = 0;
extern int currLine = 0;

void screen_init()
{
    video = 0xB8000;
    nextTextPos = 0;
    currLine = 0;
}