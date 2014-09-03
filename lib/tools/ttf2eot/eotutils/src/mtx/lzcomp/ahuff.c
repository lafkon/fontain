/****************************************************************************************/
/*                                      AHUFF.C                                         */
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
#include "ahuff.h"
#include "mtxmem.h"

/* Returns number of bits used in the positive number x */
long MTX_AHUFF_BitsUsed( register long x )
{
    register long n;

    assert( x >=0 );
    if ( x & 0xffff0000 ) {
        /* 17-32 */
        if ( x & 0xff000000 ) {
            /* 25-32 */
            if ( x & 0xf0000000 ) {
                /* 29-32 */
                if ( x & 0xC0000000 ) {
                    /* 31-32 */
                    n = x & 0x80000000 ? 32 : 31;
                } else {
                    /* 29-30 */
                    n = x & 0x20000000 ? 30 : 29;
                }
            } else {
                /* 25-28 */
                if ( x & 0x0C000000 ) {
                    /* 27-28 */
                    n = x & 0x08000000 ? 28 : 27;
                } else {
                    /* 25-26 */
                    n = x & 0x02000000 ? 26 : 25;
                }
            }
        } else {
            /* 17-24 */
            if ( x & 0x00f00000 ) {
                /* 21-24 */
                if ( x & 0x00C00000 ) {
                    /* 23-24 */
                    n = x & 0x00800000 ? 24 : 23;
                } else {
                    /* 21-22 */
                    n = x & 0x00200000 ? 22 : 21;
                }
            } else {
                /* 17-20 */
                if ( x & 0x000C0000 ) {
                    /* 19-20 */
                    n = x & 0x00080000 ? 20 : 19;
                } else {
                    /* 17-18 */
                    n = x & 0x00020000 ? 18 : 17;
                }
            }
        }
    } else {
        /* 1-16 */
        if ( x & 0xff00 ) {
            /* 9-16 */
            if ( x & 0xf000 ) {
                /* 13-16 */
                if ( x & 0xC000 ) {
                    /* 15-16 */
                    n = x & 0x8000 ? 16 : 15;
                } else {
                    /* 13-14 */
                    n = x & 0x2000 ? 14 : 13;
                }
            } else {
                /* 9-12 */
                if ( x & 0x0C00 ) {
                    /* 11-12 */
                    n = x & 0x0800 ? 12 : 11;
                } else {
                    /* 9-10 */
                    n = x & 0x0200 ? 10 : 9;
                }
            }
        } else {
            /* 1-8 */
            if ( x & 0xf0 ) {
                /* 5-8 */
                if ( x & 0x00C0 ) {
                    /* 7-8 */
                    n = x & 0x0080 ? 8 : 7;
                } else {
                    /* 5-6 */
                    n = x & 0x0020 ? 6 : 5;
                }
            } else {
                /* 1-4 */
                if ( x & 0x000C ) {
                    /* 3-4 */
                    n = x & 0x0008 ? 4 : 3;
                } else {
                    /* 1-2 */
                    n = x & 0x0002 ? 2 : 1;
                }
            }
        }
    }
    return n; /******/
}


#ifdef DEBUG
/* This method does various validity checks on the tree */
/* This is only needed for debugging, but if any changes */
/* are made to the code, then we need to ensure that */
/* this method still accepts the tree. */
static void check_tree( AHUFF *t )
{
    long i, j;
    short a, b, diff;
    register nodeType *tree = t->tree;
    const short ROOT = 1;
    
    /* assert children point to parents */
    for ( i = ROOT; i < t->range; i++ ) {
        if ( tree[i].code < 0 ) {
            if ( tree[tree[i].left].up != i ) {
                /*cout << i << "," << tree[i].left << "," << tree[tree[i].left].up << endl; */ 
#ifndef _WINDOWS
                printf("%ld , %ld , %ld\n", (long)i, (long)tree[i].left, (long)tree[tree[i].left].up );
#endif
            }
            assert( tree[tree[i].left].up == i );
            assert( tree[tree[i].right].up == i );
        
        }
    }
    /* assert weigths sum up */
    for ( i = ROOT; i < t->range; i++ ) {
        if ( tree[i].code < 0 ) {
#ifndef _WINDOWS
            if ( tree[i].weight != tree[tree[i].left].weight + tree[tree[i].right].weight ) {
                /*cout << i << "," << tree[i].left << "," << tree[i].right << endl; */
                printf("%ld , %ld , %ld\n", (long)i, (long)tree[i].left, (long)tree[i].right );
                /*cout << tree[i].weight << "," << tree[tree[i].left].weight << "," << tree[tree[i].right].weight << endl; */
                printf("%ld , %ld , %ld\n", (long)tree[i].weight, (long)tree[tree[i].left].weight, (long)tree[tree[i].right].weight );
            }
#endif
            assert( tree[i].weight == tree[tree[i].left].weight + tree[tree[i].right].weight );
        }
    }
    /* assert everything in decreasing order */
    j = t->range * 2 - 1;
    for ( i = ROOT; i < j; i++ ) {
        assert( tree[i].weight >=tree[i+1].weight );
    }
    /* assert siblings next to each other */
    for ( i = ROOT+1; i < j; i++ ) {
        if ( tree[i].code < 0 ) {
            /* Internal node */
            a   = tree[i].left;
            b   = tree[i].right;
            diff  = (short)(a >=b ? a - b : b - a);
            assert( diff == 1 );
        }
    }
    j = t->range * 2;
    for ( i = ROOT + 1; i < j; i++ ) {
        a = tree[i].up;
        assert( tree[a].left == i || tree[a].right == i );
    }
}
#endif /* DEBUG */


