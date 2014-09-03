/****************************************************************************************/
/*                                      ahuff.h                                         */
/****************************************************************************************/
#include "mtxmem.h"

#ifdef __cplusplus
extern "C" {
#endif

extern long MTX_AHUFF_BitsUsed( register long x );


/* This struct is only for internal use by AHUFF */
typedef struct {
    short up;
    short left;
    short right;
    short code; /* < 0 for internal node, == code otherwise */
    long weight;
} nodeType;


typedef struct {
    /* private */
    nodeType *tree;
    short *symbolIndex;
    long bitCount, bitCount2;
    long range;
    
    BITIO *bio;
    MTX_MemHandler *mem;

    int maxSymbol;
    
    
    long countA;
    long countB;
    long sym_count;
    /* public */
    /* No public fields! */
} AHUFF;

    
/* Public Interface */
short MTX_AHUFF_ReadSymbol( AHUFF *t );
long MTX_AHUFF_WriteSymbolCost( AHUFF *t, short symbol ); /* returns 16.16 bit cost */
void MTX_AHUFF_WriteSymbol( AHUFF *t, short symbol ); 

/* Constructor */
AHUFF *MTX_AHUFF_Create( MTX_MemHandler *mem, BITIO *bio, short range );        /* [0 .. range-1] */
/* Destructor */
void MTX_AHUFF_Destroy( AHUFF *t );

#ifdef __cplusplus
}
#endif

