#include <stdio.h>
#include <stdlib.h>

unsigned int maximum = 0;

int main(void)
{
    unsigned blocksize[] = {1024 * 1024, 1024, 1};
    void *block;
    int i, count;

    for(i = 0; i < 3; i++) {
        for(count = 1; ; count++) {
            block = malloc(maximum + blocksize[i] * count);
            if (block) {
                maximum = maximum + blocksize[i] * count;
                free(block);
            } else {
                break;
            }
        }
    }

    printf("maximum malloc size = %u bytes.\n", maximum);
}