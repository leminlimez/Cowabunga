//
//  LaunchServicesPrivate.h
//  Santander
//
//  Created by Serena on 15/08/2022.
//

#ifndef LaunchServicesPrivate_h
#define LaunchServicesPrivate_h

#define UIKIT_AVAILABLE __has_include(<UIKit/UIKit.h>)

#if UIKIT_AVAILABLE
@import UIKit;
#elif __has_include(<AppKit/AppKit.h>)
@import AppKit;
#endif

NS_ASSUME_NONNULL_BEGIN

@interface LSApplicationProxy
@property (readonly, nonatomic) NSString *applicationType;
@property (getter=isDeletable, readonly, nonatomic) BOOL deletable;
@property (getter=isBetaApp, readonly, nonatomic) BOOL betaApp;
@property (getter=isRestricted, readonly, nonatomic) BOOL restricted;
@property (getter=isContainerized, readonly, nonatomic) BOOL containerized;
@property (readonly, nonatomic) NSSet <NSString *> *claimedURLSchemes;
@property (readonly, nonatomic) NSString *teamID;
@property (copy, nonatomic) NSString *sdkVersion;
@property (readonly, nonatomic) NSDictionary <NSString *, id> *entitlements;
@property (readonly, nonatomic) NSURL* _Nullable bundleContainerURL;

+ (LSApplicationProxy*)applicationProxyForIdentifier:(id)identifier;
- (NSString *)applicationIdentifier;
- (NSURL *)containerURL;
- (NSURL *)bundleURL;
- (NSString *)localizedName;
- (NSData *)iconDataForVariant:(id)variant;
- (NSData *)iconDataForVariant:(id)variant withOptions:(id)options;
@end


@interface LSApplicationWorkspace
+ (instancetype) defaultWorkspace;
- (NSArray <LSApplicationProxy *> *)allInstalledApplications;
- (NSArray <LSApplicationProxy *> *)allApplications;
- (BOOL)openApplicationWithBundleID:(NSString *)arg0 ;
- (BOOL)uninstallApplication:(NSString *)arg0 withOptions:(_Nullable id)arg1 error:(NSError **)arg2 usingBlock:(_Nullable id)arg3;
@end

#if UIKIT_AVAILABLE
@interface UIImage (Private)
+ (instancetype)_applicationIconImageForBundleIdentifier:(NSString*)bundleIdentifier format:(int)format scale:(CGFloat)scale;
@end
#endif

NS_ASSUME_NONNULL_END

#endif /* LaunchServicesPrivate_h */
