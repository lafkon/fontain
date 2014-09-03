#include <stdint.h>
#include <stdbool.h>
#include <unistd.h>
#include <stdio.h>

#include "embeddedfont.h"
#include "libeot.h"

int main(int argc, char **argv)
{
    eot_t *state;
    FILE *f;
    eot_init(&state, read, 0);
    eot_dump(state);
    
    // Dump the FontData
    f = fopen("output.dat", "w");
    fwrite(state->fontdata, 1, state->head.FontDataSize, f);
    fclose(f);

    eot_fini(state);
    return 0;
}
