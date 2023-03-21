//
//  NSTask.h
//  Santander
//
//  Created by Serena on 06/09/2022
//

#include <TargetConditionals.h>
@import Darwin;

#if !defined(NSTask_h)
#define NSTask_h

#if (TARGET_OS_IPHONE && !TARGET_OS_MACCATALYST)
@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface NSTask : NSObject

@property (copy) NSArray <NSString *> *arguments;
@property (copy) NSURL *currentDirectoryURL;
@property (copy) NSDictionary *environment;
@property (copy) NSURL *executableURL;
@property (readonly) int processIdentifier;
@property NSInteger qualityOfService;
@property (getter=isRunning, readonly) BOOL running;
@property (retain) NSPipe *standardError;
@property (retain) id standardInput;
@property (retain) NSPipe *standardOutput;
@property(copy) void (^terminationHandler)(NSTask *);
@property (readonly) NSInteger terminationReason;
@property (readonly) int terminationStatus;


+(id)allocWithZone:(struct _NSZone *)arg0 ;
+(id)currentTaskDictionary;
+(id)launchedTaskWithDictionary:(id)arg0 ;
-(BOOL)isSpawnedProcessDisclaimed;
-(BOOL)resume;
-(BOOL)suspend;
-(NSInteger)suspendCount;
-(BOOL)launchAndReturnError:(out NSError * _Nullable *)error;
-(id)currentDirectoryPath;
-(id)init;
-(id)launchPath;
-(void)waitUntilExit;
-(void)interrupt;
-(void)launch;
-(void)setCurrentDirectoryPath:(id)arg0 ;
-(void)setLaunchPath:(id)arg0 ;
-(void)setSpawnedProcessDisclaimed:(BOOL)arg0 ;
-(void)terminate;

@end

NS_ASSUME_NONNULL_END

// MARK: - Posix Spawn stuff
// these aren't available in the public SDK (for iOS), so we define them here

#define POSIX_SPAWN_PERSONA_FLAGS_OVERRIDE 1
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnullability-completeness" // shut the hell up about nullability specification
int posix_spawnattr_set_persona_np(const posix_spawnattr_t* __restrict, uid_t, uint32_t);
int posix_spawnattr_set_persona_uid_np(const posix_spawnattr_t* __restrict, uid_t);
int posix_spawnattr_set_persona_gid_np(const posix_spawnattr_t* __restrict, uid_t);
#pragma clang diagnostic pop
#endif

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnullability-completeness"
int proc_pidpath(pid_t pid, void *buffer, uint32_t buffersize);
#pragma clang diagnostic pop

#endif /* NSTask_h */
