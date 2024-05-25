#ifdef _WIN32
#define O_RDONLY 00
#define S_IRWXU 448
#define O_ASYNC 020000
#endif
#ifdef __linux__
#include <fcntl.h>
#endif