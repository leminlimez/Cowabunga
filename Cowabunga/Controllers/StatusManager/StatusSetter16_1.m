#import "StatusSetter16_1.h"
#import "StatusManager.h"

typedef NS_ENUM(int, StatusBarItem) {
  TimeStatusBarItem = 0,
  DateStatusBarItem = 1,
  QuietModeStatusBarItem = 2,
  AirplaneModeStatusBarItem = 3,
  CellularSignalStrengthStatusBarItem = 4,
  SecondaryCellularSignalStrengthStatusBarItem = 5,
  CellularServiceStatusBarItem = 6,
  SecondaryCellularServiceStatusBarItem = 7,
  // 8
  CellularDataNetworkStatusBarItem = 9,
  SecondaryCellularDataNetworkStatusBarItem = 10,
  // 11
  MainBatteryStatusBarItem = 12,
  ProminentlyShowBatteryDetailStatusBarItem = 13,
  // 14
  // 15
  BluetoothStatusBarItem = 16,
  TTYStatusBarItem = 17,
  AlarmStatusBarItem = 18,
  // 19
  // 20
  LocationStatusBarItem = 21,
  RotationLockStatusBarItem = 22,
  CameraUseStatusBarItem = 23,
  AirPlayStatusBarItem = 24,
  AssistantStatusBarItem = 25,
  CarPlayStatusBarItem = 26,
  StudentStatusBarItem = 27,
  MicrophoneUseStatusBarItem = 28,
  VPNStatusBarItem = 29,
  // 30
  // 31
  // 32
  // 33
  // 34
  // 35
  // 36
  // 37
  LiquidDetectionStatusBarItem = 38,
  VoiceControlStatusBarItem = 39,
  // 40
  // 41
  // 42
  // 43
  Extra1StatusBarItem = 44,
};

typedef NS_ENUM(unsigned int, BatteryState) {
  BatteryStateUnplugged = 0
};

typedef struct {
  bool itemIsEnabled[45];
  char padding;
  char timeString[64];
  char shortTimeString[64];
  char dateString[256];
  int gsmSignalStrengthRaw;
  int secondaryGsmSignalStrengthRaw;
  int gsmSignalStrengthBars;
  int secondaryGsmSignalStrengthBars;
  char serviceString[100];
  char secondaryServiceString[100];
  char serviceCrossfadeString[100];
  char secondaryServiceCrossfadeString[100];
  char serviceImages[2][100];
  char operatorDirectory[1024];
  unsigned int serviceContentType;
  unsigned int secondaryServiceContentType;
  unsigned int cellLowDataModeActive:1;
  unsigned int secondaryCellLowDataModeActive:1;
  int wifiSignalStrengthRaw;
  int wifiSignalStrengthBars;
  unsigned int wifiLowDataModeActive:1;
  unsigned int dataNetworkType;
  unsigned int secondaryDataNetworkType;
  int batteryCapacity;
  unsigned int batteryState;
  char batteryDetailString[150];
  int bluetoothBatteryCapacity;
  int thermalColor;
  unsigned int thermalSunlightMode : 1;
  unsigned int slowActivity : 1;
  unsigned int syncActivity : 1;
  char activityDisplayId[256];
  unsigned int bluetoothConnected : 1;
  unsigned int displayRawGSMSignal : 1;
  unsigned int displayRawWifiSignal : 1;
  unsigned int locationIconType : 1;
  unsigned int voiceControlIconType:2;
  unsigned int quietModeInactive : 1;
  unsigned int tetheringConnectionCount;
  unsigned int batterySaverModeActive : 1;
  unsigned int deviceIsRTL : 1;
  unsigned int lock : 1;
  char breadcrumbTitle[256];
  char breadcrumbSecondaryTitle[256];
  char personName[100];
  unsigned int electronicTollCollectionAvailable : 1;
  unsigned int radarAvailable : 1;
  unsigned int wifiLinkWarning : 1;
  unsigned int wifiSearching : 1;
  double backgroundActivityDisplayStartDate;
  unsigned int shouldShowEmergencyOnlyStatus : 1;
  unsigned int secondaryCellularConfigured : 1;
  char primaryServiceBadgeString[100];
  char secondaryServiceBadgeString[100];
  char quietModeImage[256];
  unsigned int extra1 : 1; // Unsure of actual size, but it's at least 1 byte. Since this is at the end of the struct, and we aren't modifying this part of the struct, it likely shouldn't matter that it's not the correct size.
} StatusBarRawData;

