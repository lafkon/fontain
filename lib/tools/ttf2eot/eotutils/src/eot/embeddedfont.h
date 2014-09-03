#pragma once
#ifndef __EMBEDDEDFONT_H
#define __EMBEDDEDFONT_H

#define EOTMAGICNUMBER 0x504C

#define TTEMBED_SUBSET                     0x00000001
#define TTEMBED_TTCOMPRESSED               0x00000004
#define TTEMBED_FAILIFVARIATIONSIMULATED   0x00000010
#define TTMBED_EMBEDEUDC                   0x00000020
#define TTEMBED_VALIDATIONTESTS            0x00000040 // Deprecated
#define TTEMBED_WEBOBJECT                  0x00000080
#define TTEMBED_XORENCRYPTDATA             0x10000000

#define TTEMBED_FLAGSMASK (TTEMBED_SUBSET \
                                | TTEMBED_TTCOMPRESSED \
                                | TTEMBED_FAILIFVARIATIONSIMULATED \
                                | TTMBED_EMBEDEUDC \
                                | TTEMBED_VALIDATIONTESTS \
                                | TTEMBED_WEBOBJECT \
                                | TTEMBED_XORENCRYPTDATA)

#pragma pack(push, 1)

typedef struct {
    uint32_t EOTSize;
    uint32_t FontDataSize;
    struct {
        uint16_t Major;
        uint16_t Minor;
    } Version;
    uint32_t Flags;
    uint8_t FontPANOSE[10];
    uint8_t Charset;
    uint8_t Italic;
    uint32_t Weight;
    uint16_t fsType;
    uint16_t MagicNumber;
    uint32_t UnicodeRange1;
    uint32_t UnicodeRange2;
    uint32_t UnicodeRange3;
    uint32_t UnicodeRange4;
    uint32_t CodePageRange1;
    uint32_t CodePageRange2;
    uint32_t CheckSumAdjustment;
    uint32_t Reserved1;
    uint32_t Reserved2;
    uint32_t Reserved3;
    uint32_t Reserved4;
} eotheader_t;

typedef struct {
    uint32_t size;
    uint32_t checksum;
    uint8_t *data;
    char *tag;
} eotdata_t;

#pragma pack(pop)

#else
# warning embeddefont.h included twice
#endif
