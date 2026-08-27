#ifndef DEFS
#define DEFS

int time;
int entry;
int readerCount;

void createEntry()
{
    /*some really complex stuffs... ...*/
    //we have already acquired lock inside operatives.h/log(), wont need it here
    ++entry;
}

#endif