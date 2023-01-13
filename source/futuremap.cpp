#include "futuremap.h"

FutureMap::FutureMap(){
    this->m_mutex = new std::mutex();
    // this->m_map = new std::map<int, void *>();
}

void * FutureMap::get(int key)
{
    void * ptr = this->m_map[key];
    return ptr;
}

void * FutureMap::pop(int key)
{
    void * ptr = this->get(key);
    this->m_map.erase(key);
    return ptr;
}

void FutureMap::set(int key, void * ptr)
{
    this->m_mutex->lock();
    this->m_map[key] = ptr;
    this->m_mutex->unlock();
}
