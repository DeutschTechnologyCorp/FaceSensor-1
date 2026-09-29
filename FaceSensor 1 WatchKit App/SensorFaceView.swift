//
//  SensorFaceView.swift
//  FaceSensor 1 WatchKit App
//

import SwiftUI

/// The watch version of the iPhone screen: the logo pulses to the iPhone's size at each reading.
struct SensorFaceView: View {
    let model: WatchSensorModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Image("logo size 9:17:17")
            .resizable()
            .scaledToFit()
            // The iPhone logo is 341 of 414 points wide at rest; keep that proportion.
            .containerRelativeFrame(.horizontal) { width, _ in width * 341 / 414 }
            .keyframeAnimator(initialValue: model.scale, trigger: model.pulse) { content, scale in
                content.scaleEffect(scale)
            } keyframes: { _ in
                // As on the iPhone: back to full size, then spring to the new size with the same
                // initial kick. With Reduce Motion on, the logo goes straight to its new size.
                KeyframeTrack {
                    MoveKeyframe(reduceMotion ? model.scale : 1.0)
                    SpringKeyframe(model.scale, duration: 1,
                                   spring: Spring(settlingDuration: 1, dampingRatio: model.scale < 0.5 ? 0.6 : 0.5),
                                   startVelocity: reduceMotion ? 0 : (model.scale - 1) * 5)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .accessibilityLabel("F S")
            .background(.black)
    }
}

#Preview("Before a face") {
    SensorFaceView(model: WatchSensorModel())
}

#Preview("Close") {
    let model = WatchSensorModel()
    model.receive(SensorUpdate(message: ["launch": "preview", "cycle": 1, "scale": 1.2]))
    return SensorFaceView(model: model)
}

#Preview("Far") {
    let model = WatchSensorModel()
    model.receive(SensorUpdate(message: ["launch": "preview", "cycle": 1, "scale": 0.4]))
    return SensorFaceView(model: model)
}
