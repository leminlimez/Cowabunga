//
//  CUICommonAssetStorage.h
//  Santander
//
//  Created by Serena on 25/09/2022
//
	

#ifndef CUICommonAssetStorage_h
#define CUICommonAssetStorage_h
@import Foundation;
#include "structs.h"

NS_ASSUME_NONNULL_BEGIN
@interface CUICommonAssetStorage : NSObject
- (NSArray *)allAssetKeys;
- (NSArray *)allRenditionNames;
- (NSData *)assetForKey:(NSData *)arg1;
- (void)enumerateKeysAndObjectsUsingBlock:(void (^)(struct renditionkeytoken *keyList, NSData *csiData))block;
- (long long)maximumRenditionKeyTokenCount;
- (instancetype _Nullable)initWithPath:(NSString *)arg1 forWriting:(bool)arg2;

- (const char *)mainVersionString;
- (const char *)versionString;

- (long long)storageTimestamp;
- (long long)_storagefileTimestamp;
- (unsigned int)schemaVersion;
- (unsigned int)coreuiVersion;
- (unsigned int)storageVersion;
- (NSUUID *)uuid;

- (NSString *)thinningArguments;
- (NSString *)deploymentPlatform;
- (NSString *)deploymentPlatformVersion;
- (NSString *)authoringTool;
@end

@interface CUIMutableCommonAssetStorage : CUICommonAssetStorage
- (void)setColor:(struct rgbquad)arg1 forName:(char *)arg2 excludeFromFilter:(bool)arg3;
- (bool)setAsset:(NSData *)arg1 forKey:(NSData *)arg2;
- (void)removeAssetForKey:(id)arg0;
- (bool)writeToDiskAndCompact:(bool)arg1 NS_SWIFT_NAME(writeToDisk(compact:));
@end

NS_ASSUME_NONNULL_END

#endif /* CUICommonAssetStorage_h */
