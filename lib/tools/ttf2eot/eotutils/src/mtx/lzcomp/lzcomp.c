/****************************************************************************************/
/*                                      LZCOMP.C                                        */
/****************************************************************************************/
#ifdef _WINDOWS
#include <windows.h>
#endif
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <string.h>
#include <ctype.h>
#include <stdbool.h>

#include "config.h"
#include "bitio.h"
#include "ahuff.h"
#include "lzcomp.h"
#include "errcodes.h"

#define sizeof_hasnNodePtr 4


/*const long num_DistRanges = 6; */
/*const long dist_max   = ( dist_min + (1L << (dist_width*num_DistRanges)) - 1 ); */

/*const int DUP2          = 256 + (1L << len_width) * num_DistRanges; */
/*const int DUP4          = DUP2 + 1; */
/*const int DUP6          = DUP4 + 1; */
/*const int NUM_SYMS      = DUP6 + 1; */

const long max_2Byte_Dist = 512;

/* Sets the maximum number of distance ranges used, based on the <length> parameter */
static void SetDistRange( LZCOMP *t, long length )
{
    const long len_min   = 2;
    const long len_min3  = 3;
    const long len_width = 3;
    
    const long bit_Range = 3 - 1; /* == len_width - 1 */
    
    
    const long dist_min      = 1;
    const long dist_width = 3;
    t->num_DistRanges = 1;
    t->dist_max   = ( dist_min + (1L << (dist_width*t->num_DistRanges)) - 1 );
    while ( t->dist_max  < length ) {
        t->num_DistRanges++;
        t->dist_max    = ( dist_min + (1L << (dist_width*t->num_DistRanges)) - 1 );
    }
    t->DUP2          = 256 + (1L << len_width) * t->num_DistRanges;
    t->DUP4          = t->DUP2 + 1;
    t->DUP6          = t->DUP4 + 1;

    t->NUM_SYMS      = t->DUP6 + 1;
}

#ifdef COMPRESS_ON

/* Returns the number of distance ranges necessary to encode the <distance> */ 
#ifndef SLOWER
#define GetNumberofDistRanges( distance ) ((MTX_AHUFF_BitsUsed( (distance) - dist_min ) + dist_width-1) / dist_width)
#else
static long GetNumberofDistRanges( register long distance )
{
    register long distRanges, bitsNeeded;
    const long len_min      = 2;
    const long len_min3  = 3;
    const long len_width = 3;
    
    const long bit_Range = 3 - 1; /* == len_width - 1 */
    
    
    const long dist_min      = 1;
    const long dist_width = 3;
            
    assert( distance >=dist_min );
    bitsNeeded = MTX_AHUFF_BitsUsed( distance - dist_min );
    /* 1,2,3.. */
    #ifdef OLD
        distRanges = bitsNeeded / dist_width;
        if ( distRanges * dist_width < bitsNeeded ) distRanges++;
    #endif /* OLD */
    distRanges = (bitsNeeded + dist_width-1) / dist_width;    assert( distRanges * dist_width >=bitsNeeded );
    assert( (distRanges-1) * dist_width < bitsNeeded );
    return distRanges; /******/
}
#endif /* SLOWER */
#endif /*COMPRESS_ON */




#ifdef COMPRESS_ON
/* Encodes the length <value> and the number of distance ranges used for this distance */
static void EncodeLength( LZCOMP *t, long value, long distance, long numDistRanges )
{
    long i, bitsUsed, symbol;
    unsigned long mask = 1;
    const long len_min      = 2;
    const long len_min3  = 3;
    const long len_width = 3;
    
    const long bit_Range = 3 - 1; /* == len_width - 1 */
    
    
    const long dist_min      = 1;
    const long dist_width = 3;

    if ( distance >=max_2Byte_Dist ) {
        value -= len_min3;
    } else {
        value -= len_min;
    }
    assert( value >=0 );
    assert( numDistRanges >=1 && numDistRanges <= t->num_DistRanges );
    bitsUsed = MTX_AHUFF_BitsUsed( value );
    assert( bit_Range == len_width - 1 );
    
    /* for ( i = 0; i < bitsUsed; ) i += bit_Range; */
    /* i = (bitsUsed + bit_Range-1)/bit_Range * bit_Range; */
    /* for ( i = bit_Range; i < bitsUsed; ) i += bit_Range; */
    for ( i = bit_Range; bitsUsed > i; ) i += bit_Range; /* fastest option ! */
    assert ( bitsUsed <= i );
    mask = 1L << (i-1);
    symbol = bitsUsed > bit_Range ? 2 : 0; /* set to 2 so we eliminate the first symbol <= 1 below */
    /* repeat bit_Range times, hard-wire so that we do not have to loop */
    assert( bit_Range == 2 );
    /* 1 */
    if ( value & mask ) symbol |= 1; mask >>=1;
    /* 2 */
    symbol <<= 1;
    if ( value & mask ) symbol |= 1; mask >>=1;
    
    
    MTX_AHUFF_WriteSymbol( t->sym_ecoder, (short)(256 + symbol +  (numDistRanges - 1) * (1L << len_width)) );
    for ( i = bitsUsed - bit_Range; i >=1; ) {
        symbol = i > bit_Range ? 2 : 0; /* set to 2 so we eliminate the first symbol <= 1 below */
        /* repeat bit_Range times, hard-wire so that we do not have to loop */
        assert( bit_Range == 2 );
        /* 1 */
        if ( value & mask ) symbol |= 1; mask >>=1;
        /* 2 */
        symbol <<= 1;
        if ( value & mask ) symbol |= 1; mask >>=1;
        
        i -= bit_Range;
        MTX_AHUFF_WriteSymbol( t->len_ecoder, (short)symbol );
    }
}


