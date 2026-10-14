import AppKit
import ServiceManagement
import UserNotifications

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let timer = TimerStore()
    private let flash = FlashController()
    private let note = NoteOverlay()
    private let hotkey = HotkeyManager()
    private lazy var settings = SettingsWindow(timer: timer) { [weak self] in self?.refresh() }

    func applicationDidFinishLaunching(_ notification: Notification) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }

        timer.onTick = { [weak self] in self?.refresh() }
        timer.onPhaseFinished = { [weak self] phase in self?.finished(phase) }
        hotkey.register { [weak self] in self?.note.toggle() }
        refresh()
    }

    private func refresh() {
        statusItem.button?.title = timer.phase == .idle ? "⏱" : "⏱ \(timer.display)"
        statusItem.menu = buildMenu()
    }

    private func buildMenu() -> NSMenu {
        let m = NSMenu()
        if timer.phase == .idle {
            m.addItem(item("Start Focus (\(timer.focusMinutes) min)", #selector(startFocus)))
            m.addItem(item("Start Break (\(timer.restMinutes) min)", #selector(startRest)))
        } else {
            m.addItem(item("Stop \(timer.phase.rawValue.capitalized)", #selector(stopTimer)))
        }
        m.addItem(.separator())
        m.addItem(item("Toggle Note  (⌃⌥P)", #selector(toggleNote)))
        m.addItem(item("Settings…", #selector(openSettings), key: ","))
        let login = item("Launch at Login", #selector(toggleLogin))
        login.state = SMAppService.mainApp.status == .enabled ? .on : .off
        m.addItem(login)
        m.addItem(.separator())
        m.addItem(item("Quit Pulse", #selector(quit), key: "q"))
        return m
    }

    private func item(_ title: String, _ sel: Selector, key: String = "") -> NSMenuItem {
        let i = NSMenuItem(title: title, action: sel, keyEquivalent: key)
        i.target = self
        return i
    }

    private func finished(_ phase: TimerStore.Phase) {
        flash.flash(color: phase == .focus ? .systemGreen : .systemBlue)
        let c = UNMutableNotificationContent()
        c.title = phase == .focus ? "Focus session done" : "Break over"
        c.body = phase == .focus ? "Time for a break." : "Back to work."
        c.sound = .default
        UNUserNotificationCenter.current()
            .add(UNNotificationRequest(identifier: UUID().uuidString, content: c, trigger: nil))
    }

    @objc private func startFocus() { timer.start(.focus) }
    @objc private func startRest() { timer.start(.rest) }
    @objc private func stopTimer() { timer.stop() }
    @objc private func toggleNote() { note.toggle() }
    @objc private func openSettings() { settings.show() }
    @objc private func toggleLogin() {
        let service = SMAppService.mainApp
        do {
            if service.status == .enabled { try service.unregister() } else { try service.register() }
        } catch {
            let a = NSAlert()
            a.messageText = "Couldn't change Launch at Login"
            a.informativeText = "\(error.localizedDescription)\n\nMove Pulse.app to /Applications and try again."
            a.runModal()
        }
        refresh()
    }
    @objc private func quit() { NSApp.terminate(nil) }
}
