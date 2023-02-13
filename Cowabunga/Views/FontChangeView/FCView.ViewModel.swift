//
//  FCView.ViewModel.swift
//  WDBFontOverwrite
//
//  Created by Noah Little (@ginsudev) on 31/12/2022.
//

import Foundation

enum PathType {
    case single(String)
    case many([String])
}

enum Notice: String {
    case iosVersion = "iOS version not supported. Don't ask us to support newer versions because the exploit used just simply does not support newer iOS versions."
    case beforeUse = "Custom fonts require font files that are ported for iOS. See https://github.com/ginsudev/WDBFontOverwrite for details."
    case keyboard = "Keyboard fonts may not be applied immediately due to iOS caching issues. IF POSSIBLE, remove the folder /var/mobile/Library/Caches/com.apple.keyboards/ if you wish for changes to take effect immediately."
}

extension FCView {
    struct FontToReplace {
        var name: String
        var postScriptName: String
        var repackedPath: String
    }
    
    struct CustomFont {
        var name: String
        var targetPath: PathType?
        var localPath: String
        var alternativeTTCRepackMode: TTCRepackMode?
        var notice: Notice?
    }
    
    final class ViewModel: ObservableObject {
        @Published var fontListSelection: Int = 0
        @Published var customFontPickerSelection: Int = 0
        @Published var message = "Choose a font."
        @Published var progress: Progress!
        @Published var importPresented: Bool = false
        @Published var importName: String = ""
        @Published var importTTCRepackMode: TTCRepackMode = .woff2
        
        var selectedCustomFont: CustomFont {
            return customFonts[customFontPickerSelection]
        }
        
        let fonts = [
            FontToReplace(
                name: "DejaVu Sans Condensed",
                postScriptName: "DejaVuSansCondensed",
                repackedPath: "DejaVuSansCondensed.woff2"
            ),
            FontToReplace(
                name: "DejaVu Serif",
                postScriptName: "DejaVuSerif",
                repackedPath: "DejaVuSerif.woff2"
            ),
            FontToReplace(
                name: "DejaVu Sans Mono",
                postScriptName: "DejaVuSansMono",
                repackedPath: "DejaVuSansMono.woff2"
            ),
            FontToReplace(
                name: "Go Regular",
                postScriptName: "GoRegular",
                repackedPath: "Go-Regular.woff2"
            ),
            FontToReplace(
                name: "Go Mono",
                postScriptName: "GoMono",
                repackedPath: "Go-Mono.woff2"
            ),
            FontToReplace(
                name: "Fira Sans",
                postScriptName: "FiraSans-Regular",
                repackedPath: "FiraSans-Regular.2048.woff2"
            ),
            FontToReplace(
                name: "Segoe UI",
                postScriptName: "SegoeUI",
                repackedPath: "segoeui.woff2"
            ),
            FontToReplace(
                name: "Comic Sans MS",
                postScriptName: "ComicSansMS",
                repackedPath: "Comic Sans MS.woff2"
            ),
            FontToReplace(
                name: "Choco Cooky",
                postScriptName: "Chococooky",
                repackedPath: "Chococooky.woff2"
            ),
        ]

        let customFonts = [
            CustomFont(
                name: "SFUI.ttf",
                targetPath: .single("/System/Library/Fonts/CoreUI/SFUI.ttf"),
                localPath: "CustomSFUI.woff2",
                alternativeTTCRepackMode: .ttcpad
            ),
            CustomFont(
                name: "Emoji",
                targetPath: .many([
                    "/System/Library/Fonts/CoreAddition/AppleColorEmoji-160px.ttc",
                    "/System/Library/Fonts/Core/AppleColorEmoji.ttc",
                ]),
                localPath: "CustomAppleColorEmoji.woff2"
            ),
            CustomFont(
                name: "SFUISoft.ttc",
                targetPath: .single("/System/Library/Fonts/CoreUI/SFUISoft.ttc"),
                localPath: "CustomSFUISoft.woff2",
                alternativeTTCRepackMode: .ttcpad
            ),
            CustomFont(
                name: "PingFang.ttc",
                targetPath: .single("/System/Library/Fonts/LanguageSupport/PingFang.ttc"),
                localPath: "CustomPingFang.woff2",
                alternativeTTCRepackMode: .ttcpad
            ),
            CustomFont(
                name: "Keycaps.ttc",
                targetPath: .single("/System/Library/Fonts/CoreAddition/Keycaps.ttc"),
                localPath: "CustomKeycaps.woff2",
                alternativeTTCRepackMode: .ttcpad,
                notice: .keyboard
            ),
            CustomFont(
                name: "KeycapsPad.ttc",
                targetPath: .single("/System/Library/Fonts/CoreAddition/KeycapsPad.ttc"),
                localPath: "CustomKeycapsPad.woff2",
                alternativeTTCRepackMode: .ttcpad,
                notice: .keyboard
            ),
            CustomFont(
                name: "PhoneKeyCaps.ttf",
                targetPath: .single("/System/Library/Fonts/CoreAddition/PhoneKeyCaps.ttf"),
                localPath: "CustomPhoneKeyCaps.woff2",
                alternativeTTCRepackMode: .ttcpad,
                notice: .keyboard
            )
        ]
    }
}
