#include <cstdio>

int main(){
    int i = 5;
    float* f = (float*)&i;
    *f += 5.0f;

    return 0;
}