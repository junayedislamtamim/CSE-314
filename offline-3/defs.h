#ifndef DEFS
#define DEFS

#define TYPE_STATION_COUNT 4

int clockTime;
int entry;
int readerCount;

//operatives.h
void recreate(int unitID);
void sendToGroupLeader(int unitID);
void ts(void* arg);
void log(int unitID);

//reader.h
void reader(void* arg);

//locks.h
int incrclockTime();
void incrReader();
void decrReader();

void createEntry()
{
    /*some really complex stuffs... ...*/
    //we have already acquired lock inside operatives.h/log(), wont need it here
    ++entry;
}

#endif