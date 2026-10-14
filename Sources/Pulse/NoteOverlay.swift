import AppKit

/// A small always-on-top floating note panel (toggle with the hotkey).
final class NoteOverlay {
    private var panel: NSPanel?
    private let textView = NSTextView()

    var isVisible: Bool { panel?.isVisible ?? false }

    func toggle() {
        if isVisible { panel?.orderOut(nil) } else { show() }
    }

    private func show() {
        if panel == nil { build() }
        panel?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func build() {
        let p = NSPanel(contentRect: NSRect(x: 0, y: 0, width: 320, height: 200),
                        styleMask: [.titled, .closable, .resizable, .utilityWindow, .nonactivatingPanel],
                        backing: .buffered, defer: false)
        p.title = "Pulse Note"
        p.level = .floating
        p.isFloatingPanel = true
        p.hidesOnDeactivate = false
        p.center()

        let scroll = NSScrollView(frame: p.contentView!.bounds)
        scroll.autoresizingMask = [.width, .height]
        scroll.hasVerticalScroller = true
        textView.autoresizingMask = .width
        textView.font = .systemFont(ofSize: 14)
        textView.string = UserDefaults.standard.string(forKey: "note") ?? ""
        textView.delegate = NoteSaver.shared
        scroll.documentView = textView
        p.contentView = scroll
        panel = p
    }
}

final class NoteSaver: NSObject, NSTextViewDelegate {
    static let shared = NoteSaver()
    func textDidChange(_ notification: Notification) {
        guard let tv = notification.object as? NSTextView else { return }
        UserDefaults.standard.set(tv.string, forKey: "note")
    }
}
