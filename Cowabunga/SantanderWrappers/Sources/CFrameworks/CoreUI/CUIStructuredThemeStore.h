//
//  CUIStructuredThemeStore.h
//  Santander
//
//  Created by Serena on 26/09/2022
//
	

#ifndef CUIStructuredThemeStore_h
#define CUIStructuredThemeStore_h
#include "CUIThemeRendition.h"

@interface CUIStructuredThemeStore : NSObject
- (NSData *)convertRenditionKeyToKeyData:(const struct renditionkeytoken *)arg1;
@end

#endif /* CUIStructuredThemeStore_h */