typedef struct {
  bool overrideItemIsEnabled[45];
  char padding;
  unsigned int overrideTimeString : 1;
  unsigned int overrideDateString : 1;
  unsigned int overrideGsmSignalStrengthRaw : 1;
  unsigned int overrideSecondaryGsmSignalStrengthRaw : 1;
  unsigned int overrideGsmSignalStrengthBars : 1;
  unsigned int overrideSecondaryGsmSignalStrengthBars : 1;
  unsigned int overrideServiceString : 1;
  unsigned int overrideSecondaryServiceString : 1;
  unsigned int overrideServiceImages : 2;
  unsigned int overrideOperatorDirectory : 1;
  unsigned int overrideServiceContentType : 1;
  unsigned int overrideSecondaryServiceContentType : 1;
  unsigned int overrideWifiSignalStrengthRaw : 1;
  unsigned int overrideWifiSignalStrengthBars : 1;
  unsigned int overrideDataNetworkType : 1;
  unsigned int overrideSecondaryDataNetworkType : 1;
  unsigned int disallowsCellularDataNetworkTypes : 1;
  unsigned int overrideBatteryCapacity : 1;
  unsigned int overrideBatteryState : 1;
  unsigned int overrideBatteryDetailString : 1;
  unsigned int overrideBluetoothBatteryCapacity : 1;
  unsigned int overrideThermalColor : 1;
  unsigned int overrideSlowActivity : 1;
  unsigned int overrideActivityDisplayId : 1;
  unsigned int overrideBluetoothConnected : 1;
  unsigned int overrideBreadcrumb : 1;
  unsigned int overrideLock;
  unsigned int overrideDisplayRawGSMSignal : 1;
  unsigned int overrideDisplayRawWifiSignal : 1;
  unsigned int overridePersonName : 1;
  unsigned int overrideWifiLinkWarning : 1;
  unsigned int overrideSecondaryCellularConfigured : 1;
  unsigned int overridePrimaryServiceBadgeString : 1;
  unsigned int overrideSecondaryServiceBadgeString : 1;
  unsigned int overrideQuietModeImage : 1;
  unsigned int overrideExtra1 : 1; // Not sure what this is, but there only seems to be one of them
  StatusBarRawData values;
} StatusBarOverrideData;

@class UIStatusBarServer;

@protocol UIStatusBarServerClient

@required

- (void)statusBarServer:(UIStatusBarServer *)arg1 didReceiveDoubleHeightStatusString:(NSString *)arg2 forStyle:(long long)arg3;
- (void)statusBarServer:(UIStatusBarServer *)arg1 didReceiveGlowAnimationState:(bool)arg2 forStyle:(long long)arg3;
- (void)statusBarServer:(UIStatusBarServer *)arg1 didReceiveStatusBarData:(const StatusBarRawData *)arg2 withActions:(int)arg3;
- (void)statusBarServer:(UIStatusBarServer *)arg1 didReceiveStyleOverrides:(int)arg2;

@end

@interface UIStatusBarServer : NSObject

@property (nonatomic, strong) id<UIStatusBarServerClient> statusBar;

+ (void)postStatusBarOverrideData:(StatusBarOverrideData *)arg1;
+ (void)permanentizeStatusBarOverrideData;
+ (StatusBarOverrideData *)getStatusBarOverrideData;

@end

@implementation StatusSetter16_1

