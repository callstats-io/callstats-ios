//
//  CsioRTCVideoView.swift
//  demo
//
//  Created by Amornchai Kanokpullwad on 5/20/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import UIKit
import WebRTC

class CsioRTCVideoView: UIView, RTCEAGLVideoViewDelegate {
    
    public let remoteVideoView: RTCEAGLVideoView
    public let localVideoView: RTCCameraPreviewView
    private var remoteVideoSize = CGSize.zero
    
    override public init(frame: CGRect) {
        remoteVideoView = RTCEAGLVideoView(frame: CGRect.zero)
        localVideoView = RTCCameraPreviewView(frame: CGRect.zero)
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        remoteVideoView = RTCEAGLVideoView(frame: CGRect.zero)
        localVideoView = RTCCameraPreviewView(frame: CGRect.zero)
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        (localVideoView.layer as? AVCaptureVideoPreviewLayer)?.videoGravity = .resizeAspectFill
        clipsToBounds = true
        addSubview(remoteVideoView)
        addSubview(localVideoView)
        remoteVideoView.delegate = self
    }
    
    public func setLocalCaptureSession(session: AVCaptureSession) {
        localVideoView.captureSession = session
        remoteVideoView.removeFromSuperview()
    }
    
    override open func layoutSubviews() {
        if remoteVideoSize.width > 0 && remoteVideoSize.height > 0 {
            // Aspect fill remote video into bounds.
            var remoteVideoFrame = AVMakeRect(aspectRatio: remoteVideoSize, insideRect: bounds)
            var scale: CGFloat = 1.0
            let wDif = bounds.size.width - remoteVideoFrame.size.width
            let hDif = bounds.size.height - remoteVideoFrame.size.height
            if wDif > hDif {
                // Scale by width.
                scale = bounds.size.width / remoteVideoFrame.size.width
            } else {
                // Scale by height.
                scale = bounds.size.height / remoteVideoFrame.size.height
            }
            remoteVideoFrame.size.height *= scale
            remoteVideoFrame.size.width *= scale
            remoteVideoView.frame = remoteVideoFrame
            remoteVideoView.center = CGPoint(x: bounds.midX, y: bounds.midY)
        } else {
            remoteVideoView.frame = bounds
        }
        localVideoView.frame = bounds
    }
    
    // RTCEAGLVideoViewDelegate
    
    func videoView(_ videoView: RTCVideoRenderer, didChangeVideoSize size: CGSize) {
        if videoView === remoteVideoView {
            remoteVideoSize = size
        }
        setNeedsLayout()
    }
}
