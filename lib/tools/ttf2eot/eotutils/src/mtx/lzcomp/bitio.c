/****************************************************************************************/
/*                                      BITIO.C                                         */
/****************************************************************************************/
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
#include "errcodes.h"

/* Writes out <numberOfBits> to the output memory */
void MTX_BITIO_WriteValue( BITIO *t, unsigned long value, long numberOfBits )
{
    register long i;
    for ( i = numberOfBits-1; i >=0; i-- ) {
        MTX_BITIO_output_bit( t, (unsigned long)(value & (1L<<i)) );
    }
}


/* Reads out <numberOfBits> from the input memory */
unsigned long MTX_BITIO_ReadValue( BITIO *t, long numberOfBits )
{
    unsigned long value;
    long i;
    
    value = 0;
    for ( i = numberOfBits-1; i >=0; i-- ) {
        value <<= 1;
        if ( MTX_BITIO_input_bit(t) ) value |= 1;
    }
    return value; /******/
}

/* Read one bit from the input memory */
short MTX_BITIO_input_bit( register BITIO *t )
{
    /*assert( t->ReadOrWrite == 'r' ); */
    if ( t->input_bit_count-- == 0 ) {
        t->input_bit_buffer = t->mem_bytes[ t->mem_index++ ];
        if ( t->mem_index > t->mem_size ) {
            longjmp( t->mem->env, ERR_BITIO_end_of_file );
        }
        ++(t->bytes_in);
        t->input_bit_count = 7;
    }
    t->input_bit_buffer <<= 1;
    return(t->input_bit_buffer & 0x100);  /******/
}



/* Write one bit to the output memory */
void MTX_BITIO_output_bit( register BITIO *t, unsigned long bit )
{
    /*assert( t->ReadOrWrite == 'w' ); */
    t->output_bit_buffer <<= 1;
    if ( bit ) t->output_bit_buffer |= 1;
    if ( ++(t->output_bit_count) == 8 ) {
        if ( t->mem_index >=t->mem_size ) { /* See if we need more memory */
            t->mem_size += t->mem_size/2; /* Allocate in exponentially increasing steps */
            t->mem_bytes = (unsigned char *)MTX_mem_realloc( t->mem, t->mem_bytes, t->mem_size );
        }
        t->mem_bytes[t->mem_index++] = (unsigned char)t->output_bit_buffer;
        t->output_bit_count = 0;
        ++(t->bytes_out);
    }
}

/* Flush any remaining bits to output memory before finnishing */
void MTX_BITIO_flush_bits( BITIO *t )
{
    assert( t->ReadOrWrite == 'w' );
    if (t->output_bit_count > 0) {
        if ( t->mem_index >=t->mem_size ) {
            t->mem_size  = t->mem_index + 1;
            t->mem_bytes = (unsigned char *)MTX_mem_realloc( t->mem, t->mem_bytes, t->mem_size );
        }
        t->mem_bytes[t->mem_index++] = (unsigned char)(t->output_bit_buffer << (8 - t->output_bit_count));
        t->output_bit_count = 0;
        ++(t->bytes_out);
    }
}

/* Returns the memory buffer pointer */
unsigned char *MTX_BITIO_GetMemoryPointer( BITIO *t )
{
    return t->mem_bytes; /******/
}

/* Returns number of bytes written */
long MTX_BITIO_GetBytesOut( BITIO *t )
{
    assert( t->ReadOrWrite == 'w' );
    return t->bytes_out; /******/
}

/* Returns number of bytes read */
long MTX_BITIO_GetBytesIn( BITIO *t )
{
    assert( t->ReadOrWrite == 'r' );
    return t->bytes_out; /******/
}



/* Constructor for Memory based incarnation */
BITIO *MTX_BITIO_Create( MTX_MemHandler *mem, void *memPtr, long memSize, const char param )
{
    BITIO *t    = (BITIO *)MTX_mem_malloc( mem, sizeof( BITIO ) );
    t->mem        = mem;
    
    t->mem_bytes             = (unsigned char *)memPtr;
    t->mem_index             = 0;
    t->mem_size              = memSize;
    t->ReadOrWrite            = param;
    
    t->input_bit_count        = 0;
    t->input_bit_buffer        = 0;
    t->bytes_in                = 0;

    t->output_bit_count        = 0;
    t->output_bit_buffer        = 0;
    t->bytes_out            = 0;
    
    return t; /******/
}


/* Destructor */
void MTX_BITIO_Destroy(BITIO *t)
{
    if ( t->ReadOrWrite == 'w' ) {
        MTX_BITIO_flush_bits(t);
        assert( t->mem_index == t->bytes_out );
    }
    MTX_mem_free( t->mem, t );
}