// BELOW IS THE SAME IN iOS 15, 16, and 16.1

- (void) applyChanges:(StatusBarOverrideData*)overrides {
    if (!StatusManager.sharedInstance.isMDCMode) {
        [UIStatusBarServer postStatusBarOverrideData:overrides];
        [UIStatusBarServer permanentizeStatusBarOverrideData];
    } else {
        FILE *outfile;
        outfile = fopen ("/var/mobile/Library/SpringBoard/statusBarOverridesEditing", "w+");
        if (outfile == NULL) return;
        
        char padding[256] = {'\0'};

        fwrite (overrides, sizeof(StatusBarOverrideData), 1, outfile);
        fwrite (padding, sizeof(padding), 1, outfile);

        fclose (outfile);
    }
}

- (StatusBarOverrideData*) getOverrides {
    if (!StatusManager.sharedInstance.isMDCMode) {
        return [UIStatusBarServer getStatusBarOverrideData];
    } else {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *path = @"/var/mobile/Library/SpringBoard/statusBarOverridesEditing";
        if ([fileManager fileExistsAtPath:path]){
            FILE *infile;
            NSMutableData* data = [NSMutableData dataWithLength:sizeof(StatusBarOverrideData)];
            StatusBarOverrideData* input = [data mutableBytes];
            infile = fopen ("/var/mobile/Library/SpringBoard/statusBarOverridesEditing", "r");
            if (infile == NULL) return NULL;
            if (fread(input, sizeof(StatusBarOverrideData), 1, infile) != 0) {
                fclose (infile);
                return input;
            }
            fclose (infile);
            return NULL;
        } else {
            StatusBarOverrideData* overrides = [UIStatusBarServer getStatusBarOverrideData];
            [self applyChanges:overrides];
            return overrides;
        }
    }
}

// ALL BELOW HERE IS IDENTICAL IN EACH SETTER

- (bool) isCarrierOverridden {
    StatusBarOverrideData *overrides = [self getOverrides];
    return overrides->overrideServiceString == 1;
}

- (NSString*) getCarrierOverride {
    StatusBarOverrideData *overrides = [self getOverrides];
    NSString* carrier = @(overrides->values.serviceString);
    return carrier;
}

- (void) setCarrier:(NSString*)text {
    StatusBarOverrideData *overrides = [self getOverrides];
    overrides->overrideServiceString = 1;
    overrides->overrideSecondaryServiceString = 1;
    strcpy(overrides->values.serviceString, [text cStringUsingEncoding:NSUTF8StringEncoding]);
    strcpy(overrides->values.serviceCrossfadeString, [text cStringUsingEncoding:NSUTF8StringEncoding]);
    strcpy(overrides->values.secondaryServiceString, [text cStringUsingEncoding:NSUTF8StringEncoding]);
    strcpy(overrides->values.secondaryServiceCrossfadeString, [text cStringUsingEncoding:NSUTF8StringEncoding]);
    [self applyChanges:overrides];
}

- (void) unsetCarrier {
    StatusBarOverrideData *overrides = [self getOverrides];
    overrides->overrideServiceString = 0;
    overrides->overrideSecondaryServiceString = 0;
    [self applyChanges:overrides];
}

- (bool) isTimeOverridden {
    StatusBarOverrideData *overrides = [self getOverrides];
    return overrides->overrideTimeString == 1;
}

- (NSString*) getTimeOverride {
    StatusBarOverrideData *overrides = [self getOverrides];
    NSString* time = @(overrides->values.timeString);
    return time;
}

- (void) setTime:(NSString*)text {
    StatusBarOverrideData *overrides = [self getOverrides];
    strcpy(overrides->values.timeString, [text cStringUsingEncoding:NSUTF8StringEncoding]);
    overrides->overrideTimeString = 1;
    [self applyChanges:overrides];
}

- (void) unsetTime {
    StatusBarOverrideData *overrides = [self getOverrides];
    overrides->overrideTimeString = 0;
    [self applyChanges:overrides];
}

