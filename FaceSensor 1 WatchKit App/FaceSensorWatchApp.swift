//
//  FaceSensorWatchApp.swift
//  FaceSensor 1 WatchKit App
//

import SwiftUI

@main
struct FaceSensorWatchApp: App {
    @State private var model = WatchSensorModel()

    var body: some Scene {
        WindowGroup {
            SensorFaceView(model: model)
                .task { model.start() }
        }
    }
}
