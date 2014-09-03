#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>
#include <assert.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <iconv.h>

#include "embeddedfont.h"
#include "properties.h"
#include "libeot.h"

#define dprintf(x, y...) 
// fprintf(stderr, "DEBUG: " x "\n", y)
#define eprintf(x, y...)

typedef enum { EOTDATALEN_SHORT = 16, EOTDATALEN_LONG = 32 } eotdatalen_t;

// Convert an EOT UTF-16 string to UTF-8, easier to manage.
static bool eot_toutf8(char *in, size_t insz, char *out, size_t outsz)
{
    static iconv_t cd;

    void __attribute__((constructor)) init()
    {
        cd = iconv_open("UTF-8", "UTF-16");
    }

    void __attribute__((destructor)) fini()
    {
        iconv_close(cd);
    }

    return iconv(cd, &in, &insz, &out, &outsz) != (size_t)(-1);
}

static bool eot_decrypt(uint8_t *data, size_t len)
{
    const uint8_t kKey = 0x50;
    while (len--) 
        data[len] ^= kKey;
    return true;
}

static uint32_t eot_checksum(const uint8_t *data, size_t len)
{
    const uint32_t kCsXorKey = 0x50475342;
    uint32_t i, checksum = 0;

    dprintf("called eot_checksum(%p, %u);", data, len);

    for (i = 0; i < len; i++)
        checksum += data[i];

    return checksum ^ kCsXorKey;
}

static bool eot_readeotdata(eot_t *state,
                            eotdata_t **dest,
                            eotdatalen_t len,
                            const char *tag)
{
    uint16_t size_s;
    uint32_t size_l;
    uint16_t padding;
    ssize_t read;
    uint32_t i;
    eotdata_t *data;

    assert(state);
    assert(state->head.MagicNumber == EOTMAGICNUMBER);
    assert(dest);

    dprintf("called eot_readdata(%p, %p, %d, %s);", state, dest, len, tag);

    *dest = NULL;

    data = malloc(sizeof(eotdata_t));

    if (data == NULL) {
        eprintf("memory allocation failure");
        return false;
    }

    // Read the size from the input data
    switch (len) {
        case EOTDATALEN_SHORT:

            // Short data begins with 2 bytes of alignment padding
            read = state->read(state->userval, &padding, sizeof(padding));

            if (read != sizeof(padding)) {
                eprintf("unable to read padding '%s', file truncated?", tag);
                free(data);
                return false;
            }

            // EOT S3.1/3.2/3.3 Padding value MUST always be set to 0x0000.
            if (padding != 0x0000) {
                // Try to continue, but print a warning
                dprintf("illegal padding %#04hx, file may be corrupt", padding);
            }

            read = state->read(state->userval, &size_s, sizeof(size_s));

            if (read != sizeof(size_s)) {
                eprintf("unable to read size of '%s', file truncated?");
                free(data);
                return false;
            }

            data->size = size_s;
            break;
        case EOTDATALEN_LONG:
            read = state->read(state->userval, &size_l, sizeof(size_l));

            if (read != sizeof(size_l)) {
                eprintf("unable to read size of '%s', file truncated?", tag);
                return false;
            }

            data->size = size_l;
            break;
        default:
            eprintf("invalid datasize specified, %d", len);
            free(data);
            assert(false);
            return false;
    }

    dprintf("data '%s' is %u bytes", tag, data->size);

    // Read the Data
    data->data = malloc(data->size);

    if (data->data == NULL) {
        dprintf("memory allocation of %u bytes failed", data->size);
        free(data);
        return false;
    }

    read = state->read(state->userval, data->data, data->size);

    if (read != data->size) {
        eprintf("unable to read '%s', file truncated?", tag);
        free(data->data);
        free(data);
        return false;
    }

    // Only tag 'RootString' in EOT 2.2 has a checksum, but to 
    // simplify the code I always calculate it.
    data->checksum = eot_checksum(data->data, data->size);

    // I don't care if this fails, the tag is mainly for debugging.
    data->tag = strdup(tag);

    *dest = data;

    return true;
}