- (bool) isCrumbOverridden {
    StatusBarOverrideData *overrides = [self getOverrides];
    return overrides->overrideBreadcrumb == 1;
}

- (NSString*) getCrumbOverride {
    StatusBarOverrideData *overrides = [self getOverrides];
    NSString* crumb = @(overrides->values.breadcrumbTitle);
    if (crumb.length > 1) {
        return [crumb substringToIndex:[crumb length] - 2];
    } else {
        return @"";
    }
}

- (void) setCrumb:(NSString*)text {
    StatusBarOverrideData *overrides = [self getOverrides];
    overrides->overrideBreadcrumb = 1;
    strcpy(overrides->values.breadcrumbTitle, [[text stringByAppendingString:@" ▶"] cStringUsingEncoding:NSUTF8StringEncoding]);
    [self applyChanges:overrides];
}

- (void) unsetCrumb {
    StatusBarOverrideData *overrides = [self getOverrides];
    strcpy(overrides->values.breadcrumbTitle, [@"" cStringUsingEncoding:NSUTF8StringEncoding]);
    overrides->overrideBreadcrumb = 0;
    [self applyChanges:overrides];
}

- (bool) isClockHidden {
    StatusBarOverrideData *overrides = [self getOverrides];
    return overrides->overrideItemIsEnabled[TimeStatusBarItem] == 1;
}

- (void) hideClock:(bool)hidden {
    StatusBarOverrideData *overrides = [self getOverrides];
    if (hidden) {
        overrides->overrideItemIsEnabled[TimeStatusBarItem] = 1;
        overrides->values.itemIsEnabled[TimeStatusBarItem] = 0;
    } else {
        overrides->overrideItemIsEnabled[TimeStatusBarItem] = 0;
    }
    
    [self applyChanges:overrides];
}

- (bool) isDNDHidden {
    StatusBarOverrideData *overrides = [self getOverrides];
    return overrides->overrideItemIsEnabled[QuietModeStatusBarItem] == 1;
}

- (void) hideDND:(bool)hidden {
    StatusBarOverrideData *overrides = [self getOverrides];
    if (hidden) {
        overrides->overrideItemIsEnabled[QuietModeStatusBarItem] = 1;
        overrides->values.itemIsEnabled[QuietModeStatusBarItem] = 0;
    } else {
        overrides->overrideItemIsEnabled[QuietModeStatusBarItem] = 0;
    }
    
    [self applyChanges:overrides];
}

- (bool) isAirplaneHidden {
    StatusBarOverrideData *overrides = [self getOverrides];
    return overrides->overrideItemIsEnabled[AirplaneModeStatusBarItem] == 1;
}

- (void) hideAirplane:(bool)hidden {
    StatusBarOverrideData *overrides = [self getOverrides];
    if (hidden) {
        overrides->overrideItemIsEnabled[AirplaneModeStatusBarItem] = 1;
        overrides->values.itemIsEnabled[AirplaneModeStatusBarItem] = 0;
    } else {
        overrides->overrideItemIsEnabled[AirplaneModeStatusBarItem] = 0;
    }
    
    [self applyChanges:overrides];
}

- (bool) isCellHidden {
    StatusBarOverrideData *overrides = [self getOverrides];
    return overrides->overrideItemIsEnabled[CellularServiceStatusBarItem] == 1;
}

- (void) hideCell:(bool)hidden {
    StatusBarOverrideData *overrides = [self getOverrides];
    if (hidden) {
        overrides->overrideItemIsEnabled[CellularServiceStatusBarItem] = 1;
        overrides->values.itemIsEnabled[CellularServiceStatusBarItem] = 0;
        overrides->overrideItemIsEnabled[SecondaryCellularServiceStatusBarItem] = 1;
        overrides->values.itemIsEnabled[SecondaryCellularServiceStatusBarItem] = 0;
    } else {
        overrides->overrideItemIsEnabled[CellularServiceStatusBarItem] = 0;
        overrides->overrideItemIsEnabled[SecondaryCellularServiceStatusBarItem] = 0;
    }
    
    [self applyChanges:overrides];
}

