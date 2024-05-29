extern volatile unsigned char *video;

extern int nextTextPos;
extern int currLine;
extern int lineSize;

typedef enum{Red=12, White=15} color;
extern color currColor;

void screen_init();

void print_on_entire_line(char *str, char delimiter, char spacing);
int get_char_length(char *str);

void print(char *);
void println();
void printi(int);
