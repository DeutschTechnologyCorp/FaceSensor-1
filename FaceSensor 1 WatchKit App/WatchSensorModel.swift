//
//  WatchSensorModel.swift
//  FaceSensor 1 WatchKit App
//

import Foundation
import Observation
import WatchConnectivity
import WatchKit

/// Taps the wrist once per iPhone message, as the 2018 watch app did, and keeps the size to
/// pulse the logo to.
@MainActor
@Observable
final class WatchSensorModel: NSObject, WCSessionDelegate {
    /// 1 until the first face is seen, as on the iPhone.
    private(set) var scale = 1.0
    /// Advances once per reading, so the logo pulses again even when its size is unchanged.
    private(set) var pulse = 0

    private var lastLaunch: String?
    private var lastCycle: Int?

    func start() {
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    func receive(_ update: SensorUpdate?) {
        WKInterfaceDevice.current().play(.click)
        guard let update, update.launch != lastLaunch || update.cycle != lastCycle else { return }
        lastLaunch = update.launch
        lastCycle = update.cycle
        scale = update.scale
        pulse += 1
    }

    nonisolated func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {}

    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        let update = SensorUpdate(message: message)
        Task { @MainActor [weak self] in self?.receive(update) }
    }
}
