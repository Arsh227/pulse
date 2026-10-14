import AppKit

/// Small preferences window for focus/break durations (1–180 minutes).
final class SettingsWindow: NSObject, NSWindowDelegate {
    private let timer: TimerStore
    private let onChange: () -> Void
    private var window: NSWindow?
    private let focusField = NSTextField()
    private let restField = NSTextField()
    private let focusStepper = NSStepper()
    private let restStepper = NSStepper()

    init(timer: TimerStore, onChange: @escaping () -> Void) {
        self.timer = timer
        self.onChange = onChange
    }

    func show() {
        if window == nil { build() }
        focusStepper.integerValue = timer.focusMinutes
        restStepper.integerValue = timer.restMinutes
        focusField.integerValue = timer.focusMinutes
        restField.integerValue = timer.restMinutes
        window?.center()
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func build() {
        let w = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 300, height: 130),
                         styleMask: [.titled, .closable], backing: .buffered, defer: false)
        w.title = "Pulse Settings"
        w.isReleasedWhenClosed = false
        w.delegate = self

        let focusRow = row("Focus (minutes)", focusField, focusStepper, #selector(focusChanged(_:)))
        let restRow = row("Break (minutes)", restField, restStepper, #selector(restChanged(_:)))
        let stack = NSStackView(views: [focusRow, restRow])
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 14
        stack.translatesAutoresizingMaskIntoConstraints = false

        let content = NSView()
        content.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -20),
            stack.centerYAnchor.constraint(equalTo: content.centerYAnchor),
        ])
        w.contentView = content
        window = w
    }

    private func row(_ title: String, _ field: NSTextField, _ stepper: NSStepper, _ action: Selector) -> NSStackView {
        let label = NSTextField(labelWithString: title)
        label.widthAnchor.constraint(equalToConstant: 120).isActive = true
        field.widthAnchor.constraint(equalToConstant: 50).isActive = true
        field.alignment = .right
        field.target = self
        field.action = action
        stepper.minValue = 1
        stepper.maxValue = 180
        stepper.increment = 1
        stepper.target = self
        stepper.action = action
        let r = NSStackView(views: [label, field, stepper])
        r.spacing = 8
        return r
    }

    private func clamp(_ v: Int) -> Int { min(180, max(1, v)) }

    @objc private func focusChanged(_ sender: NSControl) {
        let v = clamp(sender.integerValue)
        timer.focusMinutes = v
        focusField.integerValue = v
        focusStepper.integerValue = v
        onChange()
    }

    @objc private func restChanged(_ sender: NSControl) {
        let v = clamp(sender.integerValue)
        timer.restMinutes = v
        restField.integerValue = v
        restStepper.integerValue = v
        onChange()
    }
}
