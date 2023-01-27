//
//  LSFootnoteChangerView.swift
//  TrollTools
//
//  Created by LeminLimez on 12/15/22.
//

import SwiftUI

struct LSFootnoteChangerView: View {
    @State var footnoteText = ""
    @State var footnoteOffset: CGFloat = .zero
    @State var footnoteSize: [CGFloat] = [.zero, .zero]
    
    var sharedDeviceConfigPath = "/var/containers/Shared/SystemGroup/systemgroup.com.apple.configurationprofiles/Library/ConfigurationProfiles"
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                ZStack(alignment: .center) {
                    Image("lockscreen")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom)
                        .background(GeometryReader { (geometry) -> Color in
                            DispatchQueue.main.async {
                                // set the footnote textbox size
                                footnoteSize[0] = geometry.size.width/3
                                footnoteSize[1] = geometry.size.height/25
                                
                                // set the footnote textbox offset
                                footnoteOffset = -geometry.size.height/2 + (870/990) * geometry.size.height + footnoteSize[1]/2
                            }
                        return .clear
                    })
                    TextField("Footnote", text: $footnoteText)
                        .foregroundColor(.white)
                        .offset(x: 0, y: footnoteOffset)
                        .frame(width: footnoteSize[0], height: footnoteSize[1], alignment: .center)
                        .multilineTextAlignment(.center)
                }
            }
        }
        //.ignoresSafeArea(.keyboard, edges: .bottom)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    do {
                        let url = URL(fileURLWithPath: sharedDeviceConfigPath + "/SharedDeviceConfiguration.plist")
                        
                        var plistData: Data
                        if !FileManager.default.fileExists(atPath: url.path) {
                            plistData = try PropertyListSerialization.data(fromPropertyList: ["LockScreenFootnote": footnoteText], format: .xml, options: 0)
                        } else {
                            guard let data = try? Data(contentsOf: url), var plist = try PropertyListSerialization.propertyList(from: data, format: nil) as? [String:Any] else { throw "Couldn't read SharedDeviceConfiguration.plist" }
                            plist["LockScreenFootnote"] = footnoteText
                            
                            // Save plist
                            plistData = try PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0)
                            UserDefaults.standard.set(footnoteText, forKey: "LSFootnoteText")
                        }
                        
                        // write to file
                        do {
                            try plistData.write(to: url)
                        } catch {
                            print("error replacing plist")
                            UIApplication.shared.alert(body: "Could not replace footnote data!")
                        }
                    } catch {
                        UIApplication.shared.alert(body: "\(error)")
                    }
                }) {
                    Image(systemName: "checkmark")
                }
            }
        }
        .onAppear {
            footnoteText = UserDefaults.standard.string(forKey: "LSFootnoteText") ?? ""
        }
        .navigationTitle("Lock Screen Footnote Changer")
    }
}

struct LSFootnoteChangerView_Previews: PreviewProvider {
    static var previews: some View {
        LSFootnoteChangerView()
    }
}
