#include <cassert>
#include <cstdlib>

void* operator new(std::size_t count)
{
    constexpr const size_t offset = 8;

    // allocate a bit more so we can safely offset it
    void* ptr = std::malloc(count + offset);

    // verify malloc returned 16 bytes aligned mem
    static_assert(__STDCPP_DEFAULT_NEW_ALIGNMENT__ == 16);
    assert(((std::ptrdiff_t)ptr & (__STDCPP_DEFAULT_NEW_ALIGNMENT__ - 1)) == 0);

    return (char*)ptr + offset;
}

struct Param
{
    void* _cookie1;
    void* _cookie2;
};

static_assert(alignof(Param) == 8);
#include <stdio.h>
int main()
{
    printf("Hewwo\n");
    Param* p = new Param;
}
