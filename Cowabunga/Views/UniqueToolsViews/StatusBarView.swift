//
//  StatusBarView.swift
//  Cowabunga
//
//  Created by lemin on 2/3/23.
//

import SwiftUI

struct StatusBarView: View {
    @Environment(\.openURL) var openURL
    
    @State private var carrierText: String = StatusManager.sharedInstance().getCarrierOverride()
    @State private var carrierTextEnabled: Bool = StatusManager.sharedInstance().isCarrierOverridden()
    
    @State private var primaryServiceBadgeText: String = StatusManager.sharedInstance().getPrimaryServiceBadgeOverride()
    @State private var primaryServiceBadgeTextEnabled: Bool = StatusManager.sharedInstance().isPrimaryServiceBadgeOverridden()
    
    @State private var secondaryCarrierText: String = StatusManager.sharedInstance().getSecondaryCarrierOverride()
    @State private var secondaryCarrierTextEnabled: Bool = StatusManager.sharedInstance().isSecondaryCarrierOverridden()
    
    @State private var secondaryServiceBadgeText: String = StatusManager.sharedInstance().getSecondaryServiceBadgeOverride()
    @State private var secondaryServiceBadgeTextEnabled: Bool = StatusManager.sharedInstance().isSecondaryServiceBadgeOverridden()
    
    @State private var dateText: String = StatusManager.sharedInstance().getDateOverride()
    @State private var dateTextEnabled: Bool = StatusManager.sharedInstance().isDateOverridden()
    
    @State private var timeText: String = StatusManager.sharedInstance().getTimeOverride()
    @State private var timeTextEnabled: Bool = StatusManager.sharedInstance().isTimeOverridden()
    
    @State private var batteryDetailText: String = StatusManager.sharedInstance().getBatteryDetailOverride()
    @State private var batteryDetailEnabled: Bool = StatusManager.sharedInstance().isBatteryDetailOverridden()
    
    @State private var crumbText: String = StatusManager.sharedInstance().getCrumbOverride()
    @State private var crumbTextEnabled: Bool = StatusManager.sharedInstance().isCrumbOverridden()
    
    @State private var batteryCapacity: Double = Double(StatusManager.sharedInstance().getBatteryCapacityOverride())
    @State private var batteryCapacityEnabled: Bool = StatusManager.sharedInstance().isBatteryCapacityOverridden()
    
    @State private var wiFiStrengthBars: Double = Double(StatusManager.sharedInstance().getWiFiSignalStrengthBarsOverride())
    @State private var wiFiStrengthBarsEnabled: Bool = StatusManager.sharedInstance().isWiFiSignalStrengthBarsOverridden()
    
    @State private var gsmStrengthBars: Double = Double(StatusManager.sharedInstance().getGsmSignalStrengthBarsOverride())
    @State private var gsmStrengthBarsEnabled: Bool = StatusManager.sharedInstance().isGsmSignalStrengthBarsOverridden()
    
    @State private var displayingRawWiFiStrength: Bool = StatusManager.sharedInstance().isDisplayingRawWiFiSignal()
    @State private var displayingRawGSMStrength: Bool = StatusManager.sharedInstance().isDisplayingRawGSMSignal()
    
    @State private var clockHidden: Bool = StatusManager.sharedInstance().isClockHidden()
    @State private var DNDHidden: Bool = StatusManager.sharedInstance().isDNDHidden()
    @State private var airplaneHidden: Bool = StatusManager.sharedInstance().isAirplaneHidden()
    @State private var cellHidden: Bool = StatusManager.sharedInstance().isCellHidden()
    @State private var wiFiHidden: Bool = StatusManager.sharedInstance().isWiFiHidden()
    @State private var batteryHidden: Bool = StatusManager.sharedInstance().isBatteryHidden()
    @State private var bluetoothHidden: Bool = StatusManager.sharedInstance().isBluetoothHidden()
    @State private var alarmHidden: Bool = StatusManager.sharedInstance().isAlarmHidden()
    @State private var locationHidden: Bool = StatusManager.sharedInstance().isLocationHidden()
    @State private var rotationHidden: Bool = StatusManager.sharedInstance().isRotationHidden()
    @State private var airPlayHidden: Bool = StatusManager.sharedInstance().isAirPlayHidden()
    @State private var carPlayHidden: Bool = StatusManager.sharedInstance().isCarPlayHidden()
    @State private var VPNHidden: Bool = StatusManager.sharedInstance().isVPNHidden()
    
