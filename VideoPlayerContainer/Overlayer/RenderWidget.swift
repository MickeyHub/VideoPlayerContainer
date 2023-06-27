//
//  RenderWidget.swift
//  VideoPlayer
//
//  Created by shayanbo on 2023/6/15.
//

import Foundation
import SwiftUI
import AVKit
#if os(iOS) || os(watchOS) || os(tvOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

public class RenderService : Service {
    
    @ViewState fileprivate var gravity: AVLayerVideoGravity = .resizeAspect
    
    @StateSync(serviceType: FeatureService.self, keyPath: \.$feature) fileprivate var feature
    
    public let player = AVPlayer()
    
    public func fill() {
        gravity = .resizeAspectFill
    }
    
    public func fit() {
        gravity = .resizeAspect
    }
}

struct RenderWidget : View {
    
    var body: some View {
        WithService(RenderService.self) { service in
            HStack {
                if let feature = service.feature, feature.direction == .left(.squeeze) {
                    AnyView(
                        feature.viewGetter()
                            .frame(maxHeight: .infinity)
                            .transition(.move(edge: .leading))
                    )
                }
                
                ZStack {
                    RenderView(player: service.player, gravity: service.gravity)
                    GestureWidget()
                }
                
                if let feature = service.feature, feature.direction == .right(.squeeze) {
                    AnyView(
                        feature.viewGetter()
                            .frame(maxHeight: .infinity)
                            .transition(.move(edge: .trailing))
                    )
                }
            }
        }
    }
}

#if os(iOS) || os(watchOS) || os(tvOS)

struct RenderView : UIViewRepresentable {

    let player: AVPlayer
    let gravity: AVLayerVideoGravity
    
    func makeUIView(context: UIViewRepresentableContext<Self>) -> PlayerView {
        let playerView = PlayerView()
        playerView.player = player
        playerView.videoGravity = gravity
        return playerView
    }

    func updateUIView(_ uiView: PlayerView, context: UIViewRepresentableContext<Self>) {
        uiView.videoGravity = gravity
    }
}

class PlayerView: UIView {
    
    var videoGravity: AVLayerVideoGravity {
        get {
            let canvas = self.layer as! AVPlayerLayer
            return canvas.videoGravity
        }
        set {
            let canvas = self.layer as! AVPlayerLayer
            canvas.videoGravity = newValue
        }
    }
    
    var player: AVPlayer? {
        didSet {
            let canvas = self.layer as! AVPlayerLayer
            canvas.player = player
        }
    }
    
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
}

#elseif os(macOS)

struct RenderView : NSViewRepresentable {
    
    let player: AVPlayer
    let gravity: AVLayerVideoGravity
    
    func makeNSView(context: NSViewRepresentableContext<Self>) -> PlayerView {
        let playerView = PlayerView()
        playerView.player = player
        playerView.videoGravity = gravity
        return playerView
    }

    func updateNSView(_ uiView: PlayerView, context: NSViewRepresentableContext<Self>) {
        uiView.videoGravity = gravity
    }
}

class PlayerView: NSView {
    
    let renderCanvas = AVPlayerLayer()
    
    init() {
        super.init(frame: .zero)
        wantsLayer = true
        renderCanvas.frame = bounds
        renderCanvas.autoresizingMask = [.layerHeightSizable, .layerWidthSizable]
        layer?.addSublayer(renderCanvas)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var videoGravity: AVLayerVideoGravity {
        get {
            return renderCanvas.videoGravity
        }
        set {
            renderCanvas.videoGravity = newValue
        }
    }
    
    var player: AVPlayer? {
        didSet {
            renderCanvas.player = player
        }
    }
}

#endif
