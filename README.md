![Artboard](https://user-images.githubusercontent.com/52459150/215552092-9dc1e029-da35-43da-867f-17279e3dc180.png)
# Cowabunga
A Jailed toolbox application for iOS 14.0-15.7.1 and 16.0-16.1.2 using [CVE-2022-46689](https://support.apple.com/en-us/HT213530).

Enable Notifications and set Location Services to **Always** to keep the app running in the background, keep the dock and folder background hidden, and prevent some sound effects from reverting.

Warning: Some changes are permanent on iOS 14.0-14.8.1

IPA available in the [Releases](https://github.com/leminlimez/DockHider/releases) section.

## Features
- Running in the background to keep some changes from reverting
    - From running tests, battery loss is negligible (~1% per day on frequent), but that may very

- Springboard
    - Hide dock
    - Hide home bar
    - Hide folder backgrounds
    - Disable folder background blur
    - Disable app switcher blur

- Audio
    - Custom sound effects
    - Upload your own sounds (nearly every audio format allowed!)

- Passcode
    - Customize passcode keys
    - Import passcode keys files (.passthm) from TrollTools

- Misc
    - Custom carrier name
    Warning: Use the features below at your own risk!
    - Change system version (shows in settings, iOS 15+)
    - Enable iPhone X Gestures
    - Enable Dynamic Island (iOS 16+)

- Extra Tools
    - Lock Screen Footnote
    - Supervise Device
    - Device Organization Name
    - No Lock On Respring
    - Numeric Wi-Fi/Cellular Strength

## Screenshots
<img src="/Images/Home.PNG" width="300" height="650"/> <img src="/Images/Tools.PNG" width="300" height="650"/> <img src="/Images/SpringboardTools.PNG" width="300" height="650"/> <img src="/Images/Audio_Changer.PNG" width="300" height="650"/>
<img src="/Images/Passcode_Editor.PNG" width="300" height="650"/> <img src="/Images/LS_Footnote.PNG" width="300" height="650"/> <img src="/Images/Misc.PNG" width="300" height="650"/> <img src="/Images/Extra_Tools.PNG" width="300" height="650"/>

## Installing
You can install through AltStore, Sideloadly, Xcode, or TrollStore (if your device supports it)

## Building
Just build like a normal Xcode project. Sign using your own team and bundle identifier. You can also build the IPA file with `ipabuild.sh`.

## Credits
- [TrollTools](https://github.com/sourcelocation/TrollTools) for ipabuild.command, carrier changer logic, alerts UI, and update inbounds message.
- [FontOverwrite](https://github.com/ginsudev/WDBFontOverwrite) for exploit code.
- [SourceLocation](https://github.com/sourcelocation) for the redesigned springboard UI and background services.
- [BomberFish](https://github.com/BomberFish) for AirPower sound.
- [c22dev](https://github.com/c22dev) for fixing AirPower and some included audios.
- [DynamicCow](https://github.com/matteozappia/DynamicCow) for DynamicIsland tweak + improved plist function.
- [Evyrest](https://github.com/sourcelocation/Evyrest) for location based background running.

## Suggestions and support
You can either create an issue on this GitHub repo, or join our [Discord server](https://discord.gg/VyVcNjRMeg) where us, or other members, might help you.