    let fm = FileManager.default
    
    var body: some  View {
        List {
            Section (footer: Text("⚠️ Warning ⚠️\nSome users have experienced bootloops using this feature. If you are on a beta version of iOS, preceed with caution. If you are on an iOS 16.0 beta, do not use this feature.")) {
                
            }
            
            if (StatusManager.sharedInstance().isMDCMode()) {
                Section (footer: Text("Your device will respring.")) {
                    Button("Apply") {
                        if fm.fileExists(atPath: "/var/mobile/Library/SpringBoard/statusBarOverridesEditing") {
                            do {
                                _ = try fm.replaceItemAt(URL(fileURLWithPath: "/var/mobile/Library/SpringBoard/statusBarOverrides"), withItemAt: URL(fileURLWithPath: "/var/mobile/Library/SpringBoard/statusBarOverridesEditing"))
                                restartFrontboard()
                            } catch {
                                UIApplication.shared.alert(body: "\(error)")
                            }
                            
                        }
                    }
                }
            }
            
            Section (footer: Text("When set to blank on notched devices, this will display the carrier name.")) {
                Toggle("Change Breadcrumb Text", isOn: $crumbTextEnabled).onChange(of: crumbTextEnabled, perform: { nv in
                    if nv {
                        StatusManager.sharedInstance().setCrumb(crumbText)
                    } else {
                        StatusManager.sharedInstance().unsetCrumb()
                    }
                })
                TextField("Breadcrumb Text", text: $crumbText).onChange(of: crumbText, perform: { nv in
                    // This is important.
                    // Make sure the UTF-8 representation of the string does not exceed 256
                    // Otherwise the struct will overflow
                    var safeNv = nv
                    while (safeNv + " ▶").utf8CString.count > 256 {
                        safeNv = String(safeNv.prefix(safeNv.count - 1))
                    }
                    crumbText = safeNv
                    if crumbTextEnabled {
                        StatusManager.sharedInstance().setCrumb(safeNv)
                    }
                })
                Toggle("Change Battery Detail Text", isOn: $batteryDetailEnabled).onChange(of: batteryDetailEnabled, perform: { nv in
                    if nv {
                        StatusManager.sharedInstance().setBatteryDetail(batteryDetailText)
                    } else {
                        StatusManager.sharedInstance().unsetBatteryDetail()
                    }
                })
                TextField("Battery Detail Text", text: $batteryDetailText).onChange(of: batteryDetailText, perform: { nv in
                    // This is important.
                    // Make sure the UTF-8 representation of the string does not exceed 150
                    // Otherwise the struct will overflow
                    var safeNv = nv
                    while safeNv.utf8CString.count > 150 {
                        safeNv = String(safeNv.prefix(safeNv.count - 1))
                    }
                    batteryDetailText = safeNv
                    if batteryDetailEnabled {
                        StatusManager.sharedInstance().setBatteryDetail(safeNv)
                    }
                })
                if UIDevice.current.userInterfaceIdiom == .pad {
                    Toggle("Change Status Bar Date Text", isOn: $dateTextEnabled).onChange(of: dateTextEnabled, perform: { nv in
                        if nv {
                            StatusManager.sharedInstance().setDate(dateText)
                        } else {
                            StatusManager.sharedInstance().unsetDate()
                        }
                    })
                    TextField("Status Bar Date Text", text: $dateText).onChange(of: dateText, perform: { nv in
                        // This is important.
                        // Make sure the UTF-8 representation of the string does not exceed 256
                        // Otherwise the struct will overflow
                        var safeNv = nv
                        while safeNv.utf8CString.count > 256 {
                            safeNv = String(safeNv.prefix(safeNv.count - 1))
                        }
                        dateText = safeNv
                        if dateTextEnabled {
                            StatusManager.sharedInstance().setDate(safeNv)
                        }
                    })
                }
                Toggle("Change Status Bar Time Text", isOn: $timeTextEnabled).onChange(of: timeTextEnabled, perform: { nv in
                    if nv {
                        StatusManager.sharedInstance().setTime(timeText)
                    } else {
                        StatusManager.sharedInstance().unsetTime()
                    }
                })
                TextField("Status Bar Time Text", text: $timeText).onChange(of: timeText, perform: { nv in
                    // This is important.
                    // Make sure the UTF-8 representation of the string does not exceed 64
                    // Otherwise the struct will overflow
                    var safeNv = nv
                    while safeNv.utf8CString.count > 64 {
                        safeNv = String(safeNv.prefix(safeNv.count - 1))
                    }
                    timeText = safeNv
                    if timeTextEnabled {
                        StatusManager.sharedInstance().setTime(safeNv)
                    }
                })
            }
            
            Section {
                Toggle("Change Primary Carrier Text", isOn: $carrierTextEnabled).onChange(of: carrierTextEnabled, perform: { nv in
                    if nv {
                        StatusManager.sharedInstance().setCarrier(carrierText)
                    } else {
                        StatusManager.sharedInstance().unsetCarrier()
                    }
                })
                TextField("Primary Carrier Text", text: $carrierText).onChange(of: carrierText, perform: { nv in
                    // This is important.
                    // Make sure the UTF-8 representation of the string does not exceed 100
                    // Otherwise the struct will overflow
                    var safeNv = nv
                    while safeNv.utf8CString.count > 100 {
                        safeNv = String(safeNv.prefix(safeNv.count - 1))
                    }
                    carrierText = safeNv
                    if carrierTextEnabled {
                        StatusManager.sharedInstance().setCarrier(safeNv)
                    }
                })
                Toggle("Change Primary Service Badge Text", isOn: $primaryServiceBadgeTextEnabled).onChange(of: primaryServiceBadgeTextEnabled, perform: { nv in
                    if nv {
                        StatusManager.sharedInstance().setPrimaryServiceBadge(primaryServiceBadgeText)
                    } else {
                        StatusManager.sharedInstance().unsetPrimaryServiceBadge()
                    }
                })
                TextField("Primary Service Badge Text", text: $primaryServiceBadgeText).onChange(of: primaryServiceBadgeText, perform: { nv in
                    // This is important.
                    // Make sure the UTF-8 representation of the string does not exceed 100
                    // Otherwise the struct will overflow
                    var safeNv = nv
                    while safeNv.utf8CString.count > 100 {
                        safeNv = String(safeNv.prefix(safeNv.count - 1))
                    }
                    primaryServiceBadgeText = safeNv
                    if primaryServiceBadgeTextEnabled {
                        StatusManager.sharedInstance().setPrimaryServiceBadge(safeNv)
                    }
                })
                
                Toggle("Change Secondary Carrier Text", isOn: $secondaryCarrierTextEnabled).onChange(of: secondaryCarrierTextEnabled, perform: { nv in
                    if nv {
                        StatusManager.sharedInstance().setSecondaryCarrier(secondaryCarrierText)
                    } else {
                        StatusManager.sharedInstance().unsetSecondaryCarrier()
                    }
                })
                TextField("Secondary Carrier Text", text: $secondaryCarrierText).onChange(of: secondaryCarrierText, perform: { nv in
                    // This is important.
                    // Make sure the UTF-8 representation of the string does not exceed 100
                    // Otherwise the struct will overflow
                    var safeNv = nv
                    while safeNv.utf8CString.count > 100 {
                        safeNv = String(safeNv.prefix(safeNv.count - 1))
                    }
                    secondaryCarrierText = safeNv
                    if secondaryCarrierTextEnabled {
                        StatusManager.sharedInstance().setSecondaryCarrier(safeNv)
                    }
                })
                Toggle("Change Secondary Service Badge Text", isOn: $secondaryServiceBadgeTextEnabled).onChange(of: secondaryServiceBadgeTextEnabled, perform: { nv in
                    if nv {
                        StatusManager.sharedInstance().setSecondaryServiceBadge(secondaryServiceBadgeText)
                    } else {
                        StatusManager.sharedInstance().unsetSecondaryServiceBadge()
                    }
                })
                TextField("Secondary Service Badge Text", text: $secondaryServiceBadgeText).onChange(of: secondaryServiceBadgeText, perform: { nv in
                    // This is important.
                    // Make sure the UTF-8 representation of the string does not exceed 100
                    // Otherwise the struct will overflow
                    var safeNv = nv
                    while safeNv.utf8CString.count > 100 {
                        safeNv = String(safeNv.prefix(safeNv.count - 1))
                    }
                    secondaryServiceBadgeText = safeNv
                    if secondaryServiceBadgeTextEnabled {
                        StatusManager.sharedInstance().setSecondaryServiceBadge(safeNv)
                    }
                })
            }
            
            Section {
                Toggle("Change Battery Icon Capacity", isOn: $batteryCapacityEnabled).onChange(of: batteryCapacityEnabled, perform: { nv in
                    if nv {
                        StatusManager.sharedInstance().setBatteryCapacity(Int32(batteryCapacity))
                    } else {
                        StatusManager.sharedInstance().unsetBatteryCapacity()
                    }
                })
                HStack {
                    Text("\(Int(batteryCapacity))%")
                        .frame(width: 125)
                    Spacer()
                    Slider(value: $batteryCapacity, in: 0...100, step: 1.0)
                        .padding(.horizontal)
                        .onChange(of: batteryCapacity) { nv in
                            StatusManager.sharedInstance().setBatteryCapacity(Int32(nv))
                        }
                }
                
                Toggle("Change WiFi Signal Strength Bars", isOn: $wiFiStrengthBarsEnabled).onChange(of: wiFiStrengthBarsEnabled, perform: { nv in
                    if nv {
                        StatusManager.sharedInstance().setWiFiSignalStrengthBars(Int32(wiFiStrengthBars))
                    } else {
                        StatusManager.sharedInstance().unsetWiFiSignalStrengthBars()
                    }
                })
                HStack {
                    Text("\(Int(wiFiStrengthBars))")
                        .frame(width: 125)
                    Spacer()
                    Slider(value: $wiFiStrengthBars, in: 0...3, step: 1.0)
                        .padding(.horizontal)
                        .onChange(of: wiFiStrengthBars) { nv in
                            StatusManager.sharedInstance().setWiFiSignalStrengthBars(Int32(nv))
                        }
                }
                
                Toggle("Change Cellular Signal Strength Bars", isOn: $gsmStrengthBarsEnabled).onChange(of: gsmStrengthBarsEnabled, perform: { nv in
                    if nv {
                        StatusManager.sharedInstance().setGsmSignalStrengthBars(Int32(gsmStrengthBars))
                    } else {
                        StatusManager.sharedInstance().unsetGsmSignalStrengthBars()
                    }
                })
                HStack {
                    Text("\(Int(gsmStrengthBars))")
                        .frame(width: 125)
                    Spacer()
                    Slider(value: $gsmStrengthBars, in: 0...4, step: 1.0)
                        .padding(.horizontal)
                        .onChange(of: gsmStrengthBars) { nv in
                            StatusManager.sharedInstance().setGsmSignalStrengthBars(Int32(nv))
                        }
                }
            }
            
            Section {
                Toggle("Show Numeric WiFi Strength", isOn: $displayingRawWiFiStrength).onChange(of: displayingRawWiFiStrength, perform: { nv in
                    StatusManager.sharedInstance().displayRawWifiSignal(nv)
                })
                Toggle("Show Numeric Cellular Strength", isOn: $displayingRawGSMStrength).onChange(of: displayingRawGSMStrength, perform: { nv in
                    StatusManager.sharedInstance().displayRawGSMSignal(nv)
                })
            }

            Section (footer: Text("*Will also hide carrier name\n**Will also hide cellular data indicator")) {
                // bruh I had to add a group cause SwiftUI won't let you add more than 10 things to a view?? ok
                Group {
                    Toggle("Hide Status Bar Time", isOn: $clockHidden).onChange(of: clockHidden, perform: { nv in
                        StatusManager.sharedInstance().hideClock(nv)
                    })
                    Toggle("Hide Do Not Disturb", isOn: $DNDHidden).onChange(of: DNDHidden, perform: { nv in
                        StatusManager.sharedInstance().hideDND(nv)
                    })
                    Toggle("Hide Airplane Mode", isOn: $airplaneHidden).onChange(of: airplaneHidden, perform: { nv in
                        StatusManager.sharedInstance().hideAirplane(nv)
                    })
                    Toggle("Hide Cellular*", isOn: $cellHidden).onChange(of: cellHidden, perform: { nv in
                        StatusManager.sharedInstance().hideCell(nv)
                    })
                    Toggle("Hide Wi-Fi**", isOn: $wiFiHidden).onChange(of: wiFiHidden, perform: { nv in
                        StatusManager.sharedInstance().hideWiFi(nv)
                    })
                    if UIDevice.current.userInterfaceIdiom != .pad {
                        Toggle("Hide Battery", isOn: $batteryHidden).onChange(of: batteryHidden, perform: { nv in
                            StatusManager.sharedInstance().hideBattery(nv)
                        })
                    }
                    Toggle("Hide Bluetooth", isOn: $bluetoothHidden).onChange(of: bluetoothHidden, perform: { nv in
                        StatusManager.sharedInstance().hideBluetooth(nv)
                    })
                    Toggle("Hide Alarm", isOn: $alarmHidden).onChange(of: alarmHidden, perform: { nv in
                        StatusManager.sharedInstance().hideAlarm(nv)
                    })
                    Toggle("Hide Location", isOn: $locationHidden).onChange(of: locationHidden, perform: { nv in
                        StatusManager.sharedInstance().hideLocation(nv)
                    })
                    Toggle("Hide Rotation Lock", isOn: $rotationHidden).onChange(of: rotationHidden, perform: { nv in
                        StatusManager.sharedInstance().hideRotation(nv)
                    })
                }
                Toggle("Hide AirPlay", isOn: $airPlayHidden).onChange(of: airPlayHidden, perform: { nv in
                    StatusManager.sharedInstance().hideAirPlay(nv)
                })
                Toggle("Hide CarPlay", isOn: $carPlayHidden).onChange(of: carPlayHidden, perform: { nv in
                    StatusManager.sharedInstance().hideCarPlay(nv)
                })
                Toggle("Hide VPN", isOn: $VPNHidden).onChange(of: VPNHidden, perform: { nv in
                    StatusManager.sharedInstance().hideVPN(nv)
                })
            }
            
            if #available(iOS 15.0, *) {
                Section (footer: Text("Go here if something isn't working correctly.")) {
                    NavigationLink(destination: SettingsView(), label: { Text("Settings") })
                }
            }
            
            Section (footer: Text("Your device will respring.\n\n\nApplying using \(StatusManager.sharedInstance().isMDCMode() ? "MacDirtyCOW" : "TrollStore").")) {
                Button("Reset All") {
                    if fm.fileExists(atPath: "/var/mobile/Library/SpringBoard/statusBarOverrides") {
                        do {
                            try fm.removeItem(at: URL(fileURLWithPath: "/var/mobile/Library/SpringBoard/statusBarOverrides"))
                            restartFrontboard()
                        } catch {
                            UIApplication.shared.alert(body: "\(error)")
                        }
                        
                    }
                }
            }
        }
        .navigationTitle("Status Bar")
    }
}

struct StatusBarView_Previews: PreviewProvider {
    static var previews: some View {
        StatusBarView()
    }
}
