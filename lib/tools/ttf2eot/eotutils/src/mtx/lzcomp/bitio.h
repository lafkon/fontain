/****************************************************************************************/
/*                                      bitio.h                                         */
/****************************************************************************************/
#include "mtxmem.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef struct {
    /* private */
    unsigned char  *mem_bytes;    /* Memory data buffer */
    long            mem_index;    /* Memory area size */
    long            mem_size;    /* Memory area size */
    
    
    unsigned short input_bit_count;     /* Input bits buffered */
    unsigned short input_bit_buffer;    /* Input buffer */
    long bytes_in;                /* Input byte count */

    unsigned short output_bit_count;    /* Output bits buffered */
    unsigned short output_bit_buffer;    /* Output buffer */
    long bytes_out;                /* Output byte count */

    char ReadOrWrite;
    
    MTX_MemHandler *mem;  
    /* public */
    /* No public fields! */
} BITIO;

/* public interface routines */
/* Writes out <numberOfBits> to the output memory */
void MTX_BITIO_WriteValue( BITIO *t, unsigned long value, long numberOfBits );
/* Reads out <numberOfBits> from the input memory */
unsigned long MTX_BITIO_ReadValue( BITIO *t, long numberOfBits );

/* Read a bit from input memory */
short MTX_BITIO_input_bit(BITIO *t);

/* Write one bit to output memory */
void MTX_BITIO_output_bit(BITIO *t,unsigned long bit);
/* Flush any remaining bits to output memory before finnishing */
void MTX_BITIO_flush_bits(BITIO *t);

/* Returns the memory buffer pointer */
unsigned char *MTX_BITIO_GetMemoryPointer( BITIO *t );
long MTX_BITIO_GetBytesOut( BITIO *t ); /* Get method for the output byte count */
long MTX_BITIO_GetBytesIn( BITIO *t );  /* Get method for the input byte count */

/* Constructor for the new Memory based incarnation */
BITIO *MTX_BITIO_Create( MTX_MemHandler *mem, void *memPtr, long memSize, const char param ); /* mem Pointer, current size, 'r' or 'w' */
/* Destructor */
void MTX_BITIO_Destroy(BITIO *t);

#ifdef __cplusplus
}
#endif

