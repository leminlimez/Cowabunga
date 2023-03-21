//
//  CSIGenerator.h
//  Santander
//
//  Created by Serena on 28/09/2022
//
	

#ifndef CSIGenerator_h
#define CSIGenerator_h
@import Foundation;
#include "CSIBitmapWrapper.h"

@interface CSIGenerator : NSObject
@property (nonnull, copy, nonatomic) NSString *name;
@property (nonatomic) int blendMode;
@property (nonatomic) short colorSpaceID;
@property (nonatomic) int exifOrientation;
@property (nonatomic) double opacity;
@property (nonatomic) unsigned int scaleFactor;
@property (nonatomic) long long templateRenderingMode;
@property (nullable, copy, nonatomic) NSString *utiType;
@property (nullable, copy, nonatomic) NSArray *colorComponents;
@property (nonatomic) bool isRenditionFPO;
@property (nonatomic, getter=isExcludedFromContrastFilter) bool excludedFromContrastFilter;
@property (nonatomic) bool isVectorBased;
- (void)addBitmap:(CSIBitmapWrapper * _Nonnull)arg1;
- (void)addSliceRect:(struct CGRect)arg1;
- (NSData * _Null_unspecified)CSIRepresentationWithCompression:(bool)arg1;
- (id _Nullable)initWithCanvasSize:(struct CGSize)arg1 sliceCount:(unsigned int)arg2 layout:(short)arg3;
- (id)initWithColorNamed:(id)arg0 colorSpaceID:(NSUInteger)arg1 components:(id)arg2 ;
@end


#endif /* CSIGenerator_h */