/* Same as EncodeLength, except it only computes the cost */
static long EncodeLengthCost( LZCOMP *t, long value, long distance, long numDistRanges )
{
    long i, bitsUsed, symbol, count;
    unsigned long mask = 1;
    const long len_min   = 2;
    const long len_min3  = 3;
    const long len_width = 3;
    
    const long bit_Range = 3 - 1; /* == len_width - 1 */
    
    
    const long dist_min   = 1;
    const long dist_width = 3;
    
    if ( distance >=max_2Byte_Dist ) {
        value -= len_min3;
    } else {
        value -= len_min;
    }
    assert( value >=0 );
    assert( numDistRanges >=1 && numDistRanges <= t->num_DistRanges );
    bitsUsed = MTX_AHUFF_BitsUsed( value );
    assert( bit_Range == len_width - 1 );
    
    /* for ( i = 0; i < bitsUsed; ) i += bit_Range; */
    /* i = (bitsUsed + bit_Range-1)/bit_Range * bit_Range; */
    /* for ( i = bit_Range; i < bitsUsed; ) i += bit_Range; */
    for ( i = bit_Range; bitsUsed > i; ) i += bit_Range; /* fastest option ! */
    assert ( bitsUsed <= i );
    mask = 1L << (i-1);
    symbol = bitsUsed > bit_Range ? 2 : 0; /* set to 2 so we eliminate the first symbol <= 1 below */
    /* repeat bit_Range times, hard-wire so that we do not have to loop */
    assert( bit_Range == 2 );
    /* 1 */
    if ( value & mask ) symbol |= 1; mask >>=1;
    /* 2 */
    symbol <<= 1;
    if ( value & mask ) symbol |= 1; mask >>=1;
    
    
    count = MTX_AHUFF_WriteSymbolCost( t->sym_ecoder, (short)(256 + symbol +  (numDistRanges - 1) * (1L << len_width)) );
    for ( i = bitsUsed - bit_Range; i >=1; ) {
        symbol = i > bit_Range ? 2 : 0; /* set to 2 so we eliminate the first symbol <= 1 below */
        /* repeat bit_Range times, hard-wire so that we do not have to loop */
        assert( bit_Range == 2 );
        /* 1 */
        if ( value & mask ) symbol |= 1; mask >>=1;
        /* 2 */
        symbol <<= 1;
        if ( value & mask ) symbol |= 1; mask >>=1;
        
        i -= bit_Range;
        count += MTX_AHUFF_WriteSymbolCost( t->len_ecoder, (short)symbol );
    }
    return count; /*****/
}

#endif /* COMPRESS_ON */

#ifdef DECOMPRESS_ON
/* Decodes the length, and also returns the number of distance ranges used for the distance */
static long DecodeLength( LZCOMP *t, int symbol, long *numDistRanges )
{
    unsigned long mask;
    long done, bits, firstTime = symbol >=0, value = 0;
    const long len_min   = 2;
    const long len_min3  = 3;
    const long len_width = 3;
    
    const long bit_Range = 3 - 1; /* == len_width - 1 */
    
    
    const long dist_min   = 1;
    const long dist_width = 3;
    
    mask      = 1L << bit_Range;
    do {
        if ( firstTime ) {
            bits = symbol - 256;
            firstTime = false;
            assert( bits >=0 );
            /*assert( bits < 8 ); */
            *numDistRanges = (bits / (1L << len_width) ) + 1;
            assert( *numDistRanges >=1 && *numDistRanges <= t->num_DistRanges );
            bits = bits % (1L << len_width);
        } else {
            bits = MTX_AHUFF_ReadSymbol(t->len_ecoder);
        }
        done = (bits & mask) == 0;
        bits &= ~mask;
        value <<= bit_Range;
        value |= bits;
    } while ( !done );
    
    value += len_min;

    return value; /******/
}
#endif /* DECOMPRESS_ON */


#ifdef COMPRESS_ON
/* Encodes the distance */
static void EncodeDistance2( LZCOMP *t, long value, long distRanges )
{
    register long i;
    const long len_min   = 2;
    const long len_min3  = 3;
    const long len_width = 3;

    const long bit_Range = 3 - 1; /* == len_width - 1 */


    const long dist_min   = 1;
    const long dist_width = 3;
    const long mask = (1L << dist_width) - 1;


    value -= dist_min;
    assert( value >=0 );
    assert( distRanges >=1 && distRanges <= t->num_DistRanges );
    for ( i = (distRanges-1)*dist_width; i >=0; i -= dist_width ) {
        MTX_AHUFF_WriteSymbol( t->dist_ecoder, (short)((value >> i) & mask) );
    }
}

/* Same as EncodeDistance2, except it only computes the cost */
static long EncodeDistance2Cost( LZCOMP *t, long value, long distRanges )
{
    register long i, count = 0;
    const long len_min   = 2;
    const long len_min3  = 3;
    const long len_width = 3;
    
    const long bit_Range = 3 - 1; /* == len_width - 1 */
    
    
    const long dist_min   = 1;
    const long dist_width = 3;
    const long mask = (1L << dist_width) - 1;


    value -= dist_min;
    assert( value >=0 );
    assert( distRanges >=1 && distRanges <= t->num_DistRanges );
    for ( i = (distRanges-1)*dist_width; i >=0; i -= dist_width ) {
        count += MTX_AHUFF_WriteSymbolCost( t->dist_ecoder, (short)((value >> i) & mask) );
    }
    return count;
}
#endif /*COMPRESS_ON */

#ifdef COMPRESS_ON

/* Frees all nodes from the hash */
static void FreeAllHashNodes(LZCOMP *t)
{
    register hasnNode *nextNodeBlock;
    const short hNodeAllocSize = 4095;

    while ( t->nodeBlock != NULL ) {
        nextNodeBlock = t->nodeBlock[hNodeAllocSize].next;
        MTX_mem_free( t->mem, t->nodeBlock );
        t->nodeBlock = nextNodeBlock;
    }
}


/* Returns a new hash node */
static hasnNode *GetNewHashNode(LZCOMP *t)
{
    register hasnNode *hNode;
    const short hNodeAllocSize = 4095;


    /* Try recycling first */
    if ( t->freeList != NULL ) {
        hNode = t->freeList;
        t->freeList = hNode->next;
    } else {
        if ( t->nextFreeNodeIndex >=hNodeAllocSize ) {
            register hasnNode *oldNodeBlock;

            oldNodeBlock = t->nodeBlock;
            t->nodeBlock = (hasnNode *)MTX_mem_malloc( t->mem, sizeof(hasnNode) * (hNodeAllocSize+1) );
            
            assert( t->nodeBlock != NULL );
            t->nodeBlock[hNodeAllocSize].next = oldNodeBlock;
            t->nextFreeNodeIndex = 0;
        }
        hNode = &t->nodeBlock[t->nextFreeNodeIndex++];
    }
    return hNode; /******/
}




