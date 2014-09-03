#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>
#include <stdint.h>
#include <string.h>
#include <stddef.h>
#include <assert.h>

#include "mtx.h"
#include "lzcomp/config.h"
#include "lzcomp/bitio.h"
#include "lzcomp/ahuff.h"
#include "lzcomp/lzcomp.h"

static uint32_t mtx_ntoh24(uint32_t v)
{
    assert(v >> 24 == 0);
    return ntohl(v) >> 8;
}

bool mtx_init(mtx_t **state, const uint8_t *data, size_t size)
{
    const size_t kOffsetSize = 3;       // You can't sizeof(bitfield) :-(
    const size_t kDataOffOffset = 4;    // Same with offsetof()
    const size_t kCodeOffOffset = 7;
    mtx_t *mtx;

    if (size < sizeof(mtx_header_t))
        return false;

    mtx = malloc(sizeof(mtx_t));

    memcpy(&mtx->head, data, sizeof(mtx->head));
    
    if (mtx->head.version != 3)
        return false;
    
    // Possibly fixup byte order
    mtx->head.distance = mtx_ntoh24(mtx->head.distance);
    mtx->head.dataoffset = mtx_ntoh24(mtx->head.dataoffset);
    mtx->head.codeoffset = mtx_ntoh24(mtx->head.codeoffset);

    if (mtx->head.dataoffset > mtx->head.codeoffset)
        return false;

    if (mtx->head.codeoffset > size)
        return false;
    
    mtx->restsize = mtx->head.dataoffset - (kDataOffOffset + kOffsetSize + kOffsetSize);

    mtx->datasize = mtx->head.codeoffset - ((kCodeOffOffset + kOffsetSize) + mtx->restsize);

    mtx->codesize = size - (sizeof(mtx_header_t) + mtx->restsize + mtx->datasize);

    assert(size == sizeof(mtx_header_t) 
            + mtx->restsize 
            + mtx->datasize 
            + mtx->codesize);

    mtx->rest = malloc(mtx->restsize);
    mtx->data = malloc(mtx->datasize);
    mtx->code = malloc(mtx->codesize);

    memcpy(mtx->rest, data + sizeof(mtx->head), mtx->restsize);
    memcpy(mtx->data, data + sizeof(mtx->head) + mtx->restsize, mtx->datasize);

    memcpy(mtx->code,
           data + sizeof(mtx->head) + mtx->restsize + mtx->datasize,
           mtx->codesize);

    mtx->totalsize = size;

    return !! (*state = mtx);
}

bool mtx_dump(mtx_t *mtx)
{
    fprintf(stdout, "MicroType Express Font Data\n");
    fprintf(stdout, "Version: %#hhx\n", mtx->head.version);
    fprintf(stdout, "Distance: %#x\n", mtx->head.distance);
    fprintf(stdout, "Rest Block: @%u, %u compressed bytes\n",
                    sizeof(mtx->head),
                    mtx->restsize);
    fprintf(stdout, "Data Block: @%u, %u compressed bytes\n",
                    sizeof(mtx->head) + mtx->restsize,
                    mtx->datasize);
    fprintf(stdout, "Code Block: @%u, %u compressed bytes\n",
                    sizeof(mtx->head) + mtx->datasize,
                    mtx->codesize);
    fprintf(stdout, "Total: %u bytes\n", mtx->totalsize);
    return true;
}

bool mtx_getRest(mtx_t *mtx, uint8_t **data, size_t *size)
{
    MTX_MemHandler *mem = MTX_mem_Create(malloc, realloc, free);
    LZCOMP *t = MTX_LZCOMP_Create1(mem);
    *data = MTX_LZCOMP_UnPackMemory(t, mtx->rest, mtx->restsize, size, 0);
    return !! *data;
}

bool mtx_getData(mtx_t *mtx, uint8_t **data, size_t *size)
{
    MTX_MemHandler *mem = MTX_mem_Create(malloc, realloc, free);
    LZCOMP *t = MTX_LZCOMP_Create1(mem);
    *data = MTX_LZCOMP_UnPackMemory(t, mtx->data, mtx->datasize, size, 0);
    return !! *data;
}

bool mtx_getCode(mtx_t *mtx, uint8_t **data, size_t *size)
{
    MTX_MemHandler *mem = MTX_mem_Create(malloc, realloc, free);
    LZCOMP *t = MTX_LZCOMP_Create1(mem);
    *data = MTX_LZCOMP_UnPackMemory(t, mtx->code, mtx->codesize, size, 0);
    return !! *data;
}

bool mtx_fini(mtx_t *mtx)
{
    free(mtx->rest);
    free(mtx->data);
    free(mtx->code);
    free(mtx);
    return true;
}

