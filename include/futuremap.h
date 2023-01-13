#include <mutex>
#include <map>

class FutureMap
{
private:
    std::map<int, void *> m_map;
    std::mutex *m_mutex;

public:
    FutureMap();
    void *get(int key);
    void *pop(int key);
    void set(int key, void *val);
};