/* Updates our model, for the byte pointed to by <index> */
static void UpdateModel( LZCOMP *t, long index )
{
    hasnNode *hNode;
    unsigned char c = t->ptr1[ index ];
    long pos;
    unsigned short prev_c;
    
    if ( index > 0 ) {
        hNode = GetNewHashNode( t );
        
        prev_c = t->ptr1[ index -1 ];
        pos = (prev_c << 8) |  c;

        hNode->index = index-1;
        hNode->next  = t->hashTable[ pos ];
        t->hashTable[ pos ] = hNode;
    }
}
#else
static void UpdateModel( LZCOMP *t, long index )
{
    ;
}
#endif /* COMPRESS_ON */

#ifdef DECOMPRESS_ON
/* Decodes the distance */
static long DecodeDistance2( LZCOMP *t, long distRanges )
{
    long i, bits, value = 0;
    const long len_min      = 2;
    const long len_min3  = 3;
    const long len_width = 3;
    
    const long bit_Range = 3 - 1; /* == len_width - 1 */
    
    
    const long dist_min      = 1;
    const long dist_width = 3;
    
    /* for ( i = 0; i < distRanges; i++ ) */
    for ( i = distRanges; i > 0; i-- ) {
        bits = MTX_AHUFF_ReadSymbol(t->dist_ecoder);
        value <<= dist_width;
        value |= bits;
    }
    value += dist_min;
    return value; /******/
}
#endif /* DECOMPRESS_ON */

/*
 * Initializes our hashTable and also pre-loads some data so that
 * there is a chance that bytes in the beginning of the file
 * might use copy items.
 * if compress is true then it initializes for compression, otherwise
 * it initializes only for decompression.
 */
static void InitializeModel( LZCOMP *t, int compress )
{
    long i, j, k;
    const long preLoadSize = 2*32*96 + 4*256;

#ifdef COMPRESS_ON 
    if ( compress ) {
        unsigned long hashSize;
        /*t->hashTable         = new hasnNode * [ 0x10000 ]; assert( t->hashTable != NULL ); 
        t->hashTable         = (hasnNode **)MTX_mem_malloc( t->mem, sizeof(hasnNode *) * 0x10000 ); */ 
        hashSize            = (unsigned long)sizeof_hasnNodePtr * 0x10000;
        t->hashTable         = (hasnNode **)MTX_mem_malloc( t->mem, hashSize );
        for ( i = 0; i < 0x10000; i++ ) {
            t->hashTable[i] = NULL;
        }
    }
#endif
    i = 0;
    assert( preLoadSize > 0 );

    if ( compress ) {
        for ( k = 0; k < 32; k++ ) {
            for ( j = 0; j < 96; j++ ) {
                t->ptr1[i] = (unsigned char)k; UpdateModel(t,i++);
                t->ptr1[i] = (unsigned char)j; UpdateModel(t,i++);
            }
        }
        j = 0;
        while ( i < preLoadSize && j < 256 ) {
            t->ptr1[i] = (unsigned char)j; UpdateModel(t,i++);
            t->ptr1[i] = (unsigned char)j; UpdateModel(t,i++);
            t->ptr1[i] = (unsigned char)j; UpdateModel(t,i++);
            t->ptr1[i] = (unsigned char)j; UpdateModel(t,i++);
            j++;
        }
    } else {
        for ( k = 0; k < 32; k++ ) {
            for ( j = 0; j < 96; j++ ) {
                t->ptr1[i++] = (unsigned char)k;
                t->ptr1[i++] = (unsigned char)j;
            }
        }
        j = 0;
        while ( i < preLoadSize && j < 256 ) {
            t->ptr1[i++] = (unsigned char)j;
            t->ptr1[i++] = (unsigned char)j;
            t->ptr1[i++] = (unsigned char)j;
            t->ptr1[i++] = (unsigned char)j;
            j++;
        }
    }
    assert( j == 256 );
    assert( i == preLoadSize );
}