bool eot_init(eot_t **state, eotread_t read, intptr_t userval)
{
    eot_t eot = {0};

    assert(read);
    assert(state);
    
    eot.read = read;
    eot.userval = userval;

    if (eot.read(userval, &eot.head, sizeof(eot.head)) != sizeof(eot.head)) {
        eprintf("unable to read eot head, file may be truncated");
        return false;
    }

    if (eot.head.MagicNumber != EOTMAGICNUMBER) {
        eprintf("eot magic is invalid, file corrupt or not an eot file?");
        return false;
    }

    // Read Strings
    eot_readeotdata(&eot, &eot.family, EOTDATALEN_SHORT, "Family Name");
    eot_readeotdata(&eot, &eot.style, EOTDATALEN_SHORT, "Style Name");
    eot_readeotdata(&eot, &eot.version, EOTDATALEN_SHORT, "Version Name");
    eot_readeotdata(&eot, &eot.fullname, EOTDATALEN_SHORT, "Full Name");
    eot_readeotdata(&eot, &eot.rootstring, EOTDATALEN_SHORT, "Root Strings");

    // Read RootStringChecksum
    if (eot.read(userval, &eot.rootchecksum, sizeof(eot.rootchecksum)) 
            != sizeof(eot.rootchecksum)) {
        eprintf("unable to read checksum, file truncated?");
        return false;
    }

    // Read EUDCCodePage
    if (eot.read(userval, &eot.eudccodepage, sizeof(eot.eudccodepage)) 
            != sizeof(eot.eudccodepage)) {
        eprintf("unable to read eudc codepage, file truncated?");
        return false;
    }

    // Read Signature
    eot_readeotdata(&eot, &eot.signature, EOTDATALEN_SHORT, "Signature");

    // Read EUDCFlags
    if (eot.read(userval, &eot.eudcflags, sizeof(eot.eudcflags)) 
            != sizeof(eot.eudcflags)) {
        eprintf("unable to read eudc flags, file truncated?");
        return false;
    }

    // Read EUDCFontData
    eot_readeotdata(&eot, &eot.eudcdata, EOTDATALEN_LONG, "EUDC Data");

    if ((*state = malloc(sizeof(**state))) == NULL) {
        eprintf("memory allocation failure");
        return false;
    }

    eot.fontdata = malloc(eot.head.FontDataSize);
    if (eot.read(userval, eot.fontdata, eot.head.FontDataSize) != eot.head.FontDataSize) {
        abort();
    }

    if (eot.head.Flags & TTEMBED_XORENCRYPTDATA)
        eot_decrypt(eot.fontdata, eot.head.FontDataSize);

    memcpy(*state, &eot, sizeof(eot));

    return true;
}

#if 0
bool eotvalidate(eot_t *state);
{
    CHECK(state->head.EOTSize, "The filesize specified is incorrect");
    CHECK(state->head.FontDataSize < state->head.EOTSize,
        "The FontDataSize specified is incorrect");
    CHECK(state->head.EOTSize == filesize,
        "The file is truncated or corrupt");
    CHECK(version recognised)
    CHECK(unknown flag set)
    CHECK(TTEMBED_EMBEDEUDC only set for version 2.1)
    CHECK(TTEMBED_XORENCRYPTDATA is set - this is a waste of time)
    CHECK(TTEMBED_FAILIFVARIATIONSIMULATED is set - unnescessary burden)
    CHECK(if font is symbol charset, first byte of panose must be pictorial)
    CHECK(bFamilyType, bSerifStyle and bProportion are set and sane);
    CHECK(first three bits of fstype are exclusive (warning))
    CHECK(reserved bits of fstype are unset);
    CHECK(unicode and codepage ranges look sane);
    CHECK(reserved and padding strings are 0);
    CHECK(checksum matches);
    CHECK(version is accurante);
    CHECK(appended data);
}
#endif