- (bool) isWiFiHidden {
    StatusBarOverrideData *overrides = [self getOverrides];
    return overrides->overrideItemIsEnabled[CellularDataNetworkStatusBarItem] == 1;
}

- (void) hideWiFi:(bool)hidden {
    StatusBarOverrideData *overrides = [self getOverrides];
    if (hidden) {
        overrides->overrideItemIsEnabled[CellularDataNetworkStatusBarItem] = 1;
        overrides->values.itemIsEnabled[CellularDataNetworkStatusBarItem] = 0;
        overrides->overrideItemIsEnabled[SecondaryCellularDataNetworkStatusBarItem] = 1;
        overrides->values.itemIsEnabled[SecondaryCellularDataNetworkStatusBarItem] = 0;
    } else {
        overrides->overrideItemIsEnabled[CellularDataNetworkStatusBarItem] = 0;
        overrides->overrideItemIsEnabled[SecondaryCellularDataNetworkStatusBarItem] = 0;
    }
    
    [self applyChanges:overrides];
}

- (bool) isBatteryHidden {
    StatusBarOverrideData *overrides = [self getOverrides];
    return overrides->overrideItemIsEnabled[MainBatteryStatusBarItem] == 1;
}

- (void) hideBattery:(bool)hidden {
    StatusBarOverrideData *overrides = [self getOverrides];
    if (hidden) {
        overrides->overrideItemIsEnabled[MainBatteryStatusBarItem] = 1;
        overrides->values.itemIsEnabled[MainBatteryStatusBarItem] = 0;
    } else {
        overrides->overrideItemIsEnabled[MainBatteryStatusBarItem] = 0;
    }
    
    [self applyChanges:overrides];
}

- (bool) isBluetoothHidden {
    StatusBarOverrideData *overrides = [self getOverrides];
    return overrides->overrideItemIsEnabled[BluetoothStatusBarItem] == 1;
}

- (void) hideBluetooth:(bool)hidden {
    StatusBarOverrideData *overrides = [self getOverrides];
    if (hidden) {
        overrides->overrideItemIsEnabled[BluetoothStatusBarItem] = 1;
        overrides->values.itemIsEnabled[BluetoothStatusBarItem] = 0;
    } else {
        overrides->overrideItemIsEnabled[BluetoothStatusBarItem] = 0;
    }
    
    [self applyChanges:overrides];
}

- (bool) isAlarmHidden {
    StatusBarOverrideData *overrides = [self getOverrides];
    return overrides->overrideItemIsEnabled[AlarmStatusBarItem] == 1;
}

- (void) hideAlarm:(bool)hidden {
    StatusBarOverrideData *overrides = [self getOverrides];
    if (hidden) {
        overrides->overrideItemIsEnabled[AlarmStatusBarItem] = 1;
        overrides->values.itemIsEnabled[AlarmStatusBarItem] = 0;
    } else {
        overrides->overrideItemIsEnabled[AlarmStatusBarItem] = 0;
    }
    
    [self applyChanges:overrides];
}

- (bool) isLocationHidden {
    StatusBarOverrideData *overrides = [self getOverrides];
    return overrides->overrideItemIsEnabled[LocationStatusBarItem] == 1;
}

- (void) hideLocation:(bool)hidden {
    StatusBarOverrideData *overrides = [self getOverrides];
    if (hidden) {
        overrides->overrideItemIsEnabled[LocationStatusBarItem] = 1;
        overrides->values.itemIsEnabled[LocationStatusBarItem] = 0;
    } else {
        overrides->overrideItemIsEnabled[LocationStatusBarItem] = 0;
    }
    
    [self applyChanges:overrides];
}

