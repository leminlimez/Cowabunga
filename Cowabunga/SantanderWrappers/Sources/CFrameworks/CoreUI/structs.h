//
//  structs.h
//  Santander
//
//  Created by Serena on 27/09/2022
//
	

#ifndef structs_h
#define structs_h

struct renditionkeytoken {
    unsigned short identifier;
    unsigned short value;
};

struct rgbquad {
    unsigned int b:8;
    unsigned int g:8;
    unsigned int r:8;
    unsigned int a:8;
};

struct cuithemerenditionrenditionflags {
    unsigned int isHeaderFlaggedFPO:1;
    unsigned int isExcludedFromContrastFilter:1;
    unsigned int isVectorBased:1;
    unsigned int isOpaque:1;
    unsigned int bitmapEncoding:4;
    unsigned int optOutOfThinning:1;
    unsigned int isFlippable:1;
    unsigned int isTintable:1;
    unsigned int preservedVectorRepresentation:1;
    unsigned int reserved:20;
};

#endif /* structs_h */
