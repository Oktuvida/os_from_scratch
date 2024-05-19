volatile unsigned char *video = 0xB8000; // Pointer to the video memory for text mode

int nextTextPos = 0; // Next position to write text in video memory
int currLine = 0;    // Current line number in video memory

void print(char *);  // Function prototype for printing a string
void println();      // Function prototype for printing a newline
void printi(int);    // Function prototype for printing an integer

void kernel_main()
{
    print("Welcome!");
    println();
    print("We are now in Protected-mode");
    println();

    while (1)          // Infinite loop to keep the kernel running
        ;
}

void interrupt_handler(int interrupt_number)
{
    println();
    print("Interrupt Received ");
    printi(interrupt_number);
}

void print(char *str)
{
    int currCharLocationInVidMem, currColorLocationInVidMem; // Variables for character and color memory locations

    while (*str != '\0') // Loop until the end of the string
    {
        currCharLocationInVidMem = nextTextPos * 2; // Calculate the memory location for the character
        currColorLocationInVidMem = currCharLocationInVidMem + 1; // Calculate the memory location for the color

        video[currCharLocationInVidMem] = *str; // Write the character to video memory
        video[currColorLocationInVidMem] = 15;  // Write the color (white) to video memory

        nextTextPos++; // Move to the next text position

        str++; // Move to the next character in the string
    }
}

void println()
{
    nextTextPos = ++currLine * 80; // Move to the start of the next line (80 characters per line)
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

        printi(number); // Recursively print the rest of the number
        printi(remaining); // Print the last digit
    }
}
