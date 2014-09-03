#pragma once
#ifndef __MTX_H
#define __MTX_H

#pragma pack(push, 1)

typedef struct {
    unsigned version  : 8;
    unsigned distance : 24;
    unsigned dataoffset : 24;
    unsigned codeoffset : 24;
} mtx_header_t;

#pragma pack(pop)

typedef struct {
    mtx_header_t head;
    uint8_t *rest;
    uint8_t *data;
    uint8_t *code;
    size_t restsize;
    size_t datasize;
    size_t codesize;
    size_t totalsize;
} mtx_t;

bool mtx_init(mtx_t **state, const uint8_t *data, size_t size);
bool mtx_dump(mtx_t *state);
bool mtx_getCTF(mtx_t *state, uint8_t **data, size_t *size);
bool mtx_fini(mtx_t *state);

#else
# warning mtx.h included twice
#endif
