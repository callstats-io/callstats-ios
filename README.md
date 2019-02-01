CallStats for iOS
===========================

[Callstats](https://www.callstats.io/) WebRTC analytic library for iOS.

## Getting started
### Cocoapods
```
pod 'Callstats'
```

### Create Callstats object
```swift
callstats = Callstats(
    appID: appID, // Application ID from Callstats
    localID: localID, // current user ID
    deviceID: deviceID, // unique device ID
    jwt: jwt, // jwt from server for authentication
    username: username) // (Optional) user alias
```

### Send events
When starting the call, call `startSession` with room identifier
```swift
callstats.startSession(confID: room)
```

These events need to be forwarded to the library in order to start tracking the call. Add followings into your WebRTC `RTCPeerConnectionDelegate` For example:
```swift
func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {
    callstats.reportEvent(remoteUserID: peerId, event: CSIceConnectionChangeEvent(state: newState))
}

func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {
    callstats.reportEvent(remoteUserID: peerId, event: CSIceGatheringChangeEvent(state: newState))
}

func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {
    callstats.reportEvent(remoteUserID: peerId, event: CSSignalingChangeEvent(state: stateChanged))
}
```

And when call finished
``` swift
callstats.stopSession()
```

You can take a look at how to send more events in demo application.
