#ifndef LOCKS
#define LOCKS

#include <pthread.h>
#include <unistd.h>
#include <vector>
#include "defs.h"


#define TYPE_STATION_COUNT 4


pthread_mutex_t timeLock;
pthread_mutex_t typeStation[TYPE_STATION_COUNT];
pthread_mutex_t logBook;
std::vector<pthread_mutex_t> unitLock;
std::vector<int> recreate_;
std::vector<int> distribute;

void incrTime()
{
    pthread_mutex_lock(&timeLock);
    ++time;
    pthread_mutex_unlock(&timeLock);
}

#endif