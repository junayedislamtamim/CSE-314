#ifndef READER
#define READER

#include <iostream>
#include <pthread.h>
#include <semaphore.h>
#include <unistd.h>
#include <queue>
#include "locks.h"
#include "defs.h"

void reader(void* arg)
{
    int ID = (int)(intptr_t)arg;

    incrReader();
    int clockTime = incrclockTime();
    std::cout << "Intelligence Staff " << ID << " began reviewing logbook at clockTime " << clockTime << ". Operations completed = " << entry << '\n';
    decrReader();
}

#endif