/* Swaps the nodes a and b */
static void SwapNodes( AHUFF *t, register short a, register short b )
{
    short code;
    short upa, upb;
    nodeType tNode;
    register nodeType *tree = t->tree;
    const short ROOT = 1;
    
    assert( a != b );
    assert( a > ROOT );
    assert( b > ROOT );
    assert( a < 2*t->range );
    assert( b < 2*t->range );
    assert( tree[a].code < 0 || t->symbolIndex[ tree[a].code ] == a );
    assert( tree[b].code < 0 || t->symbolIndex[ tree[b].code ] == b );
    
    upa = tree[a].up;
    upb = tree[b].up;
    assert( tree[upa].code < 0 );
    assert( tree[upb].code < 0 );
    
    assert( tree[upa].left == a || tree[upa].right == a );
    assert( tree[upb].left == b || tree[upb].right == b );
    
    assert( tree[a].weight == tree[b].weight );
    #ifdef OLD
        deltaW = -tree[a].weight + tree[b].weight;
        assert( deltaW == 0 );
        tree[upa].weight += deltaW;
        tree[upb].weight -= deltaW;
    #endif
    
    tNode   = tree[a];
    tree[a] = tree[b];
    tree[b] = tNode;
    
    tree[a].up = upa;
    tree[b].up = upb;
    
    code = tree[a].code;
    if ( code < 0 ) {
        /* Internal nodes have children */
        tree[tree[a].left ].up = a;
        tree[tree[a].right].up = a;
    } else {
        assert( code < t->range );
        t->symbolIndex[ code ] = a;
    }
    
    code = tree[b].code;
    if ( code < 0 ) {
        /* Internal nodes have children */
        tree[tree[b].left ].up = b;
        tree[tree[b].right].up = b;
    } else {
        assert( code < t->range );
        t->symbolIndex[ code ] = b;
    }
    assert( tree[upa].left == a || tree[upa].right == a );
    assert( tree[upb].left == b || tree[upb].right == b );
}


/* Updates the weight for index a, and it's parents */
static void UpdateWeight( register AHUFF *t, register short a )
{
    register nodeType *tree = t->tree;
    const short ROOT = 1;
    
    for (; a != ROOT; a = tree[a].up) {
        register long  weightA = tree[a].weight;
        register short b = (short)(a-1);
        /* This if statement prevents sibling rule violations */
        assert( tree[b].weight >=weightA );
        if ( tree[b].weight == weightA ) {
            do {
                b--;
            } while ( tree[b].weight == weightA );
            b++;
            assert( b >=ROOT );
            if ( b > ROOT ) {
                SwapNodes( t, a, b );
                a = b;
            }
        }
        tree[a].weight = ++weightA;
        #ifdef DEBUG
            if ( tree[a].code < 0 ) {
                assert( tree[a].weight == tree[tree[a].left].weight + tree[tree[a].right].weight );
            }
        #endif
    }
    assert( a == ROOT );
    tree[a].weight++;
    assert( tree[a].weight == tree[tree[a].left].weight + tree[tree[a].right].weight );
    /*check_tree(); slooow */
}

/* Recursively sets the parent weight equal to the sum of the two chilren's weights. */
static long init_weight(AHUFF *t, int a)
{
    register nodeType *tree = t->tree;
    if ( tree[a].code < 0 ) {
        /* Internal node */
        tree[a].weight = init_weight(t, tree[a].left) + init_weight(t, tree[a].right);
    }
    return tree[a].weight; /*****/
}

#ifdef OLD
/* Maps a symbol code into the corresponding index */
static short MapCodeToIndex( AHUFF *t, register short code )
{
    register short index = t->symbolIndex[ code ];
    assert( t->tree[index].code == code );
    
    return index; /*****/
}
#endif /* OLD */

/* Currently we never rescale the tables */
/* const short MAXWEIGHT = 30000; Max weight count before table reset */

