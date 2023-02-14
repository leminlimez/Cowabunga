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
    @State private var timeText: String = StatusManager.sharedInstance().getTimeOverride()
    @State private var timeTextEnabled: Bool = StatusManager.sharedInstance().isTimeOverridden()
    @State private var crumbText: String = StatusManager.sharedInstance().getCrumbOverride()
    @State private var crumbTextEnabled: Bool = StatusManager.sharedInstance().isCrumbOverridden()
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
                Toggle("Change Carrier Text", isOn: $carrierTextEnabled).onChange(of: carrierTextEnabled, perform: { nv in
                    if nv {
                        StatusManager.sharedInstance().setCarrier(carrierText)
                    } else {
                        StatusManager.sharedInstance().unsetCarrier()
                    }
                })
                TextField("Carrier Text", text: $carrierText).onChange(of: carrierText, perform: { nv in
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
