import Carbon.HIToolbox
import Foundation

/// Registers one global hotkey via Carbon (no Accessibility permission needed).
final class HotkeyManager {
    private var ref: EventHotKeyRef?
    private var handlerRef: EventHandlerRef?
    fileprivate var action: (() -> Void)?

    /// Default: Control + Option + P
    func register(keyCode: UInt32 = UInt32(kVK_ANSI_P),
                  modifiers: UInt32 = UInt32(controlKey | optionKey),
                  action: @escaping () -> Void) {
        self.action = action
        var spec = EventTypeSpec(eventClass: OSType(kEventClassKeyboard),
                                 eventKind: UInt32(kEventHotKeyPressed))
        InstallEventHandler(GetApplicationEventTarget(), { _, _, userData in
            guard let userData else { return noErr }
            Unmanaged<HotkeyManager>.fromOpaque(userData).takeUnretainedValue().action?()
            return noErr
        }, 1, &spec, Unmanaged.passUnretained(self).toOpaque(), &handlerRef)

        let id = EventHotKeyID(signature: OSType(0x504C5345), id: 1) // 'PLSE'
        RegisterEventHotKey(keyCode, modifiers, id, GetApplicationEventTarget(), 0, &ref)
    }

    deinit {
        if let ref { UnregisterEventHotKey(ref) }
        if let handlerRef { RemoveEventHandler(handlerRef) }
    }
}
