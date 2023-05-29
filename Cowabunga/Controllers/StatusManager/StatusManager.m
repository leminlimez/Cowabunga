// --------------------------------------------------------------------------------
// The MIT License (MIT)
//
// Copyright (c) 2014 Shiny Development
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
// --------------------------------------------------------------------------------

#import <UIKit/UIKit.h>
#import <sys/utsname.h>
//#import <mach-o/arch.h>
#import "StatusManager.h"
#import "StatusSetter.h"
#import "StatusSetter16_1.h"
#import "StatusSetter16.h"
#import "StatusSetter15.h"
#import "StatusSetter14.h"

@interface StatusManager ()
@property (nonatomic, strong) id <StatusSetter> setter;
@property (nonatomic) bool MDCMode;

@end

@implementation StatusManager

- (instancetype)init {
    self = [super init];
    return self;
}

- (id<StatusSetter>)setter {
    if (!_setter) {
        if (@available(iOS 16.1, *)) {
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"UseAlternativeSetter"]) {
                _setter = [StatusSetter16 new];
            } else {
                _setter = [StatusSetter16_1 new];
            }
        } else if (@available(iOS 16, *)) {
            _setter = [StatusSetter16 new];
        } else if (@available(iOS 15, *)) {
            _setter =  [StatusSetter15 new];
        } else if (@available(iOS 14, *)) {
            _setter = [StatusSetter14 new];
        }
    }
    return _setter;
}

- (bool) isMDCMode {
    return self.MDCMode;
}

/// Set whether we're using MacDirtyCOW or not
- (void) setIsMDCMode:(bool)mode {
    self.MDCMode = mode;
}

+ (StatusManager *)sharedInstance {
    static dispatch_once_t predicate = 0;
    __strong static id sharedObject = nil;
    dispatch_once(&predicate, ^{ sharedObject = [[self alloc] init]; });
    return sharedObject;
}

- (bool) isCarrierOverridden {
    return [self.setter isCarrierOverridden];
}

- (NSString*) getCarrierOverride {
    return [self.setter getCarrierOverride];
}

- (void) setCarrier:(NSString*)text {
    [self.setter setCarrier:text];
}

- (void) unsetCarrier {
    [self.setter unsetCarrier];
}

- (bool) isSecondaryCellularServiceOverridden {
    return [self.setter isSecondaryCellularServiceOverridden];
}

- (bool) getSecondaryCellularServiceOverride {
    return [self.setter getSecondaryCellularServiceOverride];
}

- (void) setSecondaryCellularService:(bool)val {
    [self.setter setSecondaryCellularService:val];
}

- (void) unsetSecondaryCellularService {
    [self.setter unsetSecondaryCellularService];
}

- (bool) isSecondaryCarrierOverridden {
    return [self.setter isSecondaryCarrierOverridden];
}

- (NSString*) getSecondaryCarrierOverride {
    return [self.setter getSecondaryCarrierOverride];
}

- (void) setSecondaryCarrier:(NSString*)text {
    [self.setter setSecondaryCarrier:text];
}

- (void) unsetSecondaryCarrier {
    [self.setter unsetSecondaryCarrier];
}

- (bool) isPrimaryServiceBadgeOverridden {
    return [self.setter isPrimaryServiceBadgeOverridden];
}

- (NSString*) getPrimaryServiceBadgeOverride {
    return [self.setter getPrimaryServiceBadgeOverride];
}

- (void) setPrimaryServiceBadge:(NSString*)text {
    [self.setter setPrimaryServiceBadge:text];
}

- (void) unsetPrimaryServiceBadge {
    [self.setter unsetPrimaryServiceBadge];
}

- (bool) isSecondaryServiceBadgeOverridden {
    return [self.setter isSecondaryServiceBadgeOverridden];
}

- (NSString*) getSecondaryServiceBadgeOverride {
    return [self.setter getSecondaryServiceBadgeOverride];
}

