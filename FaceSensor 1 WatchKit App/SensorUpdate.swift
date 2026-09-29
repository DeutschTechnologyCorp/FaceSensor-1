//
//  SensorUpdate.swift
//  FaceSensor 1 WatchKit App
//

/// One face reading from the iPhone. All messages sent for one reading (1 centre, 2 left,
/// 4 right) carry the same launch id and cycle number.
nonisolated struct SensorUpdate: Sendable {
    let launch: String
    let cycle: Int
    /// The logo's size relative to rest: 1.2 close, 0.7 middle distance, 0.4 far.
    let scale: Double

    /// Nil for a message without a reading, such as the one the iPhone sends at launch.
    init?(message: [String: Any]) {
        guard let launch = message["launch"] as? String,
              let cycle = message["cycle"] as? Int,
              let scale = message["scale"] as? Double
        else { return nil }
        self.launch = launch
        self.cycle = cycle
        self.scale = scale
    }
}
