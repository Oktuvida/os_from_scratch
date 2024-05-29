#include "screen.h"

volatile unsigned char *video = 0xB8000;

int nextTextPos = 0;
int currLine = 0;
int lineSize = 80;

color currColor = White;

void screen_init()
{
    video = 0xB8000;
    nextTextPos = 0;
    currLine = 0;
}

void print_on_entire_line(char *str, char delimiter, char spacing)
{
    int size = get_char_length(str);

    int emptySize = (lineSize - size - 2) / 2;

    char paddedStr[lineSize];
    paddedStr[0] = delimiter;
    paddedStr[lineSize - 1] = delimiter;
    for (int i = 1; i < lineSize - 1; i++)
    {
        if (i >= emptySize && i < emptySize + size)
        {
            paddedStr[i] = str[i - emptySize];
        }
        else
        {
            paddedStr[i] = spacing;
        }
    }
    print(paddedStr);
}

int get_char_length(char *str)
{
    int count = 0;
    while (*str != '\0')
    {
        count++;
        str++;
    }
    return count;
}

void print(char *str)
{
    int currCharLocationInVidMem, currColorLocationInVidMem; // Variables for character and color memory locations

    while (*str != '\0') // Loop until the end of the string
    {
        currCharLocationInVidMem = nextTextPos * 2;               // Calculate the memory location for the character
        currColorLocationInVidMem = currCharLocationInVidMem + 1; // Calculate the memory location for the color

        video[currCharLocationInVidMem] = *str; // Write the character to video memory
        video[currColorLocationInVidMem] = currColor;  // Write the color to video memory

        nextTextPos++; // Move to the next text position

        str++; // Move to the next character in the string
    }
}

void println()
{
    nextTextPos = ++currLine * lineSize; // Move to the start of the next line (80 characters per line)
}

void printi(int number)
{
    char *digitToStr[] = {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9"}; // Array to convert digits to strings

    if (number >= 0 && number <= 9) // If the number is a single digit
    {
        print(digitToStr[number]); // Print the digit
        return;
    }
    else // If the number has more than one digit
    {
        int remaining = number % 10; // Get the last digit
        number = number / 10;        // Remove the last digit from the number

        printi(number);    // Recursively print the rest of the number
        printi(remaining); // Print the last digit
    }
}
