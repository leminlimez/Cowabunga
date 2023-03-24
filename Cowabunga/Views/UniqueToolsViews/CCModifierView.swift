//
//  CCModifierView.swift
//  Cowabunga
//
//  Created by lemin on 2/22/23.
//

import SwiftUI

struct CCModifierView: View {
    let defaultSize: CGFloat = 75
    let spacing: CGFloat = 10
    
    @State var modules: [CCModuleViewable] = [
    ]
    
    var body: some View {
        let gridItems = [GridItem(.fixed(defaultSize), spacing: spacing, alignment: .leading),
                                 GridItem(.fixed(defaultSize), spacing: spacing, alignment: .leading),
                                 GridItem(.fixed(defaultSize), spacing: spacing, alignment: .leading),
                                 GridItem(.fixed(defaultSize), spacing: spacing, alignment: .leading)]
        
        VStack {
            LazyVGrid(columns: gridItems, spacing: 10) {
                ForEach($modules) { module in
                    CCColumn(span: module.widthVal.wrappedValue) {
                        CCModuleElement(
                            width: module.width.wrappedValue,
                            height: module.height.wrappedValue,
                            singleSize: defaultSize,
                            icon: module.icon.wrappedValue,
                            visible: !module.isInvisible.wrappedValue,
                            type: module.type.wrappedValue
                        )
                    }
                }
            }
            .frame(width: 470)
        }
        .onAppear {
            generateModules()
        }
    }
    
    func fillGridIndexes(blanks: [Int: Int], ind: Int) -> Int {
        if blanks[ind] != nil {
            modules.append(.init(width: defaultSize, height: defaultSize, widthVal: 1, isInvisible: true, icon: "", type: .invis, attachmentIndex: blanks[ind] ?? 0))
            return fillGridIndexes(blanks: blanks, ind: ind + 1)
        } else {
            return ind
        }
    }
    
    func generateModules() {
        let newModules = CCModifierManager.getModules()
        var gIdx: Int = 0
        var blankIdx: [Int: Int] = [:]
        for newModule in newModules {
            gIdx = fillGridIndexes(blanks: blankIdx, ind: gIdx)
            if newModule.height > 1 {
                for h in 1...newModule.height-1 {
                    for w in 1...newModule.width {
                        blankIdx[(gIdx + h*4 + (w-1))] = gIdx
                    }
                }
            }
            let w = CGFloat((Int(defaultSize)*newModule.width) + (Int(spacing)*(newModule.width - 1)))
            let h = CGFloat((Int(defaultSize)*newModule.height) + (Int(spacing)*(newModule.height - 1)))
            modules.append(.init(width: w, height: h, widthVal: newModule.width, isInvisible: (newModule.type == .invis), icon: newModule.icon, type: newModule.type, attachmentIndex: gIdx))
            gIdx += newModule.width
        }
        // create the blanks
//        for (i, module) in modules.enumerated() {
//            if module.height > 1 {
//                var point: Int = 1
//                for j in 1...module.height - 1 {
//
//                }
//            }
//        }
    }
}

struct CCColumn<Content: View>: View {
    let span: Int
    let content: () -> Content
    
    init(span: Int, @ViewBuilder content: @escaping () -> Content) {
        self.span = span
        self.content = content
    }
    
    var body: some View {
        content()
        
        if span > 1 {
            ForEach((1...span-1), id: \.self) {_ in
                Color.clear
            }
        }
    }
}

struct CCModuleElement: View {
    let width: CGFloat
    let height: CGFloat
    let singleSize: CGFloat
    
    let icon: String
    let visible: Bool
    let type: ModuleType
    
    let connectivityLayout: [GridItem] = [GridItem(.adaptive(minimum: 75, maximum: 75))]
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color(uiColor14: .secondarySystemBackground))
                .frame(width: width, height: height)
                .opacity(visible ? 1 : 0)
            
            // visuals
            // MARK: Regular
            if type == .regular {
                Image(systemName: icon)
                    .font(.system(size: 25))
            
            // MARK: Slider
            } else if type == .slider {
                VStack {
                    Spacer()
                    Image(systemName: icon)
                        .padding(.bottom, (singleSize/2) - 10)
                        .font(.system(size: 22))
                }
            
            // MARK: Focus
            } else if type == .focus {
                HStack {
                    ZStack {
                        Circle()
                            .frame(width: singleSize - 20)
                            .foregroundColor(.secondary)
                        Image(systemName: icon)
                            .font(.system(size: 20))
                    }
                    .padding(.leading, 15)
                    Text("Focus")
                        .padding(.leading, 5)
                    Spacer()
                }
                
            // MARK: Connectivity
            } else if type == .quick {
                LazyHGrid(rows: connectivityLayout, alignment: .center, spacing: 10) {
                    ForEach(1..<5) { ind in
                        ZStack {
                            Circle()
                                .frame(width: singleSize - 20, height: singleSize - 20)
                                .foregroundColor(.secondary)
                            if ind == 1 {
                                Image(systemName: "airplane")
                                    .font(.system(size: 20))
                            } else if ind == 2 {
                                Image(systemName: "wifi")
                                    .font(.system(size: 20))
                            } else if ind == 3 {
                                Image(systemName: "antenna.radiowaves.left.and.right")
                                    .font(.system(size: 25))
                            } else if ind == 4 {
                                Image("logo.bluetooth")
                                    .font(.system(size: 25))
                            }
                        }
                        .padding(5)
                    }
                }
                .frame(width: width, height: height)
                
            // MARK: Music
            } else if type == .music {
                ZStack {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "text.line.first.and.arrowtriangle.forward")
                                .padding(10)
                        }
                        Spacer()
                    }
                    
                    VStack {
                        Text("Not Playing")
                            .bold()
                            .foregroundColor(.secondary)
                            .padding(.top, 30)
                        Spacer()
                        HStack {
                            Image(systemName: "backward.fill")
                                .foregroundColor(.secondary)
                                .padding(.leading, 20)
                            Spacer()
                            Image(systemName: "play.fill")
                                .font(.system(size: 25))
                            Spacer()
                            Image(systemName: "forward.fill")
                                .foregroundColor(.secondary)
                                .padding(.trailing, 20)
                        }
                        .padding(.bottom, 30)
                    }
                }
            }
        }
            .cornerRadius(20)
            .frame(width: width, height: singleSize)
            .offset(y: (height > singleSize ? singleSize*CGFloat(Int(height/singleSize)-1) - 30*CGFloat(Int(height/singleSize)-1) : 0))
            
    }
}

struct CCModifierView_Previews: PreviewProvider {
    static var previews: some View {
        CCModifierView()
    }
}