- (bool) isRotationHidden {
    StatusBarOverrideData *overrides = [self getOverrides];
    return overrides->overrideItemIsEnabled[RotationLockStatusBarItem] == 1;
}

- (void) hideRotation:(bool)hidden {
    StatusBarOverrideData *overrides = [self getOverrides];
    if (hidden) {
        overrides->overrideItemIsEnabled[RotationLockStatusBarItem] = 1;
        overrides->values.itemIsEnabled[RotationLockStatusBarItem] = 0;
    } else {
        overrides->overrideItemIsEnabled[RotationLockStatusBarItem] = 0;
    }
    
    [self applyChanges:overrides];
}

- (bool) isAirPlayHidden {
    StatusBarOverrideData *overrides = [self getOverrides];
    return overrides->overrideItemIsEnabled[AirPlayStatusBarItem] == 1;
}

- (void) hideAirPlay:(bool)hidden {
    StatusBarOverrideData *overrides = [self getOverrides];
    if (hidden) {
        overrides->overrideItemIsEnabled[AirPlayStatusBarItem] = 1;
        overrides->values.itemIsEnabled[AirPlayStatusBarItem] = 0;
    } else {
        overrides->overrideItemIsEnabled[AirPlayStatusBarItem] = 0;
    }
    
    [self applyChanges:overrides];
}

- (bool) isCarPlayHidden {
    StatusBarOverrideData *overrides = [self getOverrides];
    return overrides->overrideItemIsEnabled[CarPlayStatusBarItem] == 1;
}

- (void) hideCarPlay:(bool)hidden {
    StatusBarOverrideData *overrides = [self getOverrides];
    if (hidden) {
        overrides->overrideItemIsEnabled[CarPlayStatusBarItem] = 1;
        overrides->values.itemIsEnabled[CarPlayStatusBarItem] = 0;
    } else {
        overrides->overrideItemIsEnabled[CarPlayStatusBarItem] = 0;
    }
    
    [self applyChanges:overrides];
}

- (bool) isVPNHidden {
    StatusBarOverrideData *overrides = [self getOverrides];
    return overrides->overrideItemIsEnabled[VPNStatusBarItem] == 1;
}

- (void) hideVPN:(bool)hidden {
    StatusBarOverrideData *overrides = [self getOverrides];
    if (hidden) {
        overrides->overrideItemIsEnabled[VPNStatusBarItem] = 1;
        overrides->values.itemIsEnabled[VPNStatusBarItem] = 0;
    } else {
        overrides->overrideItemIsEnabled[VPNStatusBarItem] = 0;
    }
    
    [self applyChanges:overrides];
}

- (bool) isMicrophoneUseHidden {
    StatusBarOverrideData *overrides = [self getOverrides];
    return overrides->overrideItemIsEnabled[MicrophoneUseStatusBarItem] == 1;
}

- (void) hideMicrophoneUse:(bool)hidden {
    StatusBarOverrideData *overrides = [self getOverrides];
    if (hidden) {
        overrides->overrideItemIsEnabled[MicrophoneUseStatusBarItem] = 1;
        overrides->values.itemIsEnabled[MicrophoneUseStatusBarItem] = 0;
    } else {
        overrides->overrideItemIsEnabled[MicrophoneUseStatusBarItem] = 0;
    }
    
    [self applyChanges:overrides];
}

- (bool) isCameraUseHidden {
    StatusBarOverrideData *overrides = [self getOverrides];
    return overrides->overrideItemIsEnabled[CameraUseStatusBarItem] == 1;
}

- (void) hideCameraUse:(bool)hidden {
    StatusBarOverrideData *overrides = [self getOverrides];
    if (hidden) {
        overrides->overrideItemIsEnabled[CameraUseStatusBarItem] = 1;
        overrides->values.itemIsEnabled[CameraUseStatusBarItem] = 0;
    } else {
        overrides->overrideItemIsEnabled[CameraUseStatusBarItem] = 0;
    }
    
    [self applyChanges:overrides];
}

@end
