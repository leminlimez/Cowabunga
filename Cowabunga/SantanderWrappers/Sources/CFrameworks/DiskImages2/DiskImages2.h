//
//  Header.h
//  
//
//  Created by Serena on 24/10/2022
//
	

#ifndef DiskImages2_h
#define DiskImages2_h

@import Foundation;

#include "DIAttachParams.h"
#include "DIDeviceHandle.h"

#define SWIFT_THROWS __attribute__((__swift_error__(nonnull_error)))

NS_ASSUME_NONNULL_BEGIN

@interface DiskImages2 : NSObject
// Prints the URL from which an attached disk came from
+(NSURL * _Nonnull)imageURLFromDevice:(NSURL *)arg1 error:(NSError **)arg2 SWIFT_THROWS;
+(BOOL)attachWithParams:(DIAttachParams *)param handle:(DIDeviceHandle * _Nullable * _Nullable)h error:(NSError **)err SWIFT_THROWS;
@end

NS_ASSUME_NONNULL_END

#endif /* DiskImages2_h */
