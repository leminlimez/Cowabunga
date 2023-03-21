//
//  CUIThemeRendition.h
//  Santander
//
//  Created by Serena on 16/09/2022
//


#ifndef CUIThemeRendition_h
#define CUIThemeRendition_h

#define HAS_CORE_SVG __has_include("../CoreSVG/CoreSVG.h")

@import CoreGraphics;

#include "structs.h"
#include "CUIRenditionKey.h"

#if HAS_CORE_SVG
#   include "../CoreSVG/CoreSVG.h"
#endif

#pragma clang diagnostic push
// for the `Pointer is missing a nullability type specifier` warnings:
#pragma clang diagnostic ignored "-Wnullability-completeness"
@interface CUIThemeRendition : NSObject
@property(nonatomic) long long type;
@property(nonatomic) unsigned int subtype;
@property(nonatomic) int blendMode;
@property(nonatomic) int exifOrientation;
@property(nonatomic) double opacity;
@property(readonly, nonatomic) NSData *srcData;
//@property (nonatomic) NSInteger type;

- (struct renditionkeytoken *)key;
- (NSString * _Nonnull)name;
- (unsigned long long)colorSpaceID;
- (double)scale;
- (long long)templateRenderingMode;
- (NSString * _Nullable)utiType;
- (bool)isHeaderFlaggedFPO;
- (struct cuithemerenditionrenditionflags *)renditionFlags;
- (bool)isVectorBased;
- (int)pixelFormat;
- (bool)isInternalLink;
- (CUIRenditionKey *)linkingToRendition;
#if HAS_CORE_SVG
- (CGSVGDocumentRef)svgDocument;
#endif
- (struct CGRect)_destinationFrame;
- (CGImageRef _Nullable)uncroppedImage;
- (CGImageRef _Nullable)unslicedImage;
- (CGColorRef)cgColor;
- (bool)substituteWithSystemColor;
- (NSString *)systemColorName;
- (CGImageRef)createImageFromPDFRenditionWithScale:(double)arg1;
- (CGPDFDocumentRef)pdfDocument;
- (struct CGRect)_destinationFrame;
- (struct CGSize)unslicedSize;
- (_Nonnull id)initWithCSIData:(NSData *)arg1 forKey:(const struct renditionkeytoken *)arg2;
@end


@interface _CUIThemeSVGRendition : CUIThemeRendition
- (NSData *)rawData;
@end


@interface _CUIRawDataRendition : CUIThemeRendition
- (id)data;
@end

#pragma clang diagnostic pop

#endif /* CUIThemeRendition_h */
