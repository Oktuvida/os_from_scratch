#include "screen.h"
#include "scheduler.h"
#include "heap.h"

void processA();
void processB();
void processC();
void processD();

void create_landing_page();

void kernel_main()
{
    process_t *p1, *p2, *p3, *p4;

    heap_init();
    paging_init();
    screen_init();
    process_init();
    scheduler_init();

    create_landing_page();

    p1 = process_create(&processA);
    p2 = process_create(&processB);
    p3 = process_create(&processC);
    p4 = process_create(&processD);

    while (1)
        ;
}

void interrupt_handler(int interrupt_number)
{
    println();
    print("Interrupt Received ");
    printi(interrupt_number);
}

void create_landing_page()
{
    currColor = Red;
    print_on_entire_line("#", '#', '#');
    println();

    print_on_entire_line("Welcome to os_from_scratch!", '#', ' ');
    println();
    print_on_entire_line("We are now in Protected-mode", '#', ' ');
    println();

    print_on_entire_line("#", '#', '#');
    println();
    currColor = White;
}

void processA()
{
    print("Process A,");

    while (1)
        asm("mov $5390, %eax");
}

void processB()
{
    print("Process B,");

    while (1)
        asm("mov $5391, %eax");
}

void processC()
{
    print("Process C,");

    while (1)
        asm("mov $5392, %eax");
}

void processD()
{
    print("Process D,");

    while (1)
        asm("mov $5393, %eax");
}