- (void) setSecondaryServiceBadge:(NSString*)text {
    [self.setter setSecondaryServiceBadge:text];
}

- (void) unsetSecondaryServiceBadge {
    [self.setter unsetSecondaryServiceBadge];
    [self.setter unsetSecondaryServiceBadge];
}

- (bool) isDateOverridden {
    return [self.setter isDateOverridden];
}

- (NSString*) getDateOverride {
    return [self.setter getDateOverride];
}

- (void) setDate:(NSString*)text {
    [self.setter setDate:text];
}

- (void) unsetDate {
    [self.setter unsetDate];
}

- (bool) isTimeOverridden {
    return [self.setter isTimeOverridden];
}

- (NSString*) getTimeOverride {
    return [self.setter getTimeOverride];
}

- (void) setTime:(NSString*)text {
    [self.setter setTime:text];
}

- (void) unsetTime {
    [self.setter unsetTime];
}

- (bool) isBatteryDetailOverridden {
    return [self.setter isBatteryDetailOverridden];
}

- (NSString*) getBatteryDetailOverride {
    return [self.setter getBatteryDetailOverride];
}

- (void) setBatteryDetail:(NSString*)text {
    [self.setter setBatteryDetail:text];
}

- (void) unsetBatteryDetail {
    [self.setter unsetBatteryDetail];
}

- (bool) isCrumbOverridden {
    return [self.setter isCrumbOverridden];
}

- (NSString*) getCrumbOverride {
    return [self.setter getCrumbOverride];
}

- (void) setCrumb:(NSString*)text {
    [self.setter setCrumb:text];
}

- (void) unsetCrumb {
    [self.setter unsetCrumb];
}

- (bool) isDataNetworkTypeOverridden {
    return [self.setter isDataNetworkTypeOverridden];
}

- (int) getDataNetworkTypeOverride {
    return [self.setter getDataNetworkTypeOverride];
}

- (void) setDataNetworkType:(int)identifier {
    [self.setter setDataNetworkType:identifier];
}

- (void) unsetDataNetworkType {
    [self.setter unsetDataNetworkType];
}

- (bool) isSecondaryDataNetworkTypeOverridden {
    return [self.setter isSecondaryDataNetworkTypeOverridden];
}

- (int) getSecondaryDataNetworkTypeOverride {
    return [self.setter getSecondaryDataNetworkTypeOverride];
}

- (void) setSecondaryDataNetworkType:(int)identifier {
    [self.setter setSecondaryDataNetworkType:identifier];
}

- (void) unsetSecondaryDataNetworkType {
    [self.setter unsetSecondaryDataNetworkType];
}

- (bool) isBatteryCapacityOverridden {
    return [self.setter isBatteryCapacityOverridden];
}

- (int) getBatteryCapacityOverride {
    return [self.setter getBatteryCapacityOverride];
}

- (void) setBatteryCapacity:(int)capacity {
    [self.setter setBatteryCapacity:capacity];
}

- (void) unsetBatteryCapacity {
    [self.setter unsetBatteryCapacity];
}

- (bool) isWiFiSignalStrengthBarsOverridden {
    return [self.setter isWiFiSignalStrengthBarsOverridden];
}

- (int) getWiFiSignalStrengthBarsOverride {
    return [self.setter getWiFiSignalStrengthBarsOverride];
}

- (void) setWiFiSignalStrengthBars:(int)strength {
    [self.setter setWiFiSignalStrengthBars:strength];
}

- (void) unsetWiFiSignalStrengthBars {
    [self.setter unsetWiFiSignalStrengthBars];
}

- (bool) isGsmSignalStrengthBarsOverridden {
    return [self.setter isGsmSignalStrengthBarsOverridden];
}

- (int) getGsmSignalStrengthBarsOverride {
    return [self.setter getGsmSignalStrengthBarsOverride];
}

- (void) setGsmSignalStrengthBars:(int)strength {
    [self.setter setGsmSignalStrengthBars:strength];
}