#ifdef COMPRESS_ON
/* Finds the best copy item match */
static long Findmatch( register LZCOMP *t, long index, long *bestDist, long *gainOut, long *costPerByte  )
{
    long length, bestLength = 0, bestGain = 0;
    long maxLen, i, distance, bestCopyCost = 0, bestDistance = 0;
    long copyCost, literalCost, distRanges, gain;
    register hasnNode *hNode, *prevNode = NULL;
    long hNodeCount = 0;
    long maxIndexMinusIndex = t->maxIndex - index;
    unsigned char *ptr2 = &t->ptr1[index];
#define MAX_COST_CACHE_LENGTH 32
    long literalCostCache[MAX_COST_CACHE_LENGTH+1], maxComputedLength = 0;
    unsigned short pos;
    const long len_min   = 2;
    const long len_min3  = 3;
    const long len_width = 3;
    
    const long bit_Range = 3 - 1; /* == len_width - 1 */
    
    
    const long dist_min   = 1;
    const long dist_width = 3;

    assert( index >=0 );
    literalCostCache[0] = 0;
    if ( 1 < maxIndexMinusIndex ) {
        pos   = ptr2[0];
        pos <<= 8;
        assert( &ptr2[1] < &t->ptr1[t->maxIndex] );
        pos  |= ptr2[1];
    
        /* *costPerByte = 0xff0000; */
        for ( hNode = t->hashTable[ pos ]; hNode != NULL; prevNode = hNode, hNode = hNode->next ) {
            i          = hNode->index;
            distance = index - i; /* to head */
            /* hNodeCount added March 14, 1996 */
            if ( ++hNodeCount > 256 || distance > t->maxCopyDistance ) { /* Added Feb 26, 1996 */
                if ( t->hashTable[ pos ] == hNode ) {
                    assert( prevNode == NULL );
                    t->hashTable[ pos ] = NULL;
                } else {
                    assert( prevNode != NULL );
                    assert( prevNode->next == hNode );
                    prevNode->next = NULL;
                }
                while ( hNode != NULL ) {
                    hasnNode *oldHead    = t->freeList;
                    t->freeList            = hNode;
                    hNode                 = hNode->next;
                    t->freeList->next     = oldHead;
                }
                break; /******/
            }
            maxLen    = index - i;
            if ( maxIndexMinusIndex < maxLen ) maxLen = maxIndexMinusIndex;
            
            if ( maxLen < len_min )                                        continue; /******/
            assert( t->ptr1[i+0] == ptr2[0] );
            assert( t->ptr1[i+1] == ptr2[1] );
            /* We already have two matching bytes, so start at two instead of zero !! */
            /* for ( length = 0; i < index && length+index < t->maxIndex; i++ ) */
            i += 2;
            assert( &ptr2[maxLen-1] < &t->ptr1[t->maxIndex] );
            for ( length = 2; length < maxLen && t->ptr1[i] == ptr2[length]; i++ ) {
                length++;
            }
            assert( length >=2 || index + length >=t->maxIndex );
            if ( length < len_min )                                        continue; /******/
                
            distance    = distance - length + 1; /* tail */
            assert( distance > 0 );
                
            if ( distance > t->dist_max  )                                continue; /******/
            if ( length == 2 && distance >=max_2Byte_Dist )            continue; /******/
            if ( length <= bestLength && distance > bestDistance ) {
                if ( length <= bestLength-2 )                             continue; /***** SPEED optimization *****/
                if ( distance > (bestDistance << dist_width) ) {
                    if ( length < bestLength )                             continue; /***** SPEED optimization *****/
                    if ( distance > (bestDistance << (dist_width+1)) )    continue; /***** SPEED optimization *****/
                }
            }
                
            if ( length > maxComputedLength ) {
                long limit = length;
                if ( limit > MAX_COST_CACHE_LENGTH ) limit = MAX_COST_CACHE_LENGTH;
                for ( i = maxComputedLength; i < limit; i++ ) {
                    literalCostCache[i+1] = literalCostCache[i] + MTX_AHUFF_WriteSymbolCost( t->sym_ecoder, ptr2[i] );
                }
                maxComputedLength = limit;
                if ( length > MAX_COST_CACHE_LENGTH ) {
                    assert( maxComputedLength == MAX_COST_CACHE_LENGTH );
                    literalCost = literalCostCache[MAX_COST_CACHE_LENGTH];
                    /* just approximate */
                    literalCost += literalCost/MAX_COST_CACHE_LENGTH * (length-MAX_COST_CACHE_LENGTH);
                } else {
                    literalCost = literalCostCache[length];
                }
            } else {
                literalCost = literalCostCache[length];
            }
            
            if ( literalCost > bestGain ) {
                distRanges    = GetNumberofDistRanges( distance );
                copyCost    = EncodeLengthCost( t, length, distance, distRanges );
                if ( literalCost - copyCost - (distRanges << 16) > bestGain ) {
                    /* The if statement above conservatively assumes only one bit per range for distBitCount */
                    copyCost    += EncodeDistance2Cost( t,  distance, distRanges );
                    gain         = literalCost - copyCost;
                        
                    if ( gain > bestGain ) {
                        bestGain         = gain;
                        assert( hNode->index < index );
                        bestLength        = length;
                        bestDistance    = distance;
                        bestCopyCost    = copyCost;
                    }
                }
            }
        }
    }
    *costPerByte  = bestLength ? bestCopyCost / bestLength : 0; /* To avoid divide by zero */
    *bestDist = bestDistance;
    *gainOut  = bestGain;
    return bestLength; /******/
}
#endif /*COMPRESS_ON */

#ifdef COMPRESS_ON
/* Makes a decision on whether to use a copy item, and then if it decides */
/* to use a copy item it decides on an optimal length & distance for the copy. */
static long MakeCopyDecision( LZCOMP *t, long index, long *bestDist )
{
    long dist1, dist2, dist3;
    long len1, len2, len3;
    long gain1, gain2, gain3;
    long costPerByte1, costPerByte2, costPerByte3;
    long lenBitCount, distBitCount;
    long here, symbolCost, dup2Cost;
    const long len_min   = 2;
    const long len_min3  = 3;
    const long len_width = 3;

    const long bit_Range = 3 - 1; /* == len_width - 1 */


    const long dist_min      = 1;
    const long dist_width = 3;
    
    here    = index;
    len1    = Findmatch( t, index, &dist1, &gain1, &costPerByte1 );
    UpdateModel(t, index++ );
    if ( gain1 > 0 ) {
        len2 = Findmatch( t, index, &dist2, &gain2, &costPerByte2 );
        symbolCost = MTX_AHUFF_WriteSymbolCost( t->sym_ecoder, t->ptr1[here]);
        if ( gain2 >=gain1 && costPerByte1 > (costPerByte2 * len2 + symbolCost ) / (len2+1) ) {
            len1 = 0;
        } else if ( len1 > 3 ) {
            /* Explore cutting back on len1 by one unit */
            len2 = Findmatch( t, here + len1, &dist2, &gain2, &costPerByte2 );
            if ( len2 >=2 ) {
                len3 = Findmatch( t, here + len1-1, &dist3, &gain3, &costPerByte3 );
                if ( len3 > len2 && costPerByte3 < costPerByte2 ) {
                    long cost1A, cost1B, distRanges;
                    distRanges = GetNumberofDistRanges( dist1 + 1 );
                    
                    lenBitCount  = EncodeLengthCost( t, len1-1, dist1+1, distRanges );
                    distBitCount = EncodeDistance2Cost( t,  dist1+1, distRanges );
                    cost1B  = lenBitCount + distBitCount;
                    cost1B += costPerByte3 * len3;
                    
                    cost1A  = costPerByte1 * len1;
                    cost1A += costPerByte2 * len2;
                    if ( (cost1A / (len1+len2)) > (cost1B/ (len1-1+len3))  ) {
                        len1--;
                        dist1++;
                    } 
                }
            }
        }
        if ( len1 == 2 ) {
            if ( here >=2 && t->ptr1[here] == t->ptr1[here-2] ) {
                dup2Cost = MTX_AHUFF_WriteSymbolCost( t->sym_ecoder, (short)t->DUP2 );
                if ( costPerByte1 * 2 > dup2Cost + MTX_AHUFF_WriteSymbolCost( t->sym_ecoder, t->ptr1[here+1] )  ) {
                    len1 = 0;
                }
            } else if ( here >=1 && here+1 < t->maxIndex && t->ptr1[here+1] == t->ptr1[here-1] ) {
                dup2Cost = MTX_AHUFF_WriteSymbolCost( t->sym_ecoder, (short)t->DUP2 );
                if ( costPerByte1 * 2 > symbolCost + dup2Cost ) {
                    len1 = 0;
                }
            }
        }
    }
    *bestDist = dist1;
    return len1; /******/
}
#endif /* COMPRESS_ON */

