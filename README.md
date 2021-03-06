![Language](https://img.shields.io/badge/Swift-%204.2%20-663399.svg?style=plastic)
![Platform](https://img.shields.io/badge/Platform-ios-ff8100.svg?style=plastic)
![Pods](https://img.shields.io/badge/Cocoapods-compatible-2ad403.svg?style=plastic)
![Carthage](https://img.shields.io/badge/Carthage-compatible-2ad403.svg?style=plastic)
![License](https://img.shields.io/badge/License-MIT-000000.svg?style=plastic)

# VidLoader

## Description

*VidLoader* is a framework used to download HLS streams. The main purpose of this library is to explain how to download  an encrypted stream through *AVFoundation* and play it without internet connection. It has as a base the process described on the [Stack Overflow](https://stackoverflow.com/questions/45670774/playing-offline-hls-with-aes-128-encryption-ios/45957045#45957045).  

The library can also be used in the projects through Carthage, CocoaPods or added manually.  

To check how everything works you can run the *VidLoaderExample*, install pods and set up URL for the master **.m3u8** file in the `VideoListDataProvider` -> `generateDefaultItems` -> `defaultURL` property.

This library works with **.m3u8 master** file that looks like:

```
#EXTM3U
#EXT-X-STREAM-INF:PROGRAM-ID=1,BANDWIDTH=1697588,RESOLUTION=1280x720,FRAME-RATE=23.980,CODECS="mp4a"
https://.../playlist_1
#EXT-X-STREAM-INF:PROGRAM-ID=1,BANDWIDTH=1132382,RESOLUTION=848x480,FRAME-RATE=23.980,CODECS="mp4a"
https://.../playlist_2
#EXT-X-STREAM-INF:PROGRAM-ID=1,BANDWIDTH=690409,RESOLUTION=640x360,FRAME-RATE=23.980,CODECS="mp4a"
https://.../playlist_3
```
*VidLoader* will download **.m3u8 master** file and will send it to the `AVAssetDownloadURLSession`.
After this, the session will select the most optimal playlist for the device, then the library will make a request with the selected URL, the **.m3u8 playlist** will look like this:

```
#EXTM3U
#EXT-X-TARGETDURATION:12
#EXT-X-ALLOW-CACHE:YES
#EXT-X-KEY:METHOD=AES-128,URI="https://.../encryption_key”
#EXT-X-VERSION:3
#EXT-X-MEDIA-SEQUENCE:1
#EXTINF:6.006,
https://.../chunk_1
#EXTINF:4.713,
https://.../chunk_2
#EXTINF:10.093,
https://.../chunk_3
#EXT-X-ENDLIST
```

*VidLoader* final step is to request encryption key from URL and to save it in the **.m3u8 playlist**. Next time when the video player will request the key, it will be extracted from the local playlist file instead of doing request.  

The sketchy description how *VidLoader* works is represented in the next diagram:

![Diagram](Assets/sequance_diagram.jpeg)

## Requirements

- iOS 12.0+  
- A device, <span style="color:red">AVAssetDownloadURLSession doesn't work on the simulator</span>

## Installation

### CocoaPods

To integrate *VidLoader* into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ObjC
pod 'VidLoader', :git => 'https://github.com/Cyklet/VidLoader.git', :tag => #tag
```

Then, run the following command:

```bash
$ pod install
```

### Carthage

To integrate *VidLoader* into your Xcode project using Carthage, specify it in your `Cartfile`:

```ObjC
github "Cyklet/VidLoader" ~> #tag
```

Run `carthage update` to build the framework and drag the built `VidLoader.framework` into your Xcode project.

### Manually

If you prefer not to use dependency managers, you can integrate *VidLoader* into your project manually.

## Usage

To use the library, it is suggested to create a singleton of *VidLoader* class (each *VidLoader* instance will have the same session identifier that can lead to unexpected behavior in case of multiple instances) and access public functions of it:
- `observe(with observer: VidObserver?) `: add an observer that will be called when the state of an item changes;
- `remove(observer: VidObserver?)`: remove observer from observers list;
- `download(identifier: String, url: URL, title: String, artworkData: Data?)`: call this method to start item download;
- `cancel(identifier: String)`: call cancel method when download must be stoped;
- `state(for identifier: String) -> DownloadState`: get current download state of the item, if downloader doesn't have any information about it, the state will be **unknown**;
- `asset(location: URL) -> AVURLAsset?`: returns AVURLAsset that will provide the encryption key when video player will demand. The AVAssetResourceLoaderDelegate of the asset will be handled in *VidLoader* framework;
- `cancelActiveItems()`: cancel all active items that are currently downloading or preparing to download;
- `enableMobileDataAccess()`: enable mobile data download availability, if the user has only mobile data connection, download will continue;
- `disableMobileDataAccess()`:  disable mobile data download availability, if the user has only mobile data connection, download will be paused;

## Configurations

| Configurations
| --- |
| `isMobileDataEnabled` - A property that represents if the user accepts to download streams with mobile data.|
| `maxConcurrentDownloads` - Maximal numbers of streams that will be downloaded at the same time. Please take into consideration, if you increase this number the downloads may start failing because of the *AVAssetDownloadURLSession* limitations.|

## License

MIT License, Copyright (c) 2019 [Petre Plotnic](https://www.linkedin.com/in/petre-plotnic/)
