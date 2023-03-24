//
//  CUIRenditionKey.h
//  Santander
//
//  Created by Serena on 29/09/2022
//
	

#ifndef CUIRenditionKey_h
#define CUIRenditionKey_h
@import Foundation;

@interface CUIRenditionKey : NSObject <NSCopying, NSCoding>
- (const struct renditionkeytoken *)keyList;
- (id)initWithKeyList:(const struct renditionkeytoken *)keyList;

@property(nonatomic) long long themeElement;
@property(nonatomic) long long themePart;
@property(nonatomic) long long themeSize;
@property(nonatomic) long long themeDirection;
@property(nonatomic) long long themeValue;
@property(nonatomic) long long themeAppearance;
@property(nonatomic) long long themeDimension1;
@property(nonatomic) long long themeDimension2;
@property(nonatomic) long long themeState;
@property(nonatomic) long long themeLayer;
@property(nonatomic) long long themeScale;
@property(nonatomic) long long themeLocalization;
@property(nonatomic) long long themePresentationState;
@property(nonatomic) long long themeIdiom;
@property(nonatomic) long long themeSubtype;
@property(nonatomic) long long themeIdentifier;
@property(nonatomic) long long themePreviousState;
@property(nonatomic) long long themePreviousValue;
@property(nonatomic) long long themeSizeClassHorizontal;
@property(nonatomic) long long themeSizeClassVertical;
@property(nonatomic) long long themeMemoryClass;
@property(nonatomic) long long themeGraphicsClass;
@property(nonatomic) long long themeDisplayGamut;
@property(nonatomic) long long themeDeploymentTarget;
@property(nonatomic) long long themeGlyphWeight;
@property(nonatomic) long long themeGlyphSize;

@end

#endif /* CUIRenditionKey_h */
