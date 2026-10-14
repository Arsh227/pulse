import AppKit

/// Briefly flashes a coloured border around every screen, e.g. when a timer ends.
final class FlashController {
    private var windows: [NSWindow] = []

    func flash(color: NSColor = .systemOrange, duration: TimeInterval = 0.6) {
        dismiss()
        for screen in NSScreen.screens {
            let w = NSWindow(contentRect: screen.frame, styleMask: .borderless,
                             backing: .buffered, defer: false)
            w.level = .screenSaver
            w.isOpaque = false
            w.backgroundColor = .clear
            w.ignoresMouseEvents = true
            w.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
            let v = NSView(frame: screen.frame)
            v.wantsLayer = true
            v.layer?.borderColor = color.cgColor
            v.layer?.borderWidth = 14
            w.contentView = v
            w.alphaValue = 0
            w.orderFrontRegardless()
            windows.append(w)
        }
        NSAnimationContext.runAnimationGroup({ ctx in
            ctx.duration = duration / 2
            windows.forEach { $0.animator().alphaValue = 1 }
        }, completionHandler: { [weak self] in
            NSAnimationContext.runAnimationGroup({ ctx in
                ctx.duration = duration / 2
                self?.windows.forEach { $0.animator().alphaValue = 0 }
            }, completionHandler: { self?.dismiss() })
        })
    }

    private func dismiss() {
        windows.forEach { $0.orderOut(nil) }
        windows.removeAll()
    }
}
