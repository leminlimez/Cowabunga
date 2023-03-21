//
//  MPArtworkColorAnalyzer.h
//  
//
//  Created by Serena on 09/11/2022
//
	

#ifndef MPArtworkColorAnalyzer_h
#define MPArtworkColorAnalyzer_h

#if __has_include(<UIKit/UIKit.h>)
@import MediaPlayer;

#include "MPArtworkColorAnalysis.h"

@class MPArtworkColorAnalyzer; // needed for the typede

typedef void (^AnalyzerReturnBlock)(MPArtworkColorAnalyzer * _Null_unspecified, MPArtworkColorAnalysis * _Null_unspecified);

@interface MPArtworkColorAnalyzer : NSObject {

    long long _algorithm;
    UIImage* _image;

}

@property (nonatomic,readonly) long long algorithm;

-(long long)algorithm;
-(_Nonnull instancetype)initWithImage:(UIImage * _Nonnull)arg1 algorithm:(long long)arg2 ;
-(void)analyzeWithCompletionHandler:(AnalyzerReturnBlock _Nonnull)arg1 ;
@end

#endif


#endif /* MPArtworkColorAnalyzer_h */
