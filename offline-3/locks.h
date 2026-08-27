#ifndef LOCKS
#define LOCKS

#include <pthread.h>
#include <unistd.h>
#include <vector>
#include "defs.h"


#define TYPE_STATION_COUNT 4


pthread_mutex_t timeLock;
pthread_mutex_t typeStation[TYPE_STATION_COUNT];
pthread_mutex_t logBookWrite;
pthread_mutex_t reader;
std::vector<pthread_mutex_t> unitLock;
std::vector<int> recreate_;
std::vector<int> distribute;

int incrTime()
{
    pthread_mutex_lock(&timeLock);
    ++time;
    pthread_mutex_unlock(&timeLock);

    return time;
}

void incrReader()
{
    pthread_mutex_lock(&reader);
    if(readerCount == 0) pthread_mutex_lock(&logBookWrite);
    ++readerCount;
    pthread_mutex_unlock(&reader);
}

void decrReader()
{
    pthread_mutex_lock(&reader);
    --readerCount;
    if(readerCount == 0) pthread_mutex_unlock(&logBookWrite);
    pthread_mutex_unlock(&reader);
}

#endif