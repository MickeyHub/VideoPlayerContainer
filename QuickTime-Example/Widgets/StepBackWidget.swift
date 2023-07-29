//
//  StepBackWidget.swift
//  Youtube-Example
//
//  Created by shayanbo on 2023/7/1.
//

import SwiftUI
import VideoPlayerContainer

fileprivate class StepBackwardWidgetService: Service {
    
    private var observation: NSKeyValueObservation?
    
    @ViewState var enabled = false
        
    required init(_ context: Context) {
        super.init(context)
        
        let player = context[RenderService.self].player
        observation = player.observe(\.currentItem) { [weak self] player, changes in
            guard let item = player.currentItem else { return }
            self?.enabled = item.canStepBackward
        }
    }
    
    func stepBackward() {
        let player = context[RenderService.self].player
        player.currentItem?.step(byCount: -30 * 5)
        player.play()
    }
}

struct StepBackWidget: View {
    var body: some View {
        WithService(StepBackwardWidgetService.self) { service in
            Image(systemName: "backward.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 25, height: 25)
                .foregroundColor(.white)
                .disabled(!service.enabled)
                .onTapGesture {
                    service.stepBackward()
                }
        }
    }
}
