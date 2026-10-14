import Foundation

/// Simple focus/break countdown. Publishes ticks through closures so the
/// AppKit layer stays free of any UI framework dependency.
final class TimerStore {
    enum Phase: String { case idle, focus, rest }

    private(set) var phase: Phase = .idle
    private(set) var remaining: TimeInterval = 0
    var focusMinutes: Int {
        get { Self.stored("focusMinutes", default: 25) }
        set { UserDefaults.standard.set(newValue, forKey: "focusMinutes") }
    }
    var restMinutes: Int {
        get { Self.stored("restMinutes", default: 5) }
        set { UserDefaults.standard.set(newValue, forKey: "restMinutes") }
    }

    private static func stored(_ key: String, default value: Int) -> Int {
        let v = UserDefaults.standard.integer(forKey: key)
        return v > 0 ? v : value
    }

    var onTick: (() -> Void)?
    var onPhaseFinished: ((Phase) -> Void)?

    private var timer: Timer?

    func start(_ phase: Phase) {
        stop()
        guard phase != .idle else { return }
        self.phase = phase
        remaining = TimeInterval((phase == .focus ? focusMinutes : restMinutes) * 60)
        let t = Timer(timeInterval: 1, repeats: true) { [weak self] _ in self?.tick() }
        RunLoop.main.add(t, forMode: .common)
        timer = t
        onTick?()
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        phase = .idle
        remaining = 0
        onTick?()
    }

    private func tick() {
        remaining -= 1
        if remaining <= 0 {
            let finished = phase
            stop()
            onPhaseFinished?(finished)
        } else {
            onTick?()
        }
    }

    var display: String {
        let m = Int(remaining) / 60, s = Int(remaining) % 60
        return String(format: "%02d:%02d", m, s)
    }
}