#ifdef COMPRESS_ON
/* This method does the compression work */
static void Encode( LZCOMP *t )
{
    register long i, j, limit;
    long here, len, dist;
    long distRanges;
    const long len_min   = 2;
    const long len_min3  = 3;
    const long len_width = 3;
    
    const long bit_Range = 3 - 1; /* == len_width - 1 */
    
    
    const long dist_min   = 1;
    const long dist_width = 3;
    const long preLoadSize = 2*32*96 + 4*256;
    
    assert( (t->length1 & 0xff000000) == 0 );
    
    t->maxIndex = t->length1+preLoadSize;
    InitializeModel( t, true );
    MTX_BITIO_WriteValue( t->bitOut, t->length1, 24 );
    
    limit = t->length1+preLoadSize;
    for ( i = preLoadSize; i < limit; ) {
        here    = i;
        len        = MakeCopyDecision( t, i++, &dist );

        if ( len > 0  ) {
            assert( dist > 0 );
            
            distRanges  = GetNumberofDistRanges( dist );
            EncodeLength( t, len, dist, distRanges );
            EncodeDistance2( t,  dist, distRanges );

            /*for ( j = 0; j < len; j++ ) { */
            /*    assert( t->ptr1[here+j] == t->ptr1[here-dist-len+1 + j] ); */
            /*} */
            for ( j = 1; j < len; j++ ) {
                UpdateModel(t, i++ );
            }
        } else {
            unsigned char c = t->ptr1[here];
            if ( here >=2 && c == t->ptr1[here-2] ) {
                MTX_AHUFF_WriteSymbol( t->sym_ecoder, (short)t->DUP2 );
            } else {
                if ( here >=4 && c == t->ptr1[here-4] ) {
                    MTX_AHUFF_WriteSymbol( t->sym_ecoder, (short)t->DUP4 );
                } else {
                    if ( here >=6 && c == t->ptr1[here-6] ) {
                        MTX_AHUFF_WriteSymbol( t->sym_ecoder, (short)t->DUP6 );
                    } else {
                        MTX_AHUFF_WriteSymbol( t->sym_ecoder, t->ptr1[here] ); /* 0-bit + byte */
                    }
                }
            }
        }
    }
    if ( i != t->maxIndex ) longjmp( t->mem->env, ERR_LZCOMP_Encode_bounds );
}
#endif /* COMPRESS_ON */