/* Constructor */
AHUFF *MTX_AHUFF_Create( MTX_MemHandler *mem, BITIO *bio, short rangeIn ) 
{
    short i, limit, range;
    long j;
    const short ROOT = 1;
    
    AHUFF *t    = (AHUFF *)MTX_mem_malloc( mem, sizeof( AHUFF ) );
    t->mem        = mem;
    
    t->bio                = bio;
    range                = rangeIn;
    t->range            = rangeIn;
    t->bitCount            = MTX_AHUFF_BitsUsed( rangeIn - 1 );
    t->bitCount2        = 0;
    if ( rangeIn > 256 && rangeIn < 512 ) {
        rangeIn -= 256;
        t->bitCount2 = MTX_AHUFF_BitsUsed( rangeIn - 1 );
        t->bitCount2++;
    }

    /*assert( range == range ); */
    /* Max possible symbol == range - 1; */
    t->maxSymbol = range - 1;
    
    t->sym_count = 0;
    t->countA = t->countB = 100;
    /*t->symbolIndex = new short[ range ]; */
    t->symbolIndex = ( short *)MTX_mem_malloc( mem, sizeof(short) * range );
    /*t->tree  = new nodeType [ 2*range ]; */
    t->tree  = (nodeType *)MTX_mem_malloc( mem, sizeof(nodeType) * 2*range );

    /* Initialize the Huffman tree */

    limit = (short)((short)2 * (short)range);
    for ( i = 2; i < limit; i++ ) {
        t->tree[i].up = (short)((short)i/(short)2);
        t->tree[i].weight = (short)1;
    }
    for ( i = 1; i < range; i++ ) {
        t->tree[i].left  = (short)(2*i);
        t->tree[i].right = (short)(2*i+1);
    }
    for ( i = 0; i < range; i++ ) {
        t->tree[i].code            = -1;
        t->tree[range+i].code    = i;
        t->tree[range+i].left    = -1;
        t->tree[range+i].right    = -1;
        t->symbolIndex[i]        = (short)(range+i);
    }
    

    init_weight( t, ROOT );
#if defined(DEBUG)
    check_tree(t);
#endif
    
    if ( t->bitCount2 != 0 ) {
        /*assert( range == 256 + (1 << (t->bitCount2-1)) ); */
        UpdateWeight(t, t->symbolIndex[256]);
        UpdateWeight(t, t->symbolIndex[257]);
        /*UpdateWeight(t->symbolIndex[258]); */
        assert( 258 < range );
#if defined(DEBUG)
        check_tree( t );
#endif
        /* DUP2 */
        for ( i = 0; i < 12; i++ ) {
            UpdateWeight(t, t->symbolIndex[range-3]);
        }
        /* DUP4 */
        for ( i = 0; i < 6; i++ ) {
            UpdateWeight(t, t->symbolIndex[range-2]);
        }
        /* DUP6 range-1 */
    } else {
        for ( j = 0; j < 2; j++ ) {
            for ( i = 0; i < range; i++ ) {
                UpdateWeight(t, t->symbolIndex[i]);
            }
        }
    }
    t->countA = t->countB = 0;
    return t;/*****/
}

/* Deconstructor */
void MTX_AHUFF_Destroy( AHUFF *t )
{
    MTX_mem_free( t->mem, t->symbolIndex );
    MTX_mem_free( t->mem, t->tree );
    MTX_mem_free( t->mem, t );
}


/* Writes the symbol to the file using adaptive Huffman encoding */
/* Jusat like but with writeToFile == false assumed */
long MTX_AHUFF_WriteSymbolCost( AHUFF *t, short symbol )
{
    register nodeType *tree = t->tree;
    register short a;
    register int sp = 0;
    const short ROOT = 1;
    
    /* The array maps the symbol code into an index */
    a = t->symbolIndex[symbol];
    assert( t->tree[a].code == symbol );

    do {
        sp++;
        a = tree[a].up;
    } while (a != ROOT);
    return (long)sp << 16; /******/
}


/* Writes the symbol to the file using adaptive Huffman encoding */
void MTX_AHUFF_WriteSymbol( AHUFF *t, short symbol )
{
    register nodeType *tree = t->tree;
    register short a, aa;
    register int sp = 0;
    char stackArr[50]; /* use this to reverse the bits */
    register char *stack = stackArr;
    register BITIO *bio = t->bio;
    register short up; 
    const short ROOT = 1;
    
    /* The array maps the symbol code into an index */
    a = t->symbolIndex[symbol];
    assert( t->tree[a].code == symbol );
    aa = a;


    do {
        up = tree[a].up;
        stack[sp++] = (char)(tree[up].right == a);
        a = up;
    } while (a != ROOT);
    assert( sp < 50 );
    do {
        MTX_BITIO_output_bit( bio, stack[--sp] );
    } while (sp);
    UpdateWeight( t, aa );
}

/* Reads the symbol from the file */
short MTX_AHUFF_ReadSymbol( AHUFF *t )
{
    const short ROOT = 1;
    register nodeType *tree = t->tree;
    register short a = ROOT, symbol;
    register BITIO *bio = t->bio;

    do {
        a = (short)(MTX_BITIO_input_bit( bio ) ? tree[a].right : tree[a].left);
        symbol = tree[a].code;
    } while ( symbol < 0 );
    UpdateWeight( t, a );
    return symbol; /******/
}


