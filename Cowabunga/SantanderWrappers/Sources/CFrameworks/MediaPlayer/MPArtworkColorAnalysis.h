//
//  MPArtworkColorAnalysis.h
//  
//
//  Created by Serena on 09/11/2022
//
	

#ifndef MPArtworkColorAnalysis_h
#define MPArtworkColorAnalysis_h

#if __has_include(<UIKit/UIKit.h>)
@import UIKit;

@interface MPArtworkColorAnalysis : NSObject <NSCopying, NSMutableCopying, NSSecureCoding> {

    UIColor* _backgroundColor;
    BOOL _backgroundColorLight;
    UIColor* _primaryTextColor;
    BOOL _primaryTextColorLight;
    UIColor* _secondaryTextColor;
    BOOL _secondaryTextColorLight;

}

@property (nonatomic,readonly) UIColor *primaryTextColor;
@property (nonatomic,readonly) UIColor *secondaryTextColor;
@property (nonatomic,readonly) UIColor *backgroundColor;

@property (getter=isPrimaryTextColorLight, nonatomic, readonly) BOOL primaryTextColorLight;
@property (getter=isSecondaryTextColorLight, nonatomic, readonly) BOOL secondaryTextColorLight;
@property (getter=isBackgroundColorLight, nonatomic, readonly) BOOL backgroundColorLight;
@end
#endif

#endif /* MPArtworkColorAnalysis_h */
