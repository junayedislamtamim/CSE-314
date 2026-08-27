#ifndef READER
#define READER

#include <iostream>
#include <pthread.h>
#include <semaphore.h>
#include <unistd.h>
#include <queue>
#include "locks.h"

void reader(void* arg)
{
    int ID = (int)(intptr_t)arg;

    incrReader();
    int time = incrTime();
    std::cout << "Intelligence Staff " << ID << "began reviewing logbook at time " << time << ". Operations completed = " << entry << '\n';
    decrReader();
}

#endif