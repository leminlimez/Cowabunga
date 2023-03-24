//
//  Header.h
//  
//
//  Created by Serena on 24/10/2022
//


#ifndef DIDeviceHandle_h
#define DIDeviceHandle_h

@import Foundation;

@interface DIDeviceHandle : NSObject
@property (nonnull, retain, nonatomic) NSString *BSDName;
@property (readonly, nonatomic) NSUInteger regEntryID;
@property (nonatomic) BOOL handleRefCount;
@end

#endif /* DIDeviceHandle_h */
