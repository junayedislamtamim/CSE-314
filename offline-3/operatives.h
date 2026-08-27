#ifndef OPERATIVES
#define OPERATIVES

#include <iostream>
#include <pthread.h>
#include <semaphore.h>
#include <unistd.h>
#include <queue>
#include "locks.h"

void recreate(int unitID)
{ 
    pthread_mutex_lock(&unitLock[unitID - 1]);
    recreate_[unitID - 1]--;
    pthread_mutex_unlock(&unitLock[unitID - 1]);

    if(recreate_[unitID - 1] == 0)
    {
        int time = incrTime();
        std::cout << "Unit " << unitID << " has completed document recreation phase at time " << time << '\n';
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

void ts1(void* arg)
{
    int time = incrTime();
    Data* data = (Data*) arg;
    int ID = data->ID;
    int unitID = data->unitID;

    std::cout << "Operative " << ID << " has arrived at typewriting station at time " << time << '\n';
    
    //staion availability checking using pthread_lock
    pthread_mutex_lock(&typeStation[0]);
    recreate(unitID);
    int time = incrTime();
    std::cout << "Operative " << ID << " has completed document recreation at time " << time << '\n';
    pthread_mutex_unlock(&typeStation[0]);

    sendToGroupLeader(unitID);
}

void ts2(void* arg)
{
    int time = incrTime();
    Data* data = (Data*) arg;
    int ID = data->ID;
    int unitID = data->unitID;
    std::cout << "Operative " << (int)(intptr_t)arg << " has arrived at typewriting station at time " << time << '\n';
    
    //staion availability checking using pthread_lock
    pthread_mutex_lock(&typeStation[1]);
    recreate(unitID);
    int time = incrTime();
    std::cout << "Operative " << (int)(intptr_t)arg << " has completed document recreation at time " << time << '\n';
    pthread_mutex_unlock(&typeStation[1]);

    sendToGroupLeader(unitID);
}

void ts3(void* arg)
{
    int time = incrTime();
    Data* data = (Data*) arg;
    int ID = data->ID;
    int unitID = data->unitID;
    std::cout << "Operative " << (int)(intptr_t)arg << " has arrived at typewriting station at time " << time << '\n';
    
    //staion availability checking using pthread_lock
    pthread_mutex_lock(&typeStation[2]);
    recreate(unitID);
    int time = incrTime();
    std::cout << "Operative " << (int)(intptr_t)arg << " has completed document recreation at time " << time << '\n';
    pthread_mutex_unlock(&typeStation[2]);

    sendToGroupLeader(unitID);
}

void ts4(void* arg)
{
    int time = incrTime();
    Data* data = (Data*) arg;
    int ID = data->ID;
    int unitID = data->unitID;
    std::cout << "Operative " << (int)(intptr_t)arg << " has arrived at typewriting station at time " << time << '\n';
    
    //staion availability checking using pthread_lock
    pthread_mutex_lock(&typeStation[3]);
    recreate(unitID);
    int time = incrTime();
    std::cout << "Operative " << (int)(intptr_t)arg << " has completed document recreation at time " << time << '\n';
    pthread_mutex_unlock(&typeStation[3]);

    sendToGroupLeader(unitID);
}

void log(int unitID)
{   
    pthread_mutex_lock(&logBookWrite);
    createEntry();
    int time = incrTime();
    std::cout << "Unit " << unitID << " has completed intelligence distribution at time " << time << '\n';
    pthread_mutex_unlock(&logBookWrite);
}

#endif