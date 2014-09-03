#ifdef _WINDOWS
#include <windows.h>
#endif
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <string.h>
#include <ctype.h>

#include "config.h"
#include "bitio.h"
#include "ahuff.h"
#include "lzcomp.h"
#include "errcodes.h"


void *MTX_mem_malloc(MTX_MemHandler *t, unsigned long size)
{
    return t->malloc(size);
}

void *MTX_mem_realloc(MTX_MemHandler *t, void *p, unsigned long size)
{
    return t->realloc(p, size);
}

void  MTX_mem_free(MTX_MemHandler *t, void *deadObject)
{
    t->free(deadObject);
}


MTX_MemHandler *MTX_mem_Create(MTX_MALLOCPTR mptr, MTX_REALLOCPTR rptr, MTX_FREEPTR fptr)
{
    MTX_MemHandler *t = malloc(sizeof(MTX_MemHandler));
    memset(t, 0, sizeof(*t));
    t->malloc = mptr;
    t->realloc = rptr;
    t->free = fptr;
    return t;
}


