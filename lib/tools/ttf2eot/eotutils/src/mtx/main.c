#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <stdint.h>
#include <stdbool.h>

#include "mtx.h"

int main(int argc, char **argv)
{
    FILE *input = fopen(argv[1], "r");
    struct stat stat;
    uint8_t *data, *rest, *code;
    mtx_t *mtx;
    size_t rsize, dsize, csize;

    fstat(fileno(input), &stat);
    data = malloc(stat.st_size);
    fread(data, stat.st_size, 1, input);
    mtx_init(&mtx, data, stat.st_size);
    mtx_dump(mtx);

    FILE *f = fopen("output.ctf", "w");

    mtx_getRest(mtx, &rest, &rsize);
    fwrite(rest, 1, rsize, f);

    mtx_getData(mtx, &data, &dsize);
    fwrite(data, 1, dsize, f);

    mtx_getCode(mtx, &code, &csize);
    fwrite(code, 1, csize, f);

    fclose(f);

    mtx_fini(mtx);
    fclose(input);
    free(data);
    return 0;
}