#ifdef DECOMPRESS_ON
/* This method does the de-compression work */
/* There is potential to save some memory in the future by uniting */
/* dataOut and ptr1 only when the run length encoding is not used. */
static unsigned char *Decode( register LZCOMP *t, long *size )
{
    register int symbol;
    long j, length, distance, start, pos = 0;
    long numDistRanges;
    register unsigned char *ptr1;
    register unsigned char value;
    register usingRunLength = t->usingRunLength;
    long dataOutSize, index = 0;
    unsigned char *dataOut;
    const long preLoadSize = 2*32*96 + 4*256;
    
    dataOut = (unsigned char *)MTX_mem_malloc( t->mem, dataOutSize = t->out_len );

    InitializeModel( t, false );
    if ( !t->ptr1_IsSizeLimited ) {
        ptr1 = (unsigned char __huge *)t->ptr1 + preLoadSize;
        for ( pos = 0; pos < t->out_len;) {
            symbol = MTX_AHUFF_ReadSymbol(t->sym_ecoder);
            if ( symbol < 256 ) {
                /* Literal item */
                value = (unsigned char)symbol;
            } else if ( symbol == t->DUP2 ) {
                /* One byte copy item */
                value = ptr1[ pos - 2 ];
            } else if ( symbol == t->DUP4 ) {
                /* One byte copy item */
                value = ptr1[ pos - 4 ];
            } else if ( symbol == t->DUP6 ) {
                /* One byte copy item */
                value = ptr1[ pos - 6 ];
            } else {
                /* Copy item */
                length        = DecodeLength( t, symbol, &numDistRanges );
                distance    = DecodeDistance2( t, numDistRanges );
                if ( distance >=max_2Byte_Dist  ) length++;
                start        = pos - distance - length + 1;
                for ( j = 0; j < length; j++ ) {
                    value = ptr1[ start + j ];
                    ptr1[ pos++ ] = value;
                    if ( usingRunLength ) {
                        MTX_RUNLENGTHCOMP_SaveBytes( t->rlComp, value, &dataOut, &dataOutSize, &index );
                    } else {
                        assert( index <= dataOutSize );
                        if ( index >=dataOutSize ) {
                            dataOutSize += dataOutSize>>1; /* Allocate in exponentially increasing steps */
                            dataOut = (unsigned char *)MTX_mem_realloc( t->mem, dataOut, dataOutSize );
                        }
                        dataOut[ index++ ] = value;
                        /*fputc( value, fpOut ); */
                    }
                }
                continue; /****** Do not fall through *****/
            }
            ptr1[ pos++ ] = value;
            if ( usingRunLength ) {
                MTX_RUNLENGTHCOMP_SaveBytes( t->rlComp, value, &dataOut, &dataOutSize, &index );
            } else {
                assert( index <= dataOutSize );
                if ( index >=dataOutSize ) {
                    dataOutSize += dataOutSize>>1; /* Allocate in exponentially increasing steps */
                    dataOut = (unsigned char *)MTX_mem_realloc( t->mem, dataOut, dataOutSize );
                }
                dataOut[ index++ ] = value;
                /*fputc( value, fpOut ); */
            }
        }
    } else {
        long src, dst = preLoadSize; /* source and destination indeces */
        ptr1 = t->ptr1;
        assert( t->maxCopyDistance > preLoadSize );
        for ( pos = 0; pos < t->out_len;) {
            symbol = MTX_AHUFF_ReadSymbol(t->sym_ecoder);
            if ( symbol < 256 ) {
                /* Literal item */
                value = (unsigned char)symbol;
            } else if ( symbol == t->DUP2 ) {
                /* One byte copy item */
                src = dst - 2;
                if ( src < 0 ) src = src + t->maxCopyDistance;
                value = ptr1[ src ];
            } else if ( symbol == t->DUP4 ) {
                /* One byte copy item */
                src = dst - 4;
                if ( src < 0 ) src = src + t->maxCopyDistance;
                value = ptr1[ src ];
            } else if ( symbol == t->DUP6 ) {
                /* One byte copy item */
                src = dst - 6;
                if ( src < 0 ) src = src + t->maxCopyDistance;
                value = ptr1[ src ];
            } else {
                /* Copy item */
                length        = DecodeLength( t, symbol, &numDistRanges );
                distance    = DecodeDistance2( t, numDistRanges );
                if ( distance >=max_2Byte_Dist  ) length++;
                start        = dst - distance - length + 1;
                assert( distance + length - 1 <= t->maxCopyDistance );
                for ( j = 0; j < length; j++ ) {
                    src = start + j;
                    if ( src < 0 ) src = src + t->maxCopyDistance;
                    value = ptr1[ src ];
                    ptr1[ dst ] = value;
                    dst = (dst + 1) % t->maxCopyDistance;
                    pos++;
                    if ( usingRunLength ) {
                        MTX_RUNLENGTHCOMP_SaveBytes( t->rlComp, value, &dataOut, &dataOutSize, &index );
                    } else {
                        assert( index <= dataOutSize );
                        if ( index >=dataOutSize ) {
                            dataOutSize += dataOutSize>>1; /* Allocate in exponentially increasing steps */
                            dataOut = (unsigned char *)MTX_mem_realloc( t->mem, dataOut, dataOutSize );
                        }
                        dataOut[ index++ ] = value;
                        /*fputc( value, fpOut ); */
                    }
                }
                continue; /****** Do not fall through *****/
            }
            ptr1[ dst ] = value;
            dst = (dst + 1) % t->maxCopyDistance;
            pos++;
            if ( usingRunLength ) {
                MTX_RUNLENGTHCOMP_SaveBytes( t->rlComp, value, &dataOut, &dataOutSize, &index );
            } else {
                assert( index <= dataOutSize );
                if ( index >=dataOutSize ) {
                    dataOutSize += dataOutSize>>1; /* Allocate in exponentially increasing steps */
                    dataOut = (unsigned char *)MTX_mem_realloc( t->mem, dataOut, dataOutSize );
                }
                dataOut[ index++ ] = value;
                /*fputc( value, fpOut ); */
            }
        }
    }
    assert( pos == t->out_len );
    assert( t->usingRunLength || index == t->out_len );
    if ( pos != t->out_len ) longjmp( t->mem->env, ERR_LZCOMP_Decode_bounds );
    *size = index;
    assert( dataOutSize >=*size );
    if ( t->usingRunLength ) {
        dataOut = (unsigned char *)MTX_mem_realloc( t->mem, dataOut, *size ); /* Free up some memory if possible */
    }
    return dataOut; /******/
}


#endif /*DECOMPRESS_ON */


#ifdef COMPRESS_ON

/* Call this method to compress a memory area */
unsigned char *MTX_LZCOMP_PackMemory( register LZCOMP *t, void *dataIn, long size_in, long *sizeOut )
{
    long lengthOut;
    unsigned char *bin;
    long binSize;
    const long len_min   = 2;
    const long len_min3  = 3;
    const long len_width = 3;
    
    const long bit_Range = 3 - 1; /* == len_width - 1 */
    
    
    const long dist_min   = 1;
    const long dist_width = 3;
    const long preLoadSize = 2*32*96 + 4*256;
    
    t->length1 = size_in;

    /* DeAllocate Memory */
    if ( t->ptr1 != NULL ) {
        MTX_mem_free( t->mem, t->ptr1 );
    }
    t->ptr1 = NULL;
    
    /* Allocate Memory */
    t->ptr1 = (unsigned char *)MTX_mem_malloc( t->mem, sizeof(unsigned char) * (t->length1 + preLoadSize) );
    
    memcpy( (unsigned char __huge *)t->ptr1+preLoadSize, dataIn, t->length1 );
    
    t->usingRunLength = false;
    {
        long i, packedLength = 0;
        unsigned char *out, *d;
        t->rlComp = MTX_RUNLENGTHCOMP_Create( t->mem );

        out = MTX_RUNLENGTHCOMP_PackData( t->rlComp, (unsigned char __huge *)t->ptr1+preLoadSize, t->length1, &packedLength );
        /* Only use run-length encoding if there is a clear benefit */
        if ( packedLength < t->length1 * 3 / 4 ) {
            t->usingRunLength = true;
            t->length1 = packedLength;
            MTX_mem_free( t->mem, t->ptr1 );
            t->ptr1 = (unsigned char *)MTX_mem_malloc( t->mem, sizeof(unsigned char) * (t->length1 + preLoadSize) );
            d = (unsigned char __huge *)t->ptr1+preLoadSize;
            for ( i = 0; i < t->length1; i++ ) {
                *d++ = out[i]; 
            }
        }
        MTX_mem_free( t->mem, out );
        
        MTX_RUNLENGTHCOMP_Destroy( t->rlComp ); t->rlComp = NULL;
    }
    binSize = 1024;
    bin = (unsigned char *)MTX_mem_malloc( t->mem, binSize );
    
    t->bitOut = MTX_BITIO_Create( t->mem, bin, binSize, 'w'); assert( t->bitOut != NULL );
    MTX_BITIO_output_bit(t->bitOut, t->usingRunLength); 
    
    t->dist_ecoder = MTX_AHUFF_Create( t->mem, t->bitOut, (short)(1L << dist_width) );
    assert( t->dist_ecoder != NULL );
    t->len_ecoder  = MTX_AHUFF_Create( t->mem, t->bitOut, (short)(1L << len_width) );
    assert( t->len_ecoder != NULL );
    
    SetDistRange( t, t->length1 ); /* sets t->NUM_SYMS */
    t->sym_ecoder  = MTX_AHUFF_Create( t->mem, t->bitOut, (short)t->NUM_SYMS); assert( t->sym_ecoder != NULL );
    Encode(t);  /* Do the work ! */
    
    MTX_AHUFF_Destroy( t->dist_ecoder ); t->dist_ecoder = NULL;
    MTX_AHUFF_Destroy( t->len_ecoder  ); t->len_ecoder  = NULL;
    MTX_AHUFF_Destroy( t->sym_ecoder  ); t->sym_ecoder  = NULL;
    
    MTX_BITIO_flush_bits( t->bitOut );
    lengthOut = MTX_BITIO_GetBytesOut( t->bitOut );
    bin = MTX_BITIO_GetMemoryPointer( t->bitOut );
    
    MTX_BITIO_Destroy( t->bitOut );
    t->bitOut = NULL;
    
    *sizeOut = lengthOut;
    return bin; /******/
}