bool eot_dump(eot_t *state)
{
    char string[8192];
    size_t i, offset, size;

    memset(string, 0x00, sizeof(string));

    fprintf(stdout, "Total Size %u, Font Data Size %u\n",
        state->head.EOTSize,
        state->head.FontDataSize);
    fprintf(stdout, "EOT Version %u.%u\n",
        state->head.Version.Major,
        state->head.Version.Minor);
    fprintf(stdout, "Flags: %#x\n", state->head.Flags);

    if (state->head.Flags & TTEMBED_SUBSET)
        fprintf(stdout, "\tTTEMBED_SUBSET\n");
    if (state->head.Flags & TTEMBED_TTCOMPRESSED)
        fprintf(stdout, "\tTTEMBED_TTCOMPRESSED\n");
    if (state->head.Flags & TTEMBED_FAILIFVARIATIONSIMULATED)
        fprintf(stdout, "\tTTEMBED_FAILIFVARIATIONSIMULATED\n");
    if (state->head.Flags & TTMBED_EMBEDEUDC)
        fprintf(stdout, "\tTTMBED_EMBEDEUDC\n");
    if (state->head.Flags & TTEMBED_VALIDATIONTESTS)
        fprintf(stdout, "\tTTEMBED_VALIDATIONTESTS (Deprecated)\n");
    if (state->head.Flags & TTEMBED_WEBOBJECT)
        fprintf(stdout, "\tTTEMBED_WEBOBJECT\n");
    if (state->head.Flags & TTEMBED_XORENCRYPTDATA)
        fprintf(stdout, "\tTTEMBED_XORENCRYPTDATA\n");

    if (state->head.Flags & ~TTEMBED_FLAGSMASK)
    {
        fprintf(stdout, "\tUnknown Flags: %#x",
            state->head.Flags & ~TTEMBED_FLAGSMASK);
    }

    fprintf(stdout, "PANOSE Classification Numbers:\n"
        "\tbFamilyType      %02hhx\n"
        "\tbSerifStyle      %02hhx\n"
        "\tbWeight          %02hhx\n"
        "\tbProportion      %02hhx\n"
        "\tbContrast        %02hhx\n"
        "\tbStrokeVariation %02hhx\n"
        "\tbArmStyle        %02hhx\n"
        "\tbLetterform      %02hhx\n"
        "\tbMidline         %02hhx\n"
        "\tbXHeight         %02hhx\n",
            state->head.FontPANOSE[0],
            state->head.FontPANOSE[1],
            state->head.FontPANOSE[2],
            state->head.FontPANOSE[3],
            state->head.FontPANOSE[4],
            state->head.FontPANOSE[5],
            state->head.FontPANOSE[6],
            state->head.FontPANOSE[7],
            state->head.FontPANOSE[8],
            state->head.FontPANOSE[9]);
    
    fprintf(stdout, "Font is %s Charset (%u), %sItalic, %s (%u) Weight\n",
        charset2str(state->head.Charset),
        state->head.Charset,
        state->head.Italic ? "" : "Non-",
        weight2str(state->head.Weight),
        state->head.Weight);

    fprintf(stdout, "Font Embedding Level Flags: %#x\n",
        state->head.fsType);

    if (state->head.fsType == LEVEL_INSTALLABLE)
        fprintf(stdout, "\tInstallable Embedding\n");
    if (state->head.fsType & LEVEL_RESTRICTED)
        fprintf(stdout, "\tRestricted License embedding\n");
    if (state->head.fsType & LEVEL_PREVIEWPRINT)
        fprintf(stdout, "\tPreview & Print embedding\n");
    if (state->head.fsType & LEVEL_EDITABLE)
        fprintf(stdout, "\tEditable embedding\n");
    if (state->head.fsType & LEVEL_NOSUBSETTING)
        fprintf(stdout, "\tNo subsetting\n");
    if (state->head.fsType & LEVEL_BITMAPONLY)
        fprintf(stdout, "\tBitmap embedding only\n");
    if (state->head.fsType & 1)
        fprintf(stdout, "\tUndocumented flag! (Secret Microsoft Setting?)\n");

    fprintf(stdout, "Magic Number: %#hx (%s)\n", state->head.MagicNumber,
        state->head.MagicNumber == EOTMAGICNUMBER ? "Correct" : "Incorrect");

    fprintf(stdout, "UnicodeRange:\n\t0x%08x%08x%08x%08x\n",
        state->head.UnicodeRange1,
        state->head.UnicodeRange2,
        state->head.UnicodeRange3,
        state->head.UnicodeRange4);
    fprintf(stdout, "CodePageRange:\n\t0x%08x%08x\n",
        state->head.CodePageRange1,
        state->head.CodePageRange2);

    fprintf(stdout, "CheckSumAdjustment: %#x\n",
        state->head.CheckSumAdjustment);

    eot_toutf8(state->family->data,
               state->family->size,
               string,
               sizeof(string));

    fprintf(stdout, "FamilyName: %u bytes, %s\n", state->family->size, string);
    
    eot_toutf8(state->style->data,
               state->style->size,
               string,
               sizeof(string));
    
    fprintf(stdout, "StyleName: %u bytes, %s\n", state->style->size, string);
    
    eot_toutf8(state->version->data,
               state->version->size,
               string,
               sizeof(string));

    fprintf(stdout,
            "VersionName: %u bytes, %s\n",
            state->version->size, 
            string);
    
    eot_toutf8(state->fullname->data,
               state->fullname->size,
               string,
               sizeof(string));

    fprintf(stdout,
            "FullName: %u bytes, %s\n",
            state->fullname->size,
            string);

    fprintf(stdout,
            "RootStrings: %u bytes (checksum: %#x)\n",
            state->rootstring->size,
            state->rootstring->checksum);

    for (offset = 0; offset < state->rootstring->size;) {
        eot_toutf8(state->rootstring->data + offset,
                   state->rootstring->size - offset,
                   string,
                   sizeof(string));
        fprintf(stdout, "\t@%u %s\n", offset, string);
        offset += (strlen(string) + 1) * 2;
    }

    fprintf(stdout, "EUDCFlags: %#x\n", state->eudcflags);
    
    if (state->eudcflags & TTEMBED_SUBSET)
        fprintf(stdout, "\tTTEMBED_SUBSET\n");
    if (state->eudcflags & TTEMBED_TTCOMPRESSED)
        fprintf(stdout, "\tTTEMBED_TTCOMPRESSED\n");
    if (state->eudcflags & TTEMBED_FAILIFVARIATIONSIMULATED)
        fprintf(stdout, "\tTTEMBED_FAILIFVARIATIONSIMULATED\n");
    if (state->eudcflags & TTMBED_EMBEDEUDC)
        fprintf(stdout, "\tTTMBED_EMBEDEUDC\n");
    if (state->eudcflags & TTEMBED_VALIDATIONTESTS)
        fprintf(stdout, "\tTTEMBED_VALIDATIONTESTS (Deprecated)\n");
    if (state->eudcflags & TTEMBED_WEBOBJECT)
        fprintf(stdout, "\tTTEMBED_WEBOBJECT\n");
    if (state->eudcflags & TTEMBED_XORENCRYPTDATA)
        fprintf(stdout, "\tTTEMBED_XORENCRYPTDATA\n");

    fprintf(stdout, "EUDCData: %u bytes\n", state->eudcdata->size);
    return true;
}

bool eot_fini(eot_t *state)
{
    assert(state);
    assert(state->head.MagicNumber == EOTMAGICNUMBER);
    
    if (state->family) {
        free(state->family->data);
        free(state->family);
    }

    free(state);
    return true;
}
