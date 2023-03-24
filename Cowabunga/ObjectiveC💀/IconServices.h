//
//  IconServices.h
//  Cowabunga
//
//  Created by sourcelocation on 27/02/2023.
//

#ifndef IconServices_h
#define IconServices_h

@class ISIconResourceLocator, NSString;

@protocol ISIconCacheServiceProtocol <NSObject>
- (void)copyIconBitmapCacheConfigurationWithReply:(void (^)(NSURL *, NSString *, NSString *))arg1;
- (void)clearCachedItemsForBundeID:(NSString *)arg1 reply:(void (^)(_Bool, NSError *))arg2;
- (void)getIconBitmapDataWithResourceLocator:(ISIconResourceLocator *)arg1 variant:(int)arg2 options:(int)arg3 reply:(void (^)(_Bool, NSData *))arg4;
@end

#endif /* IconServices_h */