#endif /* COMPRESS_ON */

#ifdef DECOMPRESS_ON
/* Call this method to un-compress memory */
unsigned char *MTX_LZCOMP_UnPackMemory( register LZCOMP *t, void *dataIn, long dataInSize, long *sizeOut, unsigned char version )
{
    long maxOutSize;
    unsigned char *dataOut;
    const long len_width = 3;
    const long dist_width = 3;
    const long preLoadSize = 2*32*96 + 4*256;
    
    assert( dataIn != NULL );
    
    /* DeAllocate Memory */
    if ( t->ptr1 != NULL ) {
        MTX_mem_free( t->mem, t->ptr1 );
    }
    t->ptr1 = NULL;
    t->rlComp = MTX_RUNLENGTHCOMP_Create( t->mem );
    
    
    t->bitIn = MTX_BITIO_Create( t->mem, dataIn, dataInSize, 'r' ); assert( t->bitIn != NULL );
    if ( version == 1 ) {  /* 5-Aug-96 awr */
        t->usingRunLength = false;
    } else {
        t->usingRunLength = MTX_BITIO_input_bit( t->bitIn ); 
    }

    t->dist_ecoder = MTX_AHUFF_Create( t->mem, t->bitIn, (short)(1L << dist_width) );
    assert( t->dist_ecoder != NULL );
    t->len_ecoder  = MTX_AHUFF_Create( t->mem, t->bitIn, (short)(1L << len_width) );
    assert( t->len_ecoder != NULL );

    t->out_len = MTX_BITIO_ReadValue( t->bitIn, 24 );
    SetDistRange( t, t->out_len ); /* Sets t->NUM_SYMS */
    /* Allocate Memory, but never more than t->maxCopyDistance bytes */
    maxOutSize = t->out_len + preLoadSize;
    t->ptr1 = (unsigned char *)MTX_mem_malloc( t->mem, sizeof(unsigned char) *
           (t->maxCopyDistance < maxOutSize ?  t->ptr1_IsSizeLimited = true, t->maxCopyDistance : maxOutSize) );
    
    t->sym_ecoder  = MTX_AHUFF_Create( t->mem, t->bitIn, (short)t->NUM_SYMS );

    assert( t->sym_ecoder != NULL );
    dataOut = Decode( t, sizeOut); /* Do the work ! */

    MTX_AHUFF_Destroy( t->dist_ecoder );     t->dist_ecoder = NULL;
    MTX_AHUFF_Destroy( t->len_ecoder  );    t->len_ecoder  = NULL;
    MTX_AHUFF_Destroy( t->sym_ecoder  );     t->sym_ecoder  = NULL;
    
    MTX_BITIO_Destroy( t->bitIn );             t->bitIn = NULL;
    MTX_RUNLENGTHCOMP_Destroy( t->rlComp );    t->rlComp = NULL;
    
    assert( t->usingRunLength || *sizeOut < maxOutSize );

    #ifdef VERBOSE
        /*cout << "Wrote " << *sizeOut << " Bytes to file <" << outName << ">" << endl; */
        printf("Wrote %ld Bytes to file\n", (long)*sizeOut);
    #endif
    return dataOut; /******/
}



#endif /* DECOMPRESS_ON */


/* Constructor */
LZCOMP *MTX_LZCOMP_Create1( MTX_MemHandler *mem  )
{
    const short hNodeAllocSize = 4095;
    LZCOMP *t    = (LZCOMP *)MTX_mem_malloc( mem, sizeof( LZCOMP ) );
    t->mem        = mem;
    
    t->ptr1                = NULL;
    t->maxCopyDistance     = 0x7fffffff;
    t->ptr1_IsSizeLimited = false;
#ifdef COMPRESS_ON
    t->freeList            = NULL;
    t->hashTable         = NULL;
    t->nodeBlock        = NULL;
    t->nextFreeNodeIndex    = hNodeAllocSize;
#endif
    return t; /*****/
}

LZCOMP *MTX_LZCOMP_Create2( MTX_MemHandler *mem, long maxCopyDistance )
{
    const long preLoadSize = 2*32*96 + 4*256;
    const short hNodeAllocSize = 4095;
    LZCOMP *t    = (LZCOMP *)MTX_mem_malloc( mem, sizeof( LZCOMP ) );
    t->mem        = mem;
    
    t->ptr1                = NULL;
    t->maxCopyDistance    = maxCopyDistance;
    if ( t->maxCopyDistance < (preLoadSize+64) ) t->maxCopyDistance = preLoadSize+64;
    t->ptr1_IsSizeLimited = false;
#ifdef COMPRESS_ON
    t->freeList            = NULL;
    t->hashTable         = NULL;
    t->nodeBlock        = NULL;
    t->nextFreeNodeIndex    = hNodeAllocSize;
#endif
    return t; /*****/
}


