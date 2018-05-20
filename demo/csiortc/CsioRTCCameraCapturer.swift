//
//  CsioCameraCapturer.swift
//  demo
//
//  Created by Amornchai Kanokpullwad on 5/20/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import Foundation
import WebRTC

class CsioRTCCameraCapturer: RTCCameraVideoCapturer {
    
    func startCapture() {
        let position = AVCaptureDevice.Position.front
        let device = findDeviceForPosition(position: position)
        let format = selectFormatForDevice(device: device)
        let fps = selectFpsForFormat(format: format)
        startCapture(with: device, format: format, fps: Int(fps))
    }
    
    // Mark: -
    
    private func findDeviceForPosition(position: AVCaptureDevice.Position) -> AVCaptureDevice {
        let devices = RTCCameraVideoCapturer.captureDevices()
        for device in devices {
            if device.position == position {
                return device
            }
        }
        return devices[0]
    }
    
    private func selectFormatForDevice(device: AVCaptureDevice) -> AVCaptureDevice.Format {
        let formats = RTCCameraVideoCapturer.supportedFormats(for: device)
        let targetWidth: Int32 = 800
        let targetHeight: Int32 = 600
        var selectedFormat: AVCaptureDevice.Format?
        var currentDiff = INT_MAX;
        for format in formats {
            let dimension = CMVideoFormatDescriptionGetDimensions(format.formatDescription)
            let pixelFormat = CMFormatDescriptionGetMediaSubType(format.formatDescription)
            let diff = abs(targetWidth - dimension.width) + abs(targetHeight - dimension.height)
            if diff < currentDiff {
                selectedFormat = format
                currentDiff = diff
            } else if diff == currentDiff && pixelFormat == preferredOutputPixelFormat() {
                selectedFormat = format
            }
        }
        return selectedFormat!;
    }
    
    private func selectFpsForFormat(format: AVCaptureDevice.Format) -> Float64 {
        var maxFramerate: Float64 = 0;
        for fpsRange in format.videoSupportedFrameRateRanges {
            maxFramerate = fmax(maxFramerate, fpsRange.maxFrameRate);
        }
        return maxFramerate;
    }
}
