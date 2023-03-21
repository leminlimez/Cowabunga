//
//  Header.h
//  
//
//  Created by Serena on 24/10/2022
//
	

#ifndef DIAttachParams_h
#define DIAttachParams_h

@import Foundation;

#define SWIFT_THROWS __attribute__((__swift_error__(nonnull_error)))

NS_ASSUME_NONNULL_BEGIN

@interface DIAttachParams : NSObject {
    
    BOOL _autoMount;
    BOOL _handleRefCount;
    long long _fileMode;
    
}

@property (assign, nonatomic) BOOL handleRefCount;
@property (assign, nonatomic) long long fileMode;
@property (assign) BOOL autoMount;
@property (nonatomic) BOOL quarantine;

-(id)initWithURL:(NSURL * _Nonnull)arg1 error:(NSError ** _Nonnull)arg2 SWIFT_THROWS;
-(BOOL)autoMount;
-(long long)fileMode;
-(void)setFileMode:(long long)arg1 ;
-(void)setAutoMount:(BOOL)arg1 ;
@end

NS_ASSUME_NONNULL_END

#endif /* DIAttachParams_h */
