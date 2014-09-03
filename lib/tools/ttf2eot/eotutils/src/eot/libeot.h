#pragma once
#ifndef __LIBEOT_H
#define __LIBEOT_H

typedef ssize_t (*eotread_t)(intptr_t, void *, size_t);

typedef struct {
    eotread_t read;
    intptr_t userval;
    eotheader_t head;
    eotdata_t *family;
    eotdata_t *style;
    eotdata_t *version;
    eotdata_t *fullname;
    eotdata_t *rootstring;
    eotdata_t *signature;
    eotdata_t *eudcdata;
    uint32_t eudcflags;
    uint32_t eudccodepage;
    uint32_t rootchecksum;
    uint8_t *fontdata;
} eot_t;

bool eotinit(eot_t **state, eotread_t read, intptr_t user);
bool eotfini(eot_t *state);

#else
# warning libeot.h included twice
#endif