- (void) unsetGsmSignalStrengthBars {
    [self.setter unsetGsmSignalStrengthBars];
}

- (bool) isSecondaryGsmSignalStrengthBarsOverridden {
    return [self.setter isSecondaryGsmSignalStrengthBarsOverridden];
}

- (int) getSecondaryGsmSignalStrengthBarsOverride {
    return [self.setter getSecondaryGsmSignalStrengthBarsOverride];
}

- (void) setSecondaryGsmSignalStrengthBars:(int)strength {
    [self.setter setSecondaryGsmSignalStrengthBars:strength];
}

- (void) unsetSecondaryGsmSignalStrengthBars {
    [self.setter unsetSecondaryGsmSignalStrengthBars];
}

- (bool) isDisplayingRawWiFiSignal {
    return [self.setter isDisplayingRawWiFiSignal];
}

- (void) displayRawWifiSignal:(bool)displaying {
    [self.setter displayRawWifiSignal:displaying];
}

- (bool) isDisplayingRawGSMSignal {
    return [self.setter isDisplayingRawGSMSignal];
}

- (void) displayRawGSMSignal:(bool)displaying {
    [self.setter displayRawGSMSignal:displaying];
}

- (bool) isClockHidden {
    return [self.setter isClockHidden];
}

- (void) hideClock:(bool)hidden {
    [self.setter hideClock:hidden];
}

- (bool) isDNDHidden {
    return [self.setter isDNDHidden];
}

- (void) hideDND:(bool)hidden {
    [self.setter hideDND:hidden];
}

- (bool) isAirplaneHidden {
    return [self.setter isAirplaneHidden];
}

- (void) hideAirplane:(bool)hidden {
    [self.setter hideAirplane:hidden];
}

- (bool) isCellHidden {
    return [self.setter isCellHidden];
}

- (void) hideCell:(bool)hidden {
    [self.setter hideCell:hidden];
}

- (bool) isWiFiHidden {
    return [self.setter isWiFiHidden];
}

- (void) hideWiFi:(bool)hidden {
    [self.setter hideWiFi:hidden];
}

- (bool) isBatteryHidden {
    return [self.setter isBatteryHidden];
}

- (void) hideBattery:(bool)hidden {
    [self.setter hideBattery:hidden];
}

- (bool) isBluetoothHidden {
    return [self.setter isBluetoothHidden];
}

- (void) hideBluetooth:(bool)hidden {
    [self.setter hideBluetooth:hidden];
}

- (bool) isAlarmHidden {
    return [self.setter isAlarmHidden];
}

- (void) hideAlarm:(bool)hidden {
    [self.setter hideAlarm:hidden];
}

- (bool) isLocationHidden {
    return [self.setter isLocationHidden];
}

- (void) hideLocation:(bool)hidden {
    [self.setter hideLocation:hidden];
}

- (bool) isRotationHidden {
    return [self.setter isRotationHidden];
}

- (void) hideRotation:(bool)hidden {
    [self.setter hideRotation:hidden];
}

- (bool) isAirPlayHidden {
    return [self.setter isAirPlayHidden];
}

- (void) hideAirPlay:(bool)hidden {
    [self.setter hideAirPlay:hidden];
}

- (bool) isCarPlayHidden {
    return [self.setter isCarPlayHidden];
}

- (void) hideCarPlay:(bool)hidden {
    [self.setter hideCarPlay:hidden];
}

- (bool) isVPNHidden {
    return [self.setter isVPNHidden];
}

- (void) hideVPN:(bool)hidden {
    [self.setter hideVPN:hidden];
}

- (bool) isMicrophoneUseHidden {
    return [self.setter isMicrophoneUseHidden];
}

- (void) hideMicrophoneUse:(bool)hidden {
    [self.setter hideMicrophoneUse:hidden];
}

- (bool) isCameraUseHidden {
    return [self.setter isCameraUseHidden];
}

- (void) hideCameraUse:(bool)hidden {
    [self.setter hideCameraUse:hidden];
}

@end
