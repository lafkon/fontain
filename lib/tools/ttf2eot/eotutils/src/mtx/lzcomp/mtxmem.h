/****************************************************************************************/
/*                                      mtxmem.h                                        */
/****************************************************************************************/


#ifndef MEMORY_HPP
#define MEMORY_HPP

#include <setjmp.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct {
    /* private */ 
    void *pointermem;
    long pointersize;
} mem_struct;

#ifndef MTX_MEMPTR
#define MTX_MEMPTR
#ifdef BIT16  /* for 16-bit applications */
typedef void *(*MTX_MALLOCPTR)(unsigned long);
typedef void *(*MTX_REALLOCPTR)(void *, unsigned long, unsigned long);
typedef void (*MTX_FREEPTR)(void *);
#else         /* for 32-bit applications */
typedef void *(*MTX_MALLOCPTR)(size_t);
typedef void *(*MTX_REALLOCPTR)(void *, size_t);
typedef void (*MTX_FREEPTR)(void *);
#endif /* BIT16 */
#endif /* MTX_MEMPTR */

typedef struct {
    /* private */
    mem_struct *mem_pointers;
    long mem_maxPointers;
    long mem_numPointers; /* Number of non-zero pointers */
    long mem_numNewCalls;

    MTX_MALLOCPTR    malloc;
    MTX_REALLOCPTR    realloc;
    MTX_FREEPTR        free;
    
    /* public */
    jmp_buf env;
} MTX_MemHandler;

/* public interface routines */
/* Call mem_CloseMemory on normal exit */
void MTX_mem_CloseMemory( MTX_MemHandler *t ); /*  Frees internal memory and for debugging purposes */
/* Call mem_FreeAllMemory insted on an abnormal (exception) exit */
void MTX_mem_FreeAllMemory( MTX_MemHandler *t ); /* Always call if the code throws an exception */


void *MTX_mem_malloc(MTX_MemHandler *t, unsigned long size);
void *MTX_mem_realloc(MTX_MemHandler *t, void *p, unsigned long size);
void  MTX_mem_free(MTX_MemHandler *t, void *deadObject);

MTX_MemHandler *MTX_mem_Create(MTX_MALLOCPTR mptr, MTX_REALLOCPTR rptr, MTX_FREEPTR fptr);
void MTX_mem_Destroy(MTX_MemHandler *t);


#ifdef __cplusplus
}
#endif

#endif /* MEMORY_HPP */