/* Deconstructor */
void MTX_LZCOMP_Destroy( LZCOMP *t )
{
    MTX_mem_free( t->mem, t->ptr1 );
#ifdef COMPRESS_ON
    FreeAllHashNodes(t);
    MTX_mem_free( t->mem, t->hashTable );
#endif
    MTX_mem_free( t->mem, t );
}



/*---- Begin RUNLENGTHCOMP --- */
#ifdef COMPRESS_ON
/* Invoke this method to run length compress a file in memory */
unsigned char *MTX_RUNLENGTHCOMP_PackData( RUNLENGTHCOMP *t, unsigned char *data, long lengthIn, long *lengthOut )
{
    unsigned long counters[256], minCount;
    register long i, runLength;
    unsigned char escape, theByte;
    unsigned char *out, *outBase;
    
    /* Reset the counters */
    for ( i = 0; i < 256; i++ ) {
        counters[i] = 0;
    }
    /* Set the counters */
    for ( i = 0; i < lengthIn; i++ ) {
        counters[data[i]]++;
    }
    /* Find the least frequently used byte */
    escape      = 0; /* Initialize */
    minCount = counters[0];
    for ( i = 1; i < 256; i++ ) {
        if ( counters[i] < minCount ) {
            escape     = (unsigned char)i;
            minCount = counters[i];
        }
    }
    /* Use the least frequently used byte as the escape byte to */
    /* ensure that we do the least amount of "damage". */
    
    /* We can at most grow the file by the first escape byte + minCount, since all bytes */
    /* equal to the escape byte are represented as two bytes */
    outBase = out = (unsigned char *)MTX_mem_malloc( t->mem, sizeof(unsigned char) * (lengthIn + minCount + 1) );
    
    /* write: escape byte */
    *out++ = escape;
    for ( i = 0; i < lengthIn; ) {
        long j;
        theByte = data[i];
        for ( runLength = 1, j = i + 1; j < lengthIn; j++) {
            if ( theByte == data[j] ) {
                runLength++;
                if ( runLength >=255 ) break;/******/
            } else {
                break; /******/
            }
        }
        if ( runLength > 3 ) {
            assert( runLength <= 255 );
            /* write: escape, runLength, theByte */
            /* We have a run of bytes which are equal to theByte. */
            /* This is were we WIN. */
            *out++ = escape;
            *out++ = (unsigned char)runLength;
            *out++ = theByte;
        } else {
            runLength = 1;
            if ( theByte != escape ) {
                /* write: theByte */
                /* Just write out the byte */
                *out++ = theByte;
            } else {
                /* write: escape, 0         */
                /* This signifies that we a have single byte which is equal to the escape byte! */
                /* This is the only case were we loose, and expand intead of compress. */
                *out++ = escape;
                *out++ = 0;
            }
        }
        i += runLength;
    }
    *lengthOut = (long)(out - outBase);
    assert( *lengthOut <= (long)(lengthIn + minCount + 1) );
    return outBase; /******/
}
#endif /* COMPRESS_ON */

const unsigned char initialState    = 100;
const unsigned char normalState     = 0;
const unsigned char seenEscapeState = 1;
const unsigned char needByteState   = 2;

#ifdef DECOMPRESS_ON

/* Use this method to decompress the data transparantly */
/* as it goes to the memory. */
void MTX_RUNLENGTHCOMP_SaveBytes( register RUNLENGTHCOMP *t, unsigned char value, unsigned char * *dataOutRef, long *dataOutSizeRef, long *indexRef )
{
    register unsigned char *dataOut = *dataOutRef;
    register long dataOutSize = *dataOutSizeRef;
    register long index = *indexRef;
    
    if ( t->state == normalState ) {
        if ( value == t->escape ) {
            t->state = seenEscapeState;
        } else {
            assert( index <= dataOutSize );
            if ( index >=dataOutSize ) {
                dataOutSize += dataOutSize>>1; /* Allocate in exponentially increasing steps */
                dataOut = (unsigned char *)MTX_mem_realloc( t->mem, dataOut, dataOutSize );
            }
            dataOut[ index++ ] = value;
        }
    } else if ( t->state == seenEscapeState ) {
        if ( (t->count = value) == 0 ) {
            assert( index <= dataOutSize );
            if ( index >=dataOutSize ) {
                dataOutSize += dataOutSize>>1; /* Allocate in exponentially increasing steps */
                dataOut = (unsigned char *)MTX_mem_realloc( t->mem, dataOut, dataOutSize );
            }
            dataOut[ index++ ] = t->escape;
            t->state = normalState;
        } else {
            t->state = needByteState;
        }
    } else if ( t->state == needByteState ) {
        register int i;
        
        if ( index + (long)t->count > dataOutSize ) {
            dataOutSize = index + (long)t->count + (dataOutSize>>1); /* Allocate in exponentially increasing steps */
            dataOut = (unsigned char *)MTX_mem_realloc( t->mem, dataOut, dataOutSize );
        }
        /* for ( i = 0; i < t->count; i++ ) */
        for ( i = t->count; i > 0; i-- ) {
            dataOut[ index++ ] = value;
        }
        assert( index <= dataOutSize );
        t->state = normalState;
    } else {
        assert( t->state == initialState );
        t->escape     = value;
        t->state    = normalState;
    }
    *dataOutRef     = dataOut;
    *dataOutSizeRef    = dataOutSize;
    *indexRef         = index;
}


#endif /* DECOMPRESS_ON */

/* Constructor */
RUNLENGTHCOMP *MTX_RUNLENGTHCOMP_Create( MTX_MemHandler *mem  )
{
    RUNLENGTHCOMP *t    = (RUNLENGTHCOMP *)MTX_mem_malloc( mem, sizeof( RUNLENGTHCOMP ) );
    t->mem                = mem;
    t->state             = initialState; /* Initialize */
    return t; /*****/
}


/* Deconstructor */
void MTX_RUNLENGTHCOMP_Destroy( RUNLENGTHCOMP *t )
{
    MTX_mem_free( t->mem, t );
}

/*---- End RUNLENGTHCOMP --- */

