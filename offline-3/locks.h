#ifndef LOCKS
#define LOCKS

#include <pthread.h>
#include <unistd.h>
#include <vector>
#include "defs.h"

pthread_mutex_t clockTimeLock;
pthread_mutex_t typeStation[TYPE_STATION_COUNT];
pthread_mutex_t logBookWrite;
pthread_mutex_t reader_;
std::vector<pthread_mutex_t> unitLock;
std::vector<int> recreate_;
std::vector<int> distribute;

int incrclockTime()
{
    pthread_mutex_lock(&clockTimeLock);
    ++clockTime;
    pthread_mutex_unlock(&clockTimeLock);

    return clockTime;
}

void incrReader()
{
    pthread_mutex_lock(&reader_);
    if(readerCount == 0) pthread_mutex_lock(&logBookWrite);
    ++readerCount;
    pthread_mutex_unlock(&reader_);
}

void decrReader()
{
    pthread_mutex_lock(&reader_);
    --readerCount;
    if(readerCount == 0) pthread_mutex_unlock(&logBookWrite);
    pthread_mutex_unlock(&reader_);
}

#endif