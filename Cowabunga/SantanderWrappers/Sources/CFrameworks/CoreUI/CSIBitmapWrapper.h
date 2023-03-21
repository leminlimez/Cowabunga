//
//  CSIBitmapWrapper.h
//  Santander
//
//  Created by Serena on 28/09/2022
//
	

#ifndef CSIBitmapWrapper_h
#define CSIBitmapWrapper_h
@import CoreGraphics.CGContext;

@interface CSIBitmapWrapper : NSObject
- (CGContextRef *)bitmapContext;
- (id)initWithPixelWidth:(unsigned int)arg1 pixelHeight:(unsigned int)arg2;
@end

#endif /* CSIBitmapWrapper_h */
