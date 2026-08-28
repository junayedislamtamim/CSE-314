#include <iostream>
#include <pthread.h>
#include <unistd.h>
#include <vector>
#include <random>

#include "defs.h"
#include "locks.h"
#include "operatives.h"
#include "reader.h"

using namespace std;

// Wrapper for operative threads to introduce Poisson random delay for arrival
void* operative_wrapper(void* arg) {
    static thread_local std::mt19937 generator(std::random_device{}());
    // Poisson distribution to reflect realistic operational constraints and varying arrival times
    std::poisson_distribution<int> distribution(4.0); 
    
    int delay = distribution(generator);
    sleep(delay); // Simulate random arrival time before starting the phase
    
    // Proceed with predefined operative tasks
    ts(arg);
    
    return nullptr;
}

// Wrapper for intelligence staff to continuously read with random intervals
void* reader_wrapper(void* arg) {
    static thread_local std::mt19937 generator(std::random_device{}());
    // Readers should remain active with appropriate randomness
    std::poisson_distribution<int> distribution(6.0); 

    while (true) {
        int delay = distribution(generator);
        sleep(delay); // Random interval before next logbook review
        reader(arg);
    }
    return nullptr;
}

int main()
{
    freopen("io/input.txt", "r", stdin);
    freopen("io/log.txt", "w", stdout);
    
    int N, M, x, y;
    if (!(cin >> N >> M >> x >> y)) return 0;

    // 1. Initialize Global State Variables
    clockTime = 0;
    entry = 0;
    readerCount = 0;

    // 2. Initialize Core Mutexes
    pthread_mutex_init(&clockTimeLock, nullptr);
    pthread_mutex_init(&logBookWrite, nullptr);
    pthread_mutex_init(&reader_, nullptr);
    pthread_mutex_init(&log_, nullptr);

    for (int i = 0; i < TYPE_STATION_COUNT; i++) {
        pthread_mutex_init(&typeStation[i], nullptr);
    }

    // 3. Initialize Unit-Level Vectors and Locks
    int num_units = N / M;
    unitLock.resize(num_units);
    recreate_.resize(num_units, M);
    distribute.resize(num_units, M);

    for (int i = 0; i < num_units; i++) {
        pthread_mutex_init(&unitLock[i], nullptr);
    }

    // 4. Create Reader Threads (Intelligence Staff)
    pthread_t readers[2];
    int reader_ids[2] = {1, 2};
    for (int i = 0; i < 2; i++) {
        // Staff members monitor the logbook continuously from initialization
        pthread_create(&readers[i], nullptr, reader_wrapper, (void*)(intptr_t)reader_ids[i]);
    }

    // 5. Create Operative Threads
    pthread_t operatives[N];
    std::vector<Data*> op_data(N);
    
    for (int i = 0; i < N; i++) {
        op_data[i] = new Data();
        op_data[i]->ID = i + 1;
        // Group operatives systematically: units of exactly M members
        op_data[i]->unitID = (i / M) + 1; 
        
        // Generate all operatives simultaneously
        pthread_create(&operatives[i], nullptr, operative_wrapper, (void*)op_data[i]);
    }

    // 6. Thread Synchronization & Cleanup
    for (int i = 0; i < N; i++) {
        pthread_join(operatives[i], nullptr);
        delete op_data[i];
    }

    // Readers run infinitely; exiting main will terminate them naturally.
    return 0;
}