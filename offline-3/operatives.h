#ifndef OPERATIVES
#define OPERATIVES

#include <iostream>
#include <pthread.h>
#include <semaphore.h>
#include <unistd.h>
#include <queue>
#include "locks.h"
#include "defs.h"

void recreate(int unitID)
{ 
    pthread_mutex_lock(&unitLock[unitID - 1]);
    recreate_[unitID - 1]--;
    pthread_mutex_unlock(&unitLock[unitID - 1]);

    if(recreate_[unitID - 1] == 0)
    {
        int clockTime = incrclockTime();
        std::cout << "Unit " << unitID << " has completed document recreation phase at clockTime " << clockTime << '\n';
    }
}

void sendToGroupLeader(int unitID)
{ 
    pthread_mutex_lock(&unitLock[unitID - 1]);
    distribute[unitID - 1]--;
    pthread_mutex_unlock(&unitLock[unitID - 1]);

    if(distribute[unitID - 1] == 0)
    {
        log(unitID);
    }
}

struct Data 
{
    int ID;
    int unitID;
};

void ts(void* arg)
{
    int clockTime = incrclockTime();
    Data* data = (Data*) arg;
    int ID = data->ID;
    int typeStationID = ID % TYPE_STATION_COUNT;
    int unitID = data->unitID;

    std::cout << "Operative " << ID << " has arrived at typewriting station at clockTime " << clockTime << '\n';
    
    //staion availability checking using pthread_lock
    pthread_mutex_lock(&typeStation[typeStationID]);
    recreate(unitID);
    clockTime = incrclockTime();
    std::cout << "Operative " << ID << " has completed document recreation at clockTime " << clockTime << '\n';
    pthread_mutex_unlock(&typeStation[typeStationID]);

    sendToGroupLeader(unitID);
}

void log(int unitID)
{   
    pthread_mutex_lock(&logBookWrite);
    createEntry();
    int clockTime = incrclockTime();
    std::cout << "Unit " << unitID << " has completed intelligence distribution at clockTime " << clockTime << '\n';
    pthread_mutex_unlock(&logBookWrite);
}

#endif