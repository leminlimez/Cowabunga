//
//  CoreSVG.h
//  
//
//  Created by Serena on 29/10/2022
//
	

#define HAS_UIKIT __has_include(<UIKit/UIKit.h>)

#if HAS_UIKIT
@import UIKit.UIImage;
#else
@import CoreGraphics;
#endif

#ifndef CoreSVG_h
#define CoreSVG_h

struct CGSVGDocument;

typedef struct CGSVGDocument *CGSVGDocumentRef;

CGSVGDocumentRef CGSVGDocumentCreateFromData(CFDataRef, CFDictionaryRef);
CGSVGDocumentRef CGSVGDocumentRetain(struct CGSVGDocument);

CGSize CGSVGDocumentGetCanvasSize(CGSVGDocumentRef);

void CGSVGDocumentRelease(CGSVGDocumentRef);
void CGContextDrawSVGDocument(CGContextRef, CGSVGDocumentRef);

int CGSVGDocumentWriteToURL(CGSVGDocumentRef, CFURLRef, CFDictionaryRef);
int CGSVGDocumentWriteToData(CGSVGDocumentRef, CFDataRef, CFDictionaryRef);

#if HAS_UIKIT
// UIImage init from a SVG doc
@interface UIImage (CoreSVGPrivate)
+(instancetype)_imageWithCGSVGDocument:(struct CGSVGDocument *)arg0 NS_SWIFT_NAME(init(svgDocument:));
+(instancetype)_imageWithCGSVGDocument:(struct CGSVGDocument *)arg0 scale:(CGFloat)arg1 orientation:(UIImageOrientation)arg2
NS_SWIFT_NAME(init(svgDocument:scale:orientation:));
@end
#endif

#endif /* CoreSVG_h */
