#include <stdint.h>

#include "properties.h"

const char * charset2str(uint16_t charset)
{
    switch (charset) {
        case ANSI_CHARSET:
            return "ANSI";
        case DEFAULT_CHARSET:
            return "Default";
        case SYMBOL_CHARSET:
            return "Symbol";
        case SHIFTJIS_CHARSET:
            return "Shift-JIS";
        case HANGUL_CHARSET:
            return "Hangul";
        case GB2312_CHARSET:
            return "GB2312";
        case CHINESEBIG5_CHARSET:
            return "Big5";
        case GREEK_CHARSET:
            return "Greek";
        case TURKISH_CHARSET:
            return "Turkish";
        case HEBREW_CHARSET:
            return "Hebrew";
        case ARABIC_CHARSET:
            return "Arabic";
        case BALTIC_CHARSET:
            return "Baltic";
        case RUSSIAN_CHARSET:
            return "Russian";
        case THAI_CHARSET:
            return "Thai";
        case EASTEUROPE_CHARSET:
            return "Eastern European";
        case OEM_CHARSET:
            return "OEM";
        case JOHAB_CHARSET:
            return "Johab (Korean)";
        case VIETNAMESE_CHARSET:
            return "Vietnamese";
        case MAC_CHARSET:
            return "Mac";
    }
    return "Unrecognised Charset";
}

const char * weight2str(uint16_t weight)
{
    switch (weight) {
        case FW_DONTCARE:
            return "Unspecified";
        case FW_THIN:
            return "Thin";
        case FW_EXTRALIGHT:
            return "Extra-light (Ultra-light)";
        case FW_LIGHT:
            return "Light";
        case FW_NORMAL:
            return "Normal (Regular)";
        case FW_MEDIUM:
            return "Medium";
        case FW_SEMIBOLD:
            return "Semi-bold (Demi-bold)";
        case FW_BOLD:
            return "Bold";
        case FW_EXTRABOLD:
            return "Extra-bold (Ultra-bold)";
        case FW_HEAVY:
            return "Black (Heavy)";
    }
    return "Unknown Weight";
}

