//
//  CUINamedLookup.h
//  Santander
//
//  Created by Serena on 16/09/2022
//
	

#ifndef CUINamedLookup_h
#define CUINamedLookup_h
#include "CUIThemeRendition.h"

NS_ASSUME_NONNULL_BEGIN
@interface CUINamedLookup : NSObject
@property (copy, nonatomic) NSString *name;
@property (readonly, nonatomic) NSString *renditionName;
@property (readonly, nonatomic) NSString *appearance;
@property (readonly, nonatomic, getter=_rendition) CUIThemeRendition *rendition;
@property (copy, nonatomic) CUIRenditionKey *key;
@property (nonatomic) NSUInteger storageRef;
@end

NS_ASSUME_NONNULL_END
#endif /* CUINamedLookup_